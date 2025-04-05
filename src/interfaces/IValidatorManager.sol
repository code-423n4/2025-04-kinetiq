// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IValidatorManager
 * @notice Interface for the ValidatorManager contract that manages validator operations
 */
interface IValidatorManager {
    /* ========== STRUCTS ========== */

    /// @notice Struct containing validator information and performance metrics
    struct Validator {
        uint256 balance; // Current balance/stake of the validator
        uint256 uptimeScore; // Score measuring validator uptime (0-10000)
        uint256 speedScore; // Score measuring transaction speed (0-10000)
        uint256 integrityScore; // Score measuring data integrity (0-10000)
        uint256 selfStakeScore; // Score measuring self-staked amount (0-10000)
        uint256 lastUpdateTime; // Timestamp of last score update
        bool active; // Whether the validator is currently active
    }

    struct RebalanceRequest {
        address staking; // Staking that initiated the request's belonging
        address validator; // Validator being rebalanced
        uint256 amount; // Amount to move
    }

    struct PerformanceReport {
        uint256 balance;
        uint256 uptimeScore;
        uint256 speedScore;
        uint256 integrityScore;
        uint256 selfStakeScore;
        uint256 timestamp;
    }

    /* ========== EVENTS ========== */

    event EmergencyWithdrawalLimitUpdated(uint256 newLimit);
    event ValidatorAdded(address indexed validator);
    event ValidatorRemoved(address indexed validator);
    event ValidatorScoreUpdated(address indexed validator, uint256 totalScore);
    event StakeRebalanced(address indexed validator, uint256 newStake);
    event StakeLimitsUpdated(uint256 minLimit, uint256 maxLimit);
    event EmergencyWithdrawalRequested(address indexed validator, uint256 amount);
    event EmergencyWithdrawalProcessed(address indexed validator, uint256 amount);
    event SlashingEventReported(address indexed validator, uint256 amount);
    event PerformanceReportGenerated(address indexed validator, uint256 timestamp);
    event RebalanceRequestAdded(address indexed validator, uint256 amount);
    event RebalanceBatchProcessed(uint256 startIndex, uint256 endIndex, uint256 timestamp);
    event RebalanceRequestClosed(address indexed validator, uint256 amount);
    event AllRebalanceRequestsClosed(uint256 count, uint256 timestamp);
    event EmergencyCooldownUpdated(uint256 cooldown);
    event RebalanceCooldownUpdated(uint256 cooldown);
    event ValidatorActivated(address indexed validator);
    event ValidatorDeactivated(address indexed validator);
    event ValidatorReactivated(address indexed validator);
    event ValidatorPerformanceUpdated(address indexed validator, uint256 timestamp, uint256 blockNumber);
    event RewardEventReported(address indexed validator, uint256 amount);
    event DelegationUpdated(
        address indexed stakingManager,
        address indexed oldDelegation,
        address indexed newDelegation
    );

    /* ========== VIEW FUNCTIONS ========== */

    /// @notice Gets the total number of validators
    function validatorCount() external view returns (uint256);

    /// @notice Gets validator info at a specific index
    function validatorAt(uint256 index) external view returns (address, Validator memory);

    /// @notice Gets validator info for a specific address
    function validatorInfo(address validator) external view returns (Validator memory);

    /// @notice Gets validator scores
    function validatorScores(
        address validator
    ) external view returns (uint256 uptime, uint256 speed, uint256 integrity, uint256 selfStake);

    /// @notice Gets validator balance
    function validatorBalance(address validator) external view returns (uint256);

    /// @notice Gets validator active state
    function validatorActiveState(address validator) external view returns (bool);

    /// @notice Gets total slashing amount
    function totalSlashing() external view returns (uint256);

    /// @notice Get validator's last update time
    function validatorLastUpdateTime(address validator) external view returns (uint256);

    /// @notice Check if validator has pending rebalance
    function hasPendingRebalance(address validator) external view returns (bool);

    /// @notice Get total rewards across all validators
    function totalRewards() external view returns (uint256);

    /// @notice Get the total rewards earned by a validator
    function validatorRewards(address validator) external view returns (uint256);

    /// @notice Get the total amount slashed from a validator
    function validatorSlashing(address validator) external view returns (uint256);

    /// @notice Get the delegation address for the staking
    function getDelegation(address stakingManager) external view returns (address);

    /* ========== MUTATIVE FUNCTIONS ========== */

    /// @notice Activates a validator
    function activateValidator(address validator) external;

    /// @notice Deactivates a validator
    function deactivateValidator(address validator) external;

    /// @notice Updates validator performance metrics
    function updateValidatorPerformance(
        address validator,
        uint256 balance,
        uint256 uptimeScore,
        uint256 speedScore,
        uint256 integrityScore,
        uint256 selfStakeScore
    ) external;

    /// @notice Reports a slashing event for a validator
    function reportSlashingEvent(address validator, uint256 slashAmount) external;

    /// @notice Report a reward event for a validator
    function reportRewardEvent(address validator, uint256 amount) external;

    /// @notice Request withdrawals for multiple validators
    function rebalanceWithdrawal(
        address stakingManager,
        address[] calldata validators,
        uint256[] calldata withdrawalAmounts
    ) external;

    /// @notice Close multiple rebalance requests
    function closeRebalanceRequests(address stakingManager, address[] calldata validators) external;

    /// @notice Set the delegation address for the staking
    function setDelegation(address stakingManager, address validator) external;
}
