// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IOracleManager
 * @notice Interface for the OracleManager contract that manages oracle adapters and performance data
 */
interface IOracleManager {
    /* ========== EVENTS ========== */

    event OracleAuthorized(address indexed oracle);
    event OracleDeauthorized(address indexed oracle);
    event OracleActiveStateChanged(address indexed oracle, bool active);
    event MaxPerformanceBoundUpdated(uint256 newBound);
    event PerformanceUpdated(address indexed validator, uint256 timestamp);
    // Add new event for validation failures
    event ValidatorBehaviorCheckFailed(address indexed validator, string reason);
    // add event for staleness check
    event MaxOracleStalenessUpdated(uint256);
    event OracleDataStale(address indexed oracle, address indexed validator, uint256 timestamp, uint256 currentTime);
    // Add this event to the contract
    event SanityCheckerUpdated(address indexed newChecker);
    event MinValidOraclesUpdated(uint256 newMinimum);

    /* ========== VIEW FUNCTIONS ========== */

    /// @notice Gets the maximum performance bound
    function maxPerformanceBound() external view returns (uint256);

    /// @notice Gets the count of authorized oracles
    function getAuthorizedOracleCount() external view returns (uint256);

    /// @notice Checks if an oracle is authorized
    function isAuthorizedOracle(address oracle) external view returns (bool);

    /// @notice Checks if an oracle is active
    function isActiveOracle(address oracle) external view returns (bool);

    /* ========== MUTATIVE FUNCTIONS ========== */

    /// @notice Authorizes a new oracle adapter
    function authorizeOracleAdapter(address oracle) external;

    /// @notice Deauthorizes an oracle adapter
    function deauthorizeOracle(address oracle) external;

    /// @notice Sets the active state of an oracle
    function setOracleActive(address oracle, bool active) external;

    /// @notice Generates performance data from oracle responses
    function generatePerformance(address) external returns (bool);
}
