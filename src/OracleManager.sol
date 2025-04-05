// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// solhint-disable-next-line no-unused-vars

/* ========== IMPORTS ========== */

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IValidatorManager} from "./interfaces/IValidatorManager.sol";
import {IPauserRegistry} from "./interfaces/IPauserRegistry.sol";
import {IOracleManager} from "./interfaces/IOracleManager.sol";
import {IOracleAdapter} from "./oracles/IOracleAdapter.sol";
import {IValidatorSanityChecker} from "./validators/IValidatorSanityChecker.sol";

/* ========== CONTRACT ========== */

/**
 * @title OracleManager
 * @notice Manages oracle data updates with challenge mechanism
 * @dev Implements upgradeable patterns and includes pause functionality
 */
contract OracleManager is IOracleManager, Initializable, AccessControlEnumerableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* ========== LIBRARIES ========== */

    using EnumerableSet for EnumerableSet.AddressSet;

    /* ========== STATE VARIABLES ========== */

    // Roles
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    // Core contract references
    IPauserRegistry public pauserRegistry;
    IValidatorManager public validatorManager;
    IValidatorSanityChecker public sanityChecker;

    // Performance configuration
    uint256 public maxPerformanceBound;
    uint256 public MIN_UPDATE_INTERVAL;
    uint256 public MAX_ORACLE_STALENESS;
    uint256 public MIN_VALID_ORACLES;

    // Validator update tracking
    mapping(address => uint256) public lastValidatorUpdate;

    // Oracle management
    EnumerableSet.AddressSet private authorizedOracles;
    mapping(address => bool) private activeOracles;

    /* ========== MODIFIERS ========== */

    modifier whenNotPaused() {
        require(!pauserRegistry.isPaused(address(this)), "Contract is paused");
        _;
    }

    /* ========== INITIALIZATION ========== */

    function initialize(
        address admin,
        address operator,
        address manager,
        address _pauserRegistry,
        address _validatorManager,
        uint256 _maxPerformanceBound
    ) public initializer {
        __AccessControlEnumerable_init();

        require(_pauserRegistry != address(0), "Invalid pauser registry");
        require(_validatorManager != address(0), "Invalid validator manager");
        require(_maxPerformanceBound > 0, "Invalid max performance bound");

        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, operator);
        _grantRole(MANAGER_ROLE, manager);

        pauserRegistry = IPauserRegistry(_pauserRegistry);
        validatorManager = IValidatorManager(_validatorManager);
        maxPerformanceBound = _maxPerformanceBound;

        // Initialize update intervals
        MIN_UPDATE_INTERVAL = 24 hours;
        MAX_ORACLE_STALENESS = 1 hours;
        MIN_VALID_ORACLES = 1; // Default to 1, can be changed by admin
    }

    /* ========== ORACLE MANAGEMENT ========== */

    function authorizeOracleAdapter(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {
        require(adapter != address(0), "Invalid oracle address");
        require(IOracleAdapter(adapter).supportsInterface(type(IOracleAdapter).interfaceId), "Invalid adapter");

        authorizedOracles.add(adapter);
        // A new authorized oracle adapter should be deactivated by default; the assignment will be omitted here.
        // activeOracles[adapter] = false;
        emit OracleAuthorized(adapter);
    }

    function deauthorizeOracle(address adapter) external whenNotPaused onlyRole(MANAGER_ROLE) {
        authorizedOracles.remove(adapter);
        delete activeOracles[adapter];
        emit OracleDeauthorized(adapter);
    }

    function setOracleActive(address adapter, bool active) external whenNotPaused onlyRole(MANAGER_ROLE) {
        require(authorizedOracles.contains(adapter), "Oracle not authorized");
        activeOracles[adapter] = active;
        emit OracleActiveStateChanged(adapter, active);
    }

    function isAuthorizedOracle(address adapter) public view returns (bool) {
        return authorizedOracles.contains(adapter);
    }

    function isActiveOracle(address adapter) public view returns (bool) {
        return authorizedOracles.contains(adapter) && activeOracles[adapter];
    }

    function getAuthorizedOracleCount() external view returns (uint256) {
        return authorizedOracles.length();
    }

    function getAuthorizedOracleAt(uint256 index) external view returns (address) {
        return authorizedOracles.at(index);
    }

    function getAuthorizedOracles() external view returns (address[] memory) {
        return authorizedOracles.values();
    }

    /* ========== PERFORMANCE GENERATION ========== */

    function generatePerformance(address validator) external whenNotPaused onlyRole(OPERATOR_ROLE) returns (bool) {
        // Check minimum interval between updates for this specific validator
        require(
            block.timestamp >= lastValidatorUpdate[validator] + MIN_UPDATE_INTERVAL,
            "Update too frequent for validator"
        );
        require(validator != address(0), "Invalid validator address");

        // Check no pending rebalance
        require(!validatorManager.hasPendingRebalance(validator), "Validator has pending rebalance");

        uint256 oracleCount = authorizedOracles.length();
        require(oracleCount > 0, "No oracles authorized");

        // Initialize aggregation variables
        uint256 totalBalance;
        uint256 totalUptimeScore;
        uint256 totalSpeedScore;
        uint256 totalIntegrityScore;
        uint256 totalSelfStakeScore;
        uint256 totalRewardAmount;
        uint256 totalSlashAmount;
        uint256 validOracleCount;

        // Aggregate data from all oracles for this validator
        for (uint256 i = 0; i < oracleCount; ) {
            address oracle = authorizedOracles.at(i);
            if (!activeOracles[oracle]) {
                unchecked {
                    ++i;
                } // Increment before continue
                continue; // Skip inactive oracles
            }

            try IOracleAdapter(oracle).getPerformance(validator) returns (
                uint256 balance,
                uint256 uptimeScore,
                uint256 speedScore,
                uint256 integrityScore,
                uint256 selfStakeScore,
                uint256 accRewardAmount,
                uint256 accSlashAmount,
                uint256 timestamp
            ) {
                // Check data freshness
                if (block.timestamp > timestamp + MAX_ORACLE_STALENESS) {
                    // Skip stale data and continue to next oracle, skip emit event when timestamp is zero
                    if (timestamp > 0) emit OracleDataStale(oracle, validator, timestamp, block.timestamp);
                    unchecked {
                        ++i;
                    }
                    continue;
                }

                // Sanity checks
                if (
                    uptimeScore <= maxPerformanceBound &&
                    speedScore <= maxPerformanceBound &&
                    integrityScore <= maxPerformanceBound &&
                    selfStakeScore <= maxPerformanceBound
                ) {
                    // Aggregate scores
                    totalBalance += balance;
                    totalUptimeScore += uptimeScore;
                    totalSpeedScore += speedScore;
                    totalIntegrityScore += integrityScore;
                    totalSelfStakeScore += selfStakeScore;
                    totalRewardAmount += accRewardAmount;
                    totalSlashAmount += accSlashAmount;
                    validOracleCount++;
                }
            } catch {
                // Skip failed oracle calls
            }

            unchecked {
                ++i;
            } // Single increment point at the end of the loop
        }

        // Require minimum number of valid oracle reports
        require(validOracleCount >= MIN_VALID_ORACLES, "Insufficient valid oracles");

        // Calculate averages
        uint256 avgBalance = totalBalance / validOracleCount;
        uint256 avgUptimeScore = totalUptimeScore / validOracleCount;
        uint256 avgSpeedScore = totalSpeedScore / validOracleCount;
        uint256 avgIntegrityScore = totalIntegrityScore / validOracleCount;
        uint256 avgSelfStakeScore = totalSelfStakeScore / validOracleCount;
        uint256 avgRewardAmount = totalRewardAmount / validOracleCount;
        uint256 avgSlashAmount = totalSlashAmount / validOracleCount;

        // Get previous values
        uint256 previousSlashing = validatorManager.validatorSlashing(validator);
        uint256 previousRewards = validatorManager.validatorRewards(validator);

        // Skip sanity check if sanityChecker is not set (address zero)
        bool valid = true;
        string memory reason = "";

        if (address(sanityChecker) != address(0)) {
            // Perform validator sanity check using the sanity checker
            (valid, reason) = sanityChecker.checkValidatorSanity(
                validator,
                avgBalance,
                avgSlashAmount,
                avgRewardAmount,
                avgUptimeScore,
                avgSpeedScore,
                avgIntegrityScore,
                avgSelfStakeScore
            );
        }

        if (!valid) {
            emit ValidatorBehaviorCheckFailed(validator, reason);
            return false;
        }

        // Update validator performance in ValidatorManager
        validatorManager.updateValidatorPerformance(
            validator,
            avgBalance,
            avgUptimeScore,
            avgSpeedScore,
            avgIntegrityScore,
            avgSelfStakeScore
        );

        // Report only new rewards/slashing
        if (avgRewardAmount > previousRewards) {
            uint256 newRewardAmount = avgRewardAmount - previousRewards;
            validatorManager.reportRewardEvent(validator, newRewardAmount);
        }
        if (avgSlashAmount > previousSlashing) {
            uint256 newSlashAmount = avgSlashAmount - previousSlashing;
            validatorManager.reportSlashingEvent(validator, newSlashAmount);
        }

        // Update lastUpdateTime for this validator at the end of successful execution
        lastValidatorUpdate[validator] = block.timestamp;
        emit PerformanceUpdated(validator, block.timestamp);

        return true;
    }

    /* ========== ADMIN FUNCTIONS ========== */

    function setMaxPerformanceBound(uint256 newBound) external onlyRole(OPERATOR_ROLE) {
        require(newBound > 0, "Invalid bound");
        maxPerformanceBound = newBound;
        emit MaxPerformanceBoundUpdated(newBound);
    }

    function setMinUpdateInterval(uint256 newInterval) external onlyRole(MANAGER_ROLE) {
        require(newInterval > 0, "Invalid interval");
        MIN_UPDATE_INTERVAL = newInterval;
    }

    // Add setter for MAX_ORACLE_STALENESS
    function setMaxOracleStaleness(uint256 newStaleness) external onlyRole(MANAGER_ROLE) {
        require(newStaleness > 0, "Invalid staleness period");
        MAX_ORACLE_STALENESS = newStaleness;
        emit MaxOracleStalenessUpdated(newStaleness);
    }

    // Add function to update behavior checker
    function setSanityChecker(address newChecker) external onlyRole(DEFAULT_ADMIN_ROLE) {
        sanityChecker = IValidatorSanityChecker(newChecker);
        emit SanityCheckerUpdated(newChecker);
    }

    function setMinValidOracles(uint256 newMinimum) external onlyRole(MANAGER_ROLE) {
        require(newMinimum > 0, "Minimum must be greater than zero");
        MIN_VALID_ORACLES = newMinimum;
        emit MinValidOraclesUpdated(newMinimum);
    }
}
