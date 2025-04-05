// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Base.t.sol";
import "../src/interfaces/IStakingAccountant.sol";

contract StakingAccountantTest is BaseTest {
    // Events from IStakingAccountant
    event StakingManagerAuthorized(address indexed manager, address indexed token);
    event StakingManagerDeauthorized(address indexed manager);
    event StakeRecorded(address indexed manager, uint256 amount);
    event ClaimRecorded(address indexed manager, uint256 amount);

    address public mockStakingManager;

    function setUp() public override {
        super.setUp();
        mockStakingManager = makeAddr("mockStakingManager");
    }

    function test_Initialize() public view {
        assertEq(address(stakingAccountant.validatorManager()), address(validatorManager));
        assertTrue(stakingAccountant.hasRole(stakingAccountant.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(stakingAccountant.hasRole(stakingAccountant.MANAGER_ROLE(), manager));

        // Check that StakingManager is authorized with kHYPE token
        assertTrue(stakingAccountant.isAuthorizedManager(address(stakingManager)));
        assertEq(stakingAccountant.getManagerToken(address(stakingManager)), address(kHYPE));
    }

    function test_AuthorizeStakingManager() public {
        vm.startPrank(manager);

        vm.expectEmit(true, true, false, false);
        emit StakingManagerAuthorized(mockStakingManager, address(kHYPE));
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(kHYPE));

        assertTrue(stakingAccountant.isAuthorizedManager(mockStakingManager));
        assertEq(stakingAccountant.getManagerToken(mockStakingManager), address(kHYPE));
        vm.stopPrank();
    }

    function test_AuthorizeStakingManager_RevertUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                address(this),
                stakingAccountant.MANAGER_ROLE()
            )
        );
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(kHYPE));
    }

    function test_AuthorizeStakingManager_RevertZeroAddress() public {
        vm.startPrank(manager);
        vm.expectRevert("Invalid manager address");
        stakingAccountant.authorizeStakingManager(address(0), address(kHYPE));

        vm.expectRevert("Invalid kHYPE token address");
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(0));
        vm.stopPrank();
    }

    function test_DeauthorizeStakingManager() public {
        // First authorize
        vm.startPrank(manager);
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(kHYPE));
        assertTrue(stakingAccountant.isAuthorizedManager(mockStakingManager));
        vm.stopPrank();

        // Then deauthorize - need to switch to admin for this
        vm.startPrank(admin);
        vm.expectEmit(true, false, false, false);
        emit StakingManagerDeauthorized(mockStakingManager);
        stakingAccountant.deauthorizeStakingManager(mockStakingManager);
        vm.stopPrank();

        assertFalse(stakingAccountant.isAuthorizedManager(mockStakingManager));
    }

    function test_RecordStake() public {
        // Authorize mock staking manager
        vm.prank(manager);
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(kHYPE));

        uint256 stakeAmount = 1 ether;
        vm.prank(mockStakingManager);
        vm.expectEmit(true, false, false, true);
        emit StakeRecorded(mockStakingManager, stakeAmount);
        stakingAccountant.recordStake(stakeAmount);

        assertEq(stakingAccountant.totalStaked(), stakeAmount);
    }

    function test_RecordStake_RevertUnauthorized() public {
        uint256 stakeAmount = 1 ether;
        vm.expectRevert("Not authorized");
        stakingAccountant.recordStake(stakeAmount);
    }

    function test_RecordClaim() public {
        // Authorize mock staking manager
        vm.prank(manager);
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(kHYPE));

        uint256 claimAmount = 0.5 ether;
        vm.prank(mockStakingManager);
        vm.expectEmit(true, false, false, true);
        emit ClaimRecorded(mockStakingManager, claimAmount);
        stakingAccountant.recordClaim(claimAmount);

        assertEq(stakingAccountant.totalClaimed(), claimAmount);
    }

    function test_ExchangeRatio_InitialState() public view {
        // Should return 1:1 ratio when no kHYPE minted
        assertEq(stakingAccountant.kHYPEToHYPE(1e8), 1e8);
        assertEq(stakingAccountant.HYPEToKHYPE(1e8), 1e8);
    }

    function test_ExchangeRatio_WithStakeAndRewards() public {
        // Setup: Authorize staking manager and record stake
        vm.startPrank(manager);
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(kHYPE));
        vm.stopPrank();

        // Create and activate a validator
        address testValidator = makeAddr("testValidator");
        vm.startPrank(admin);
        validatorManager.grantRole(validatorManager.MANAGER_ROLE(), admin);
        validatorManager.activateValidator(testValidator);
        vm.stopPrank();

        // Mint some kHYPE
        vm.prank(address(stakingManager));
        kHYPE.mint(address(this), 100e8);

        // Record stake and simulate rewards
        vm.startPrank(mockStakingManager);
        stakingAccountant.recordStake(100e8);
        vm.stopPrank();

        // Simulate rewards through validator manager
        vm.prank(address(oracleManager));
        validatorManager.reportRewardEvent(testValidator, 10e8);

        // Test exchange ratio
        // Total HYPE = 110e8 (100e8 staked + 10e8 rewards)
        // Total kHYPE = 100e8
        // Ratio should be 1.1:1
        assertEq(stakingAccountant.kHYPEToHYPE(100e8), 110e8);
        assertEq(stakingAccountant.HYPEToKHYPE(110e8), 100e8);
    }

    function test_ExchangeRatio_WithSlashing() public {
        // Setup: Authorize staking manager and record stake
        vm.startPrank(manager);
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(kHYPE));
        vm.stopPrank();

        // Create and activate a validator
        address testValidator = makeAddr("testValidator");
        vm.startPrank(admin);
        validatorManager.grantRole(validatorManager.MANAGER_ROLE(), admin);
        validatorManager.activateValidator(testValidator);
        vm.stopPrank();

        // Mint some kHYPE
        vm.prank(address(stakingManager));
        kHYPE.mint(address(this), 100e8);

        // Record stake and simulate slashing
        vm.startPrank(mockStakingManager);
        stakingAccountant.recordStake(100e8);
        vm.stopPrank();

        // Simulate slashing through validator manager
        vm.startPrank(address(oracleManager));
        validatorManager.reportSlashingEvent(testValidator, 10e8);
        vm.stopPrank();

        // Test exchange ratio
        // Total HYPE = 90e8 (100e8 staked - 10e8 slashed)
        // Total kHYPE = 100e8
        // Ratio should be 0.9:1
        assertEq(stakingAccountant.kHYPEToHYPE(100e8), 90e8);
        assertEq(stakingAccountant.HYPEToKHYPE(90e8), 100e8);
    }

    function test_UniqueTokenTracking() public {
        // Get initial token count (stakingManager is already authorized with kHYPE)
        uint256 initialTokenCount = stakingAccountant.getUniqueTokenCount();

        // Create a second kHYPE token using a proxy pattern like in the setup
        KHYPE kHYPE2Implementation = new KHYPE();
        TransparentUpgradeableProxy kHYPE2Proxy = new TransparentUpgradeableProxy(
            address(kHYPE2Implementation),
            admin,
            ""
        );
        KHYPE kHYPE2 = KHYPE(address(kHYPE2Proxy));

        // Initialize the proxy
        vm.startPrank(admin);
        kHYPE2.initialize(
            "kHYPE Token 2",
            "KHYPE2",
            admin,
            address(stakingManager),
            address(stakingManager),
            address(pauserRegistry)
        );
        vm.stopPrank();

        // Create a second mock staking manager
        address mockStakingManager2 = makeAddr("mockStakingManager2");

        // Authorize both managers with different tokens
        vm.startPrank(manager);
        stakingAccountant.authorizeStakingManager(mockStakingManager, address(kHYPE));
        stakingAccountant.authorizeStakingManager(mockStakingManager2, address(kHYPE2));
        vm.stopPrank();

        // Check unique token tracking - should be initial count + 1 (for kHYPE2)
        assertEq(stakingAccountant.getUniqueTokenCount(), initialTokenCount + 1);

        // Deauthorize one manager and check if token is still tracked
        vm.prank(admin);
        stakingAccountant.deauthorizeStakingManager(mockStakingManager);

        // kHYPE should still be tracked because stakingManager is using it
        assertEq(stakingAccountant.getUniqueTokenCount(), initialTokenCount + 1);

        // Deauthorize stakingManager and check if kHYPE is removed
        vm.prank(admin);
        stakingAccountant.deauthorizeStakingManager(address(stakingManager));

        // Now kHYPE should be removed, only kHYPE2 remains
        assertEq(stakingAccountant.getUniqueTokenCount(), 1);
    }
}
