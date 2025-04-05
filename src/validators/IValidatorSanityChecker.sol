// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IValidatorSanityChecker
 * @notice Interface for validator data sanity checking
 * @dev Defines the methods required for validator sanity checking
 */
interface IValidatorSanityChecker {
    // Events
    event SlashingToleranceUpdated(uint256 newTolerance);
    event RewardsToleranceUpdated(uint256 newTolerance);
    event ScoreToleranceUpdated(uint256 newTolerance);
    event MaxScoreBoundUpdated(uint256 newBound);

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
    ) external view returns (bool valid, string memory reason);

    /**
     * @notice Set the slashing tolerance threshold
     * @param newTolerance New tolerance in basis points (e.g., 500 = 5%)
     */
    function setSlashingTolerance(uint256 newTolerance) external;

    /**
     * @notice Set the rewards tolerance threshold
     * @param newTolerance New tolerance in basis points (e.g., 1000 = 10%)
     */
    function setRewardsTolerance(uint256 newTolerance) external;

    /**
     * @notice Set the score tolerance threshold
     * @param newTolerance New tolerance in basis points (e.g., 2000 = 20%)
     */
    function setScoreTolerance(uint256 newTolerance) external;

    /**
     * @notice Set the maximum score bound
     * @param newBound New maximum score bound
     */
    function setMaxScoreBound(uint256 newBound) external;
}
