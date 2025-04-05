// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title IOracleAdapter
 * @notice Interface for oracle adapters that provide validator performance data
 */
interface IOracleAdapter is IERC165 {
    /**
     * @notice Get performance metrics for a validator
     * @param validator Address of the validator
     * @return balance Current balance of the validator(means the total delegated value, not a value to a staker)
     * @return uptimeScore Uptime performance score (0-10000)
     * @return speedScore Speed performance score (0-10000)
     * @return integrityScore Integrity performance score (0-10000)
     * @return selfStakeScore Self-stake performance score (0-10000)
     * @return rewardAmount Cumulative rewards earned by validator
     * @return slashAmount Cumulative amount slashed from validator
     * @return timestamp Timestamp of the performance data
     */
    function getPerformance(
        address validator
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
        );

    /**
     * @notice Get the name of the oracle adapter
     * @return string Name of the oracle adapter
     */
    function name() external view returns (string memory);

    /**
     * @notice Get the version of the oracle adapter
     * @return string Version of the oracle adapter
     */
    function version() external view returns (string memory);

    /**
     * @notice Check if the oracle adapter supports a specific interface
     * @param interfaceId Interface ID to check
     * @return bool True if the interface is supported, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
