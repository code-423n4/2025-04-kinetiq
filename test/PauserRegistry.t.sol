// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Base.t.sol";

contract PauserRegistryTest is BaseTest {
    event ContractPaused(address indexed pausedContract);
    event ContractUnpaused(address indexed unpausedContract);
    event ContractAuthorized(address indexed contractAddress);
    event ContractDeauthorized(address indexed contractAddress);
    event ContractsUpdated(address[] contracts);

    function setUp() public override {
        super.setUp();
    }

    function test_InitialState() public view {
        // Check roles
        assertTrue(pauserRegistry.hasRole(pauserRegistry.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(pauserRegistry.hasRole(pauserRegistry.PAUSER_ROLE(), pauser));
        assertTrue(pauserRegistry.hasRole(pauserRegistry.UNPAUSER_ROLE(), unpauser));
        assertTrue(pauserRegistry.hasRole(pauserRegistry.PAUSE_ALL_ROLE(), pauseAll));

        // Check registered contracts
        address[] memory registeredContracts = pauserRegistry.getAuthorizedContracts();
        assertEq(registeredContracts.length, 4);
        assertEq(registeredContracts[0], address(stakingManager));
        assertEq(registeredContracts[1], address(kHYPE));
        assertEq(registeredContracts[2], address(validatorManager));
        assertEq(registeredContracts[3], address(oracleManager));
    }

    function test_PauseContract() public {
        vm.prank(pauser);
        vm.expectEmit(true, false, false, false);
        emit ContractPaused(address(stakingManager));

        pauserRegistry.pauseContract(address(stakingManager));
        assertTrue(pauserRegistry.isPaused(address(stakingManager)));
    }

    function test_UnpauseContract() public {
        // First pause
        vm.prank(pauser);
        pauserRegistry.pauseContract(address(stakingManager));

        // Then unpause
        vm.prank(unpauser);
        vm.expectEmit(true, false, false, false);
        emit ContractUnpaused(address(stakingManager));

        pauserRegistry.unpauseContract(address(stakingManager));
        assertFalse(pauserRegistry.isPaused(address(stakingManager)));
    }

    function test_AuthorizeContract() public {
        address newContract = makeAddr("newContract");

        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit ContractAuthorized(newContract);

        pauserRegistry.authorizeContract(newContract);
        assertTrue(pauserRegistry.isAuthorizedContract(newContract));
    }

    function test_DeauthorizeContract() public {
        vm.prank(admin);
        vm.expectEmit(true, false, false, false);
        emit ContractDeauthorized(address(stakingManager));

        pauserRegistry.deauthorizeContract(address(stakingManager));
        assertFalse(pauserRegistry.isAuthorizedContract(address(stakingManager)));
    }

    function test_RevertUnauthorizedPause() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                user,
                pauserRegistry.PAUSER_ROLE()
            )
        );
        vm.prank(user);
        pauserRegistry.pauseContract(address(stakingManager));
    }

    function test_RevertUnauthorizedUnpause() public {
        // First pause
        vm.prank(pauser);
        pauserRegistry.pauseContract(address(stakingManager));

        // Try unauthorized unpause
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                user,
                pauserRegistry.UNPAUSER_ROLE()
            )
        );
        vm.prank(user);
        pauserRegistry.unpauseContract(address(stakingManager));
    }

    function test_RevertPauseUnauthorizedContract() public {
        address unauthorizedContract = makeAddr("unauthorized");

        vm.expectRevert("Contract not authorized");
        vm.prank(pauser);
        pauserRegistry.pauseContract(unauthorizedContract);
    }

    function test_EmergencyPauseAll() public {
        vm.prank(pauseAll);

        // Expect ContractPaused events for each contract
        vm.expectEmit(true, false, false, false);
        emit ContractPaused(address(stakingManager));
        vm.expectEmit(true, false, false, false);
        emit ContractPaused(address(kHYPE));
        vm.expectEmit(true, false, false, false);
        emit ContractPaused(address(validatorManager));
        vm.expectEmit(true, false, false, false);
        emit ContractPaused(address(oracleManager));

        pauserRegistry.emergencyPauseAll();

        // Check all contracts are paused
        assertTrue(pauserRegistry.isPaused(address(stakingManager)));
        assertTrue(pauserRegistry.isPaused(address(kHYPE)));
        assertTrue(pauserRegistry.isPaused(address(validatorManager)));
        assertTrue(pauserRegistry.isPaused(address(oracleManager)));
    }

    function test_UnpauseAllContracts() public {
        // First pause all
        vm.prank(pauseAll);
        pauserRegistry.emergencyPauseAll();

        // Then unpause each contract individually
        vm.startPrank(unpauser);

        pauserRegistry.unpauseContract(address(stakingManager));
        pauserRegistry.unpauseContract(address(kHYPE));
        pauserRegistry.unpauseContract(address(validatorManager));
        pauserRegistry.unpauseContract(address(oracleManager));

        vm.stopPrank();

        // Check all contracts are unpaused
        assertFalse(pauserRegistry.isPaused(address(stakingManager)));
        assertFalse(pauserRegistry.isPaused(address(kHYPE)));
        assertFalse(pauserRegistry.isPaused(address(validatorManager)));
        assertFalse(pauserRegistry.isPaused(address(oracleManager)));
    }

    function test_EmergencyPauseAll_RevertUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                user,
                pauserRegistry.PAUSE_ALL_ROLE()
            )
        );
        vm.prank(user);
        pauserRegistry.emergencyPauseAll();
    }

    function test_Initialize_Success() public view {
        // Verify roles are set correctly
        assertTrue(pauserRegistry.hasRole(pauserRegistry.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(pauserRegistry.hasRole(pauserRegistry.PAUSER_ROLE(), pauser));
        assertTrue(pauserRegistry.hasRole(pauserRegistry.UNPAUSER_ROLE(), unpauser));
        assertTrue(pauserRegistry.hasRole(pauserRegistry.PAUSE_ALL_ROLE(), pauseAll));

        // Verify all contracts are authorized
        assertTrue(pauserRegistry.isAuthorizedContract(address(stakingManager)));
        assertTrue(pauserRegistry.isAuthorizedContract(address(validatorManager)));
        assertTrue(pauserRegistry.isAuthorizedContract(address(oracleManager)));
        assertTrue(pauserRegistry.isAuthorizedContract(address(kHYPE)));

        // Verify contract count
        assertEq(pauserRegistry.getAuthorizedContractCount(), 4);
    }
}
