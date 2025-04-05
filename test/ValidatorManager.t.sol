// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Base.t.sol";
import {IValidatorManager} from "../src/interfaces/IValidatorManager.sol";

contract ValidatorManagerTest is BaseTest {
    address public validator1 = makeAddr("validator1");
    address public validator2 = makeAddr("validator2");

    function setUp() public override {
        super.setUp();
    }

    function test_InitialState() public view {
        // Check roles
        assertTrue(validatorManager.hasRole(validatorManager.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(validatorManager.hasRole(validatorManager.MANAGER_ROLE(), manager));
        assertTrue(validatorManager.hasRole(validatorManager.ORACLE_MANAGER_ROLE(), address(oracleManager)));

        // Check contract references
        assertEq(address(validatorManager.pauserRegistry()), address(pauserRegistry));

        // Check initial state
        assertEq(validatorManager.validatorCount(), 0);
        assertEq(validatorManager.totalSlashing(), 0);
        assertEq(validatorManager.totalRewards(), 0);
    }

    function test_UpdateValidatorPerformance() public {
        // Setup validator
        vm.prank(manager);
        validatorManager.activateValidator(validator1);

        // Update performance as OracleManager contract
        vm.prank(address(oracleManager));
        vm.expectEmit(true, false, false, false);
        emit IValidatorManager.ValidatorPerformanceUpdated(validator1, block.timestamp, block.number);

        validatorManager.updateValidatorPerformance(
            validator1,
            100 ether, // balance
            8000, // uptimeScore (80%)
            7500, // speedScore (75%)
            9000, // integrityScore (90%)
            8500 // selfStakeScore (85%)
        );

        // Verify scores
        (uint256 uptime, uint256 speed, uint256 integrity, uint256 selfStake) = validatorManager.validatorScores(
            validator1
        );

        assertEq(uptime, 8000);
        assertEq(speed, 7500);
        assertEq(integrity, 9000);
        assertEq(selfStake, 8500);
        assertEq(validatorManager.validatorBalance(validator1), 100 ether);
    }

    function test_UpdateValidatorPerformance_RevertUnauthorized() public {
        vm.prank(manager);
        validatorManager.activateValidator(validator1);

        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                user,
                validatorManager.ORACLE_MANAGER_ROLE()
            )
        );
        vm.prank(user);
        validatorManager.updateValidatorPerformance(validator1, 100 ether, 8000, 7500, 9000, 8500);
    }

    function test_UpdateValidatorPerformance_RevertInvalidScores() public {
        vm.prank(manager);
        validatorManager.activateValidator(validator1);

        vm.startPrank(address(oracleManager));

        // Test score exceeding maximum (10000)
        vm.expectRevert("Score exceeds maximum");
        validatorManager.updateValidatorPerformance(
            validator1,
            100 ether,
            10001, // Invalid uptime score
            7500,
            9000,
            8500
        );

        // Test other scores
        vm.expectRevert("Score exceeds maximum");
        validatorManager.updateValidatorPerformance(
            validator1,
            100 ether,
            8000,
            10001, // Invalid speed score
            9000,
            8500
        );

        vm.expectRevert("Score exceeds maximum");
        validatorManager.updateValidatorPerformance(
            validator1,
            100 ether,
            8000,
            7500,
            10001, // Invalid integrity score
            8500
        );

        vm.expectRevert("Score exceeds maximum");
        validatorManager.updateValidatorPerformance(
            validator1,
            100 ether,
            8000,
            7500,
            9000,
            10001 // Invalid self stake score
        );

        vm.stopPrank();
    }

    function test_ActivateValidator_Success() public {
        vm.prank(manager);
        validatorManager.activateValidator(validator1);

        assertTrue(validatorManager.validatorActiveState(validator1));
        assertEq(validatorManager.validatorCount(), 1);
    }

    function test_DeactivateValidator_Success() public {
        vm.prank(manager);
        validatorManager.activateValidator(validator1);

        vm.prank(manager);
        validatorManager.deactivateValidator(validator1);

        assertFalse(validatorManager.validatorActiveState(validator1));
    }

    function test_ReportSlashingEvent() public {
        vm.prank(manager);
        validatorManager.activateValidator(validator1);

        vm.prank(address(oracleManager));
        validatorManager.updateValidatorPerformance(validator1, 100 ether, 8000, 7500, 9000, 8500);

        vm.prank(address(oracleManager));
        vm.expectEmit(true, false, false, true);
        emit IValidatorManager.SlashingEventReported(validator1, 1 ether);
        validatorManager.reportSlashingEvent(validator1, 1 ether);

        assertEq(validatorManager.validatorSlashing(validator1), 1 ether);
        assertEq(validatorManager.totalSlashing(), 1 ether);
    }

    function test_ReportRewardEvent() public {
        vm.prank(manager);
        validatorManager.activateValidator(validator1);

        vm.prank(address(oracleManager));
        vm.expectEmit(true, false, false, true);
        emit IValidatorManager.RewardEventReported(validator1, 1 ether);
        validatorManager.reportRewardEvent(validator1, 1 ether);

        assertEq(validatorManager.validatorRewards(validator1), 1 ether);
        assertEq(validatorManager.totalRewards(), 1 ether);
    }

    function test_SetDelegation() public {
        vm.prank(manager);
        validatorManager.activateValidator(validator1);

        vm.prank(manager);
        vm.expectEmit(true, true, true, false);
        emit IValidatorManager.DelegationUpdated(address(stakingManager), address(0), validator1);
        validatorManager.setDelegation(address(stakingManager), validator1);

        assertEq(validatorManager.getDelegation(address(stakingManager)), validator1);
    }

    function test_RebalanceWithdrawal() public {
        // Setup validator
        vm.startPrank(manager);
        validatorManager.activateValidator(validator1);
        validatorManager.activateValidator(validator2);
        vm.stopPrank();

        // Update balances through oracle
        vm.prank(address(oracleManager));
        validatorManager.updateValidatorPerformance(validator1, 100 ether, 8000, 7500, 9000, 8500);

        vm.prank(address(oracleManager));
        validatorManager.updateValidatorPerformance(validator2, 50 ether, 8000, 7500, 9000, 8500);

        // Prepare rebalance data
        address[] memory validators = new address[](2);
        validators[0] = validator1;
        validators[1] = validator2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 30 ether;
        amounts[1] = 20 ether;

        // Execute rebalance
        vm.prank(manager);
        validatorManager.rebalanceWithdrawal(address(stakingManager), validators, amounts);

        // Verify rebalance requests were created
        assertTrue(validatorManager.hasPendingRebalance(validator1));
        assertTrue(validatorManager.hasPendingRebalance(validator2));

        // Verify StakingManager was called to process withdrawals
        // This requires mocking/checking the stakingManager calls
    }

    function test_CloseRebalanceRequests() public {
        // Setup initial state similar to rebalance test
        vm.startPrank(manager);
        validatorManager.activateValidator(validator1);
        validatorManager.activateValidator(validator2);
        vm.stopPrank();

        // Update validator balance through oracle
        vm.prank(address(oracleManager));
        validatorManager.updateValidatorPerformance(validator1, 100 ether, 8000, 7500, 9000, 8500);

        // Create rebalance requests
        address[] memory validators = new address[](1);
        validators[0] = validator1;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 30 ether;

        // Setup StakingManager balance for redelegation
        vm.deal(address(stakingManager), 100 ether);

        vm.startPrank(manager);
        validatorManager.rebalanceWithdrawal(address(stakingManager), validators, amounts);

        // Set delegation for redelegation
        validatorManager.setDelegation(address(stakingManager), validator2);

        // Close rebalance requests
        vm.expectEmit(true, false, false, true);
        emit IValidatorManager.RebalanceRequestClosed(validator1, 30 ether);
        validatorManager.closeRebalanceRequests(address(stakingManager), validators);
        vm.stopPrank();

        // Verify requests were cleared
        assertFalse(validatorManager.hasPendingRebalance(validator1));
    }

    // function test_EmergencyWithdrawal() public {
    //     // Setup validator
    //     vm.startPrank(manager);
    //     validatorManager.activateValidator(validator1);
    //     vm.stopPrank();

    //     // Update balance through oracle
    //     vm.prank(address(oracleManager));
    //     validatorManager.updateValidatorPerformance(validator1, 100 ether, 8000, 7500, 9000, 8500);

    //     // Setup StakingManager balance
    //     vm.deal(address(stakingManager), 100 ether);

    //     // Warp past the cooldown period
    //     vm.warp(block.timestamp + 24 hours + 1);

    //     // Request emergency withdrawal
    //     vm.startPrank(sentinel);
    //     vm.expectEmit(true, false, false, true);
    //     emit IValidatorManager.EmergencyWithdrawalRequested(validator1, 50 ether);
    //     emit IValidatorManager.RebalanceRequestAdded(validator1, 50 ether);
    //     validatorManager.requestEmergencyWithdrawal(address(stakingManager), validator1, 50 ether);
    //     vm.stopPrank();

    //     // Verify rebalance request was created
    //     assertTrue(validatorManager.hasPendingRebalance(validator1));
    // }
}
