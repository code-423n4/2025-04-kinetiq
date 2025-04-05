// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IValidatorManager} from "../interfaces/IValidatorManager.sol";
import {IValidatorSanityChecker} from "./IValidatorSanityChecker.sol";

/**
 * @title ValidatorSanityChecker
 * @notice Handles validator data sanity checks and anomaly detection
 * @dev Isolated contract for easier upgrades of sanity checking logic
 */
contract ValidatorSanityChecker is IValidatorSanityChecker {
    using Math for uint256;

    // Constants
    uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

    // Tolerance thresholds
    // Rationale:
    // A 1-3 BP tolerance is ~1.5-5x the expected daily yield of 0.006%
    // Rewards should be highly predictable with minimal variance
    // This tight tolerance ensures early detection of reward anomalies
    // Particularly important for a system with such a conservative APR
    uint256 public slashingTolerance = 1; // 0.01% in basis points
    uint256 public rewardsTolerance = 1; // 0.01% in basis points
    // 90% health check
    uint256 public scoreTolerance = 1000; // 10% in basis points

    // Maximum bounds for scores
    uint256 public maxScoreBound = BASIS_POINTS; // 100% in basis points

    // State variables
    IValidatorManager public validatorManager;

    /**
     * @notice Constructor to set the validator manager
     * @param _validatorManager Address of the validator manager contract
     */
    constructor(address _validatorManager) {
        require(_validatorManager != address(0), "Invalid validator manager");
        validatorManager = IValidatorManager(_validatorManager);
    }

    /**
     * @notice Set the slashing tolerance threshold
     * @param newTolerance New tolerance in basis points (e.g., 500 = 5%)
     */
    function setSlashingTolerance(uint256 newTolerance) external {
        require(newTolerance <= 2000, "Tolerance too high"); // Max 20%
        slashingTolerance = newTolerance;
        emit SlashingToleranceUpdated(newTolerance);
    }

    /**
     * @notice Set the rewards tolerance threshold
     * @param newTolerance New tolerance in basis points (e.g., 1000 = 10%)
     */
    function setRewardsTolerance(uint256 newTolerance) external {
        require(newTolerance <= 3000, "Tolerance too high"); // Max 30%
        rewardsTolerance = newTolerance;
        emit RewardsToleranceUpdated(newTolerance);
    }

    /**
     * @notice Set the score tolerance threshold
     * @param newTolerance New tolerance in basis points (e.g., 2000 = 20%)
     */
    function setScoreTolerance(uint256 newTolerance) external {
        require(newTolerance <= 5000, "Tolerance too high"); // Max 50%
        scoreTolerance = newTolerance;
        emit ScoreToleranceUpdated(newTolerance);
    }

    /**
     * @notice Set the maximum score bound
     * @param newBound New maximum score bound
     */
    function setMaxScoreBound(uint256 newBound) external {
        require(newBound > 0, "Bound must be positive");
        maxScoreBound = newBound;
        emit MaxScoreBoundUpdated(newBound);
    }

    /**
     * @notice Perform sanity checks on validator data
     * @param validator Address of the validator
     * @param avgBalance Average balance reported by oracles
     * @param avgSlashAmount Average slash amount reported by oracles
     * @param avgRewardAmount Average reward amount reported by oracles
     * @param avgUptimeScore Average uptime score reported by oracles
     * @param avgSpeedScore Average speed score reported by oracles
     * @param avgIntegrityScore Average integrity score reported by oracles
     * @param avgSelfStakeScore Average self-stake score reported by oracles
     * @return valid Whether the data passes all sanity checks
     * @return reason Reason for rejection if not valid
     */
    function checkValidatorSanity(
        address validator,
        uint256 avgBalance,
        uint256 avgSlashAmount,
        uint256 avgRewardAmount,
        uint256 avgUptimeScore,
        uint256 avgSpeedScore,
        uint256 avgIntegrityScore,
        uint256 avgSelfStakeScore
    ) external view returns (bool valid, string memory reason) {
        // Skip checks if balance is zero; it's a validator's total delegated value, not a balance to a staker,
        // so for a living validator, balance equaling zero is impossible.
        if (avgBalance == 0) {
            return (false, "Zero balance");
        }

        // Check score bounds
        if (avgUptimeScore > maxScoreBound) {
            return (false, "Uptime score exceeds maximum");
        }
        if (avgSpeedScore > maxScoreBound) {
            return (false, "Speed score exceeds maximum");
        }
        if (avgIntegrityScore > maxScoreBound) {
            return (false, "Integrity score exceeds maximum");
        }
        if (avgSelfStakeScore > maxScoreBound) {
            return (false, "Self-stake score exceeds maximum");
        }

        // Get previous values from validator manager
        uint256 previousSlashing = validatorManager.validatorSlashing(validator);
        uint256 previousRewards = validatorManager.validatorRewards(validator);

        // Get previous scores
        (
            uint256 prevUptimeScore,
            uint256 prevSpeedScore,
            uint256 prevIntegrityScore,
            uint256 prevSelfStakeScore
        ) = validatorManager.validatorScores(validator);

        // Check slashing changes
        if (avgSlashAmount < previousSlashing) {
            // This should never happen for accumulated metrics
            return (false, "Slashing decreased unexpectedly");
        } else if (avgSlashAmount > previousSlashing) {
            // Only check the increment amount
            uint256 slashingDiff = avgSlashAmount - previousSlashing;
            uint256 slashingBps = Math.mulDiv(slashingDiff, BASIS_POINTS, avgBalance);
            if (slashingBps > slashingTolerance) {
                return (false, "Excessive slashing increment");
            }
        }

        // Check rewards changes
        if (avgRewardAmount < previousRewards) {
            // This should never happen for accumulated metrics
            return (false, "Rewards decreased unexpectedly");
        } else if (avgRewardAmount > previousRewards) {
            // Only check the increment amount
            uint256 rewardsDiff = avgRewardAmount - previousRewards;
            uint256 rewardsBps = Math.mulDiv(rewardsDiff, BASIS_POINTS, avgBalance);
            if (rewardsBps > rewardsTolerance) {
                return (false, "Excessive rewards increment");
            }
        }

        // Check score changes
        if (prevUptimeScore > 0) {
            uint256 uptimeDiff = avgUptimeScore > prevUptimeScore
                ? avgUptimeScore - prevUptimeScore
                : prevUptimeScore - avgUptimeScore;

            if (uptimeDiff > scoreTolerance) {
                return (false, "Excessive uptime score change");
            }
        }

        if (prevSpeedScore > 0) {
            uint256 speedDiff = avgSpeedScore > prevSpeedScore
                ? avgSpeedScore - prevSpeedScore
                : prevSpeedScore - avgSpeedScore;

            if (speedDiff > scoreTolerance) {
                return (false, "Excessive speed score change");
            }
        }

        if (prevIntegrityScore > 0) {
            uint256 integrityDiff = avgIntegrityScore > prevIntegrityScore
                ? avgIntegrityScore - prevIntegrityScore
                : prevIntegrityScore - avgIntegrityScore;

            if (integrityDiff > scoreTolerance) {
                return (false, "Excessive integrity score change");
            }
        }

        if (prevSelfStakeScore > 0) {
            uint256 selfStakeDiff = avgSelfStakeScore > prevSelfStakeScore
                ? avgSelfStakeScore - prevSelfStakeScore
                : prevSelfStakeScore - avgSelfStakeScore;

            if (selfStakeDiff > scoreTolerance) {
                return (false, "Excessive self-stake score change");
            }
        }

        return (true, "");
    }
}
