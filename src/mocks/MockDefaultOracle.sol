// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MockDefaultOracle
 * @notice Mock implementation of the Default oracle that returns fixed metrics for testing
 */
contract MockDefaultOracle {
    /**
     * @notice Returns fixed mock metrics regardless of validator address
     * @return balance The mock balance (100 ether)
     * @return uptime The mock uptime score (95)
     * @return speed The mock speed score (80)
     * @return integrity The mock integrity score (90)
     * @return stake The mock stake score (50)
     * @return reward The mock reward amount (1 ether)
     * @return slashing The mock slashing amount (0.1 ether)
     */
    function getValidatorMetrics(
        address
    )
        external
        view
        returns (
            uint256 balance,
            uint256 uptime,
            uint256 speed,
            uint256 integrity,
            uint256 stake,
            uint256 reward,
            uint256 slashing,
            uint256 timestamp
        )
    {
        return (
            100 ether, // balance
            95, // uptime (0-100)
            80, // speed (0-100)
            90, // integrity (0-100)
            50, // stake (0-100)
            1 ether, // reward
            0.1 ether, // slashing
            block.timestamp
        );
    }
}
