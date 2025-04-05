// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Base.t.sol";
import "../src/oracles/IOracleAdapter.sol";
import {IValidatorManager} from "../src/interfaces/IValidatorManager.sol";

contract MockOracleAdapter is IOracleAdapter {
    function supportsInterface(bytes4 interfaceId) external pure virtual returns (bool) {
        return interfaceId == type(IOracleAdapter).interfaceId;
    }

    function getPerformance(
        address /* validator */
    )
        external
        view
        returns (
            uint256 balance,
            uint256 uptimeScore,
            uint256 speedScore,
            uint256 integrityScore,
            uint256 selfStakeScore,
            uint256 rewardAmount,
            uint256 slashAmount,
            uint256 timestamp
        )
    {
        // Return fixed values for testing with current timestamp
        return (0.1 ether, 80, 80, 80, 80, 0, 0, block.timestamp);
    }

    function name() external pure returns (string memory) {
        return "MockOracleAdapter";
    }

    function version() external pure returns (string memory) {
        return "1.0.0";
    }
}

contract MockInvalidOracleAdapter is MockOracleAdapter {
    // Override supportsInterface to always return false
    function supportsInterface(bytes4) external pure override returns (bool) {
        return false;
    }
}

contract OracleManagerTest is BaseTest {
    MockOracleAdapter public mockOracle;

    event ExchangeRateUpdated(uint256 newRate, uint256 timestamp, uint256 confidence);
    event NetworkRewardRateUpdated(uint256 newRate, uint256 timestamp, uint256 confidence);
    event ValidatorPerformanceUpdated(
        address indexed validator,
        uint256 performance,
        uint256 timestamp,
        uint256 confidence
    );
    event OracleAuthorized(address indexed oracle);
    event OracleDeauthorized(address indexed oracle);
    event UpdateChallenged(bytes32 indexed updateId, address challenger);
    event UpdateConfirmed(bytes32 indexed updateId);
    event MaxPerformanceBoundUpdated(uint256 newBound);
    event TotalStakeUpdated(uint256 newTotalStake);
    event OracleActiveStateChanged(address indexed oracle, bool active);
    event ToleranceUpdated(string indexed toleranceType, uint256 newTolerance);

    function setUp() public override {
        super.setUp();

        operator = makeAddr("operator");
        manager = makeAddr("manager");
        mockOracle = new MockOracleAdapter();

        // Grant roles
        vm.startPrank(admin);
        oracleManager.grantRole(oracleManager.OPERATOR_ROLE(), operator);
        oracleManager.grantRole(oracleManager.MANAGER_ROLE(), manager);
        vm.stopPrank();
    }

    function test_InitialState() public view {
        assertTrue(oracleManager.hasRole(oracleManager.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(oracleManager.hasRole(oracleManager.OPERATOR_ROLE(), operator));
        assertTrue(oracleManager.hasRole(oracleManager.MANAGER_ROLE(), manager));

        assertEq(address(oracleManager.pauserRegistry()), address(pauserRegistry));
        assertEq(address(oracleManager.validatorManager()), address(validatorManager));

        assertEq(oracleManager.maxPerformanceBound(), maxPerformanceBound);

        assertEq(oracleManager.getAuthorizedOracleCount(), 0);
    }

    function test_AuthorizeOracle_Success() public {
        vm.prank(manager);
        vm.expectEmit(true, false, false, false, address(oracleManager));
        emit OracleAuthorized(address(mockOracle));

        oracleManager.authorizeOracleAdapter(address(mockOracle));

        assertTrue(oracleManager.isAuthorizedOracle(address(mockOracle)));
        assertFalse(oracleManager.isActiveOracle(address(mockOracle)));
        assertEq(oracleManager.getAuthorizedOracleCount(), 1);
    }

    function test_AuthorizeOracle_RevertUnauthorized() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)")),
                address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496), // Use the actual address from the error
                oracleManager.MANAGER_ROLE()
            )
        );
        vm.prank(address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496)); // Use the same address
        oracleManager.authorizeOracleAdapter(address(mockOracle));
    }

    function test_AuthorizeOracle_RevertInvalidAdapter() public {
        MockInvalidOracleAdapter invalidAdapter = new MockInvalidOracleAdapter();

        vm.prank(manager);
        vm.expectRevert("Invalid adapter");
        oracleManager.authorizeOracleAdapter(address(invalidAdapter));
    }

    function test_DeauthorizeOracle_Success() public {
        // First authorize the oracle
        vm.prank(manager);
        oracleManager.authorizeOracleAdapter(address(mockOracle));

        // Then deauthorize it
        vm.prank(manager);
        vm.expectEmit(true, false, false, false, address(oracleManager));
        emit OracleDeauthorized(address(mockOracle));

        oracleManager.deauthorizeOracle(address(mockOracle));

        assertFalse(oracleManager.isAuthorizedOracle(address(mockOracle)));
        assertFalse(oracleManager.isActiveOracle(address(mockOracle)));
        assertEq(oracleManager.getAuthorizedOracleCount(), 0);
    }

    function test_SetOracleActive() public {
        // First authorize the oracle
        vm.startPrank(manager);
        oracleManager.authorizeOracleAdapter(address(mockOracle));

        // Then activate it
        vm.expectEmit(true, false, false, true);
        emit OracleActiveStateChanged(address(mockOracle), true);
        oracleManager.setOracleActive(address(mockOracle), true);
        vm.stopPrank();

        assertTrue(oracleManager.isActiveOracle(address(mockOracle)));
    }

    function test_GeneratePerformance_Success() public {
        address testValidator = makeAddr("validator");

        // Setup validator and delegation
        vm.startPrank(admin);
        validatorManager.grantRole(validatorManager.MANAGER_ROLE(), admin);
        validatorManager.activateValidator(testValidator);
        validatorManager.setDelegation(address(stakingManager), testValidator);
        vm.stopPrank();

        // Setup oracle
        vm.startPrank(manager);
        oracleManager.authorizeOracleAdapter(address(mockOracle));
        oracleManager.setOracleActive(address(mockOracle), true);

        // Set the MAX_ORACLE_STALENESS to a higher value to prevent staleness issues
        oracleManager.setMaxOracleStaleness(24 hours);
        vm.stopPrank();

        // Set a timestamp far in the future to avoid "Update too frequent" error
        // This is crucial since the MIN_UPDATE_INTERVAL is typically 24 hours
        vm.warp(block.timestamp + oracleManager.MIN_UPDATE_INTERVAL() + 1 hours);
        vm.roll(block.number + 100);

        // Generate performance
        vm.prank(operator);
        oracleManager.generatePerformance(testValidator);

        // Verify validator info
        IValidatorManager.Validator memory validatorInfo = validatorManager.validatorInfo(testValidator);
        assertEq(validatorInfo.balance, 0.1 ether);
        assertEq(validatorInfo.uptimeScore, 80);
        assertEq(validatorInfo.speedScore, 80);
        assertEq(validatorInfo.integrityScore, 80);
        assertEq(validatorInfo.selfStakeScore, 80);
        assertTrue(validatorInfo.lastUpdateTime > 0);
        assertTrue(validatorInfo.active);

        // Verify delegation is set correctly
        assertEq(validatorManager.getDelegation(address(stakingManager)), testValidator);
    }

    function test_GeneratePerformance_RevertNoActiveOracles() public {
        // Create test validator address
        address testValidator = makeAddr("testValidator");

        // Setup validator first
        vm.startPrank(manager);
        validatorManager.activateValidator(testValidator);
        validatorManager.setDelegation(address(stakingManager), testValidator);

        // Authorize oracle but don't activate it
        oracleManager.authorizeOracleAdapter(address(mockOracle));

        // Deactivate the oracle explicitly to ensure it's not active
        oracleManager.setOracleActive(address(mockOracle), false);
        vm.stopPrank();

        // Set the lastValidatorUpdate for this validator to a very old timestamp
        // to bypass the "Update too frequent" check
        vm.warp(block.timestamp + oracleManager.MIN_UPDATE_INTERVAL() * 2);
        vm.roll(block.number + 100);

        // Try to generate performance - should revert since no oracles are active
        vm.prank(operator);
        vm.expectRevert("Insufficient valid oracles");
        oracleManager.generatePerformance(testValidator);
    }

    function test_AuthorizeOracleAdapter() public {
        address newOracle = makeAddr("newOracle");
        MockOracleAdapter mockNewOracle = new MockOracleAdapter();
        vm.etch(newOracle, address(mockNewOracle).code);

        vm.prank(manager);
        vm.expectEmit(true, false, false, false);
        emit OracleAuthorized(newOracle);
        oracleManager.authorizeOracleAdapter(newOracle);

        assertTrue(oracleManager.isAuthorizedOracle(newOracle));
        assertFalse(oracleManager.isActiveOracle(newOracle));
    }

    function test_DeauthorizeOracle() public {
        vm.prank(manager);
        vm.expectEmit(true, false, false, false);
        emit OracleDeauthorized(address(mockOracle));
        oracleManager.deauthorizeOracle(address(mockOracle));

        assertFalse(oracleManager.isAuthorizedOracle(address(mockOracle)));
        assertFalse(oracleManager.isActiveOracle(address(mockOracle)));
    }

    function test_SetMaxPerformanceBound() public {
        uint256 newBound = 9500;

        vm.prank(operator);
        vm.expectEmit(true, false, false, true);
        emit MaxPerformanceBoundUpdated(newBound);
        oracleManager.setMaxPerformanceBound(newBound);

        assertEq(oracleManager.maxPerformanceBound(), newBound);
    }

    function test_SetMinUpdateInterval() public {
        uint256 newInterval = 2 hours;

        vm.prank(manager);
        oracleManager.setMinUpdateInterval(newInterval);

        assertEq(oracleManager.MIN_UPDATE_INTERVAL(), newInterval);
    }

    function test_RevertTooFrequentUpdate() public {
        address testValidator = makeAddr("validator");

        vm.startPrank(manager);
        validatorManager.activateValidator(testValidator);
        validatorManager.setDelegation(address(stakingManager), testValidator);
        oracleManager.authorizeOracleAdapter(address(mockOracle));
        oracleManager.setOracleActive(address(mockOracle), true);
        oracleManager.setMinUpdateInterval(1 hours);
        vm.stopPrank();

        // Set initial block timestamp
        vm.warp(2 hours);
        vm.roll(100);

        // First update should succeed
        vm.prank(operator);
        oracleManager.generatePerformance(testValidator);

        // Try immediate second update - should revert
        vm.expectRevert("Update too frequent for validator");
        vm.prank(operator);
        oracleManager.generatePerformance(testValidator);

        // Should succeed for different validator
        address otherValidator = makeAddr("otherValidator");
        vm.prank(manager);
        validatorManager.activateValidator(otherValidator);

        vm.prank(operator);
        oracleManager.generatePerformance(otherValidator); // Should work

        // Move time forward but not enough for first validator
        vm.warp(2 hours + 30 minutes);
        vm.roll(200);

        // Try again with first validator - should still revert
        vm.expectRevert("Update too frequent for validator");
        vm.prank(operator);
        oracleManager.generatePerformance(testValidator);

        // Move time forward past interval
        vm.warp(4 hours);
        vm.roll(300);

        // Should succeed now for first validator
        vm.prank(operator);
        oracleManager.generatePerformance(testValidator);
    }
}
