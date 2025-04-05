// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Base.t.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";

contract KHYPETest is BaseTest {
    using ECDSA for bytes32;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public override {
        super.setUp();
    }

    function test_InitialState() public view {
        assertEq(kHYPE.name(), "kHYPE Token");
        assertEq(kHYPE.symbol(), "KHYPE");
        assertEq(kHYPE.decimals(), 18);
        assertEq(kHYPE.totalSupply(), 0);

        // Check roles
        assertTrue(kHYPE.hasRole(kHYPE.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(kHYPE.hasRole(kHYPE.MINTER_ROLE(), address(stakingManager)));
        assertTrue(kHYPE.hasRole(kHYPE.BURNER_ROLE(), address(stakingManager)));
    }

    function test_Mint() public {
        uint256 amount = 100 ether;

        vm.prank(address(stakingManager));
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), user, amount);
        kHYPE.mint(user, amount);

        assertEq(kHYPE.balanceOf(user), amount);
        assertEq(kHYPE.totalSupply(), amount);
    }

    function test_Mint_WhenPaused() public {
        // Pause contract
        vm.prank(pauser);
        pauserRegistry.pauseContract(address(kHYPE));

        vm.prank(address(stakingManager));
        vm.expectRevert("Contract is paused");
        kHYPE.mint(user, 100e18);
    }

    function test_Burn() public {
        // First mint
        uint256 amount = 100 ether;
        vm.prank(address(stakingManager));
        kHYPE.mint(user, amount);

        // Then burn
        vm.prank(address(stakingManager));
        vm.expectEmit(true, true, false, true);
        emit Transfer(user, address(0), amount);
        kHYPE.burn(user, amount);

        assertEq(kHYPE.balanceOf(user), 0);
        assertEq(kHYPE.totalSupply(), 0);
    }

    function test_Burn_WhenPaused() public {
        // Pause contract
        vm.prank(pauser);
        pauserRegistry.pauseContract(address(kHYPE));

        vm.prank(address(stakingManager));
        vm.expectRevert("Contract is paused");
        kHYPE.burn(user, 100e18);
    }

    function test_Transfer_WhenPaused() public {
        // First mint
        uint256 amount = 100 ether;
        vm.prank(address(stakingManager));
        kHYPE.mint(user, amount);

        // Pause contract
        vm.prank(pauser);
        pauserRegistry.pauseContract(address(kHYPE));

        // Try transfer
        vm.prank(user);
        vm.expectRevert("Contract is paused");
        kHYPE.transfer(address(1), amount);
    }

    function test_TransferFrom_WhenPaused() public {
        // First mint
        uint256 amount = 100 ether;
        vm.prank(address(stakingManager));
        kHYPE.mint(user, amount);

        // Approve
        vm.prank(user);
        kHYPE.approve(address(1), amount);

        // Pause contract
        vm.prank(pauser);
        pauserRegistry.pauseContract(address(kHYPE));

        // Try transferFrom
        vm.prank(address(1));
        vm.expectRevert("Contract is paused");
        kHYPE.transferFrom(user, address(2), amount);
    }

    function test_Permit() public {
        uint256 privateKey = 0xA11CE;
        address owner = vm.addr(privateKey);
        address spender = makeAddr("bob");
        uint256 value = 100 ether;
        uint256 deadline = block.timestamp + 1 days;
        uint256 nonce = kHYPE.nonces(owner);

        // Create permit signature
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                spender,
                value,
                nonce,
                deadline
            )
        );

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", kHYPE.DOMAIN_SEPARATOR(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);

        // Execute permit
        kHYPE.permit(owner, spender, value, deadline, v, r, s);

        assertEq(kHYPE.allowance(owner, spender), value);
        assertEq(kHYPE.nonces(owner), 1);
    }

    function test_RevertPermitExpired() public {
        uint256 privateKey = 0xA11CE;
        address owner = vm.addr(privateKey);
        address spender = makeAddr("bob");
        uint256 value = 100 ether;
        uint256 deadline = block.timestamp - 1; // Expired
        uint256 nonce = kHYPE.nonces(owner);

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                spender,
                value,
                nonce,
                deadline
            )
        );

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", kHYPE.DOMAIN_SEPARATOR(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);

        vm.expectRevert(abi.encodeWithSelector(ERC20PermitUpgradeable.ERC2612ExpiredSignature.selector, deadline));
        kHYPE.permit(owner, spender, value, deadline, v, r, s);
    }

    function test_RevertUnauthorizedMint() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                user,
                kHYPE.MINTER_ROLE()
            )
        );
        vm.prank(user);
        kHYPE.mint(user, 100 ether);
    }

    function test_RevertUnauthorizedBurn() public {
        // First mint
        uint256 amount = 100 ether;
        vm.prank(address(stakingManager));
        kHYPE.mint(user, amount);

        // Try unauthorized burn
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                user,
                kHYPE.BURNER_ROLE()
            )
        );
        vm.prank(user);
        kHYPE.burn(user, amount);
    }

    function test_PauserRegistryIntegration() public {
        // Test pausing through registry
        vm.prank(pauser);
        pauserRegistry.pauseContract(address(kHYPE));
        assertTrue(pauserRegistry.isPaused(address(kHYPE)));

        // Verify contract operations are paused
        vm.prank(address(stakingManager));
        vm.expectRevert("Contract is paused");
        kHYPE.mint(user, 100e18);

        // Test unpausing
        vm.prank(unpauser);
        pauserRegistry.unpauseContract(address(kHYPE));
        assertFalse(pauserRegistry.isPaused(address(kHYPE)));

        // Verify contract operations work again
        vm.prank(address(stakingManager));
        kHYPE.mint(user, 100e18);
    }
}
