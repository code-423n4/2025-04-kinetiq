// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/StakingManager.sol";

/**
 * @title TreasuryOperationsScript
 * @notice Script for executing treasury operations
 */
contract TreasuryOperationsScript is Script {
    using stdJson for string;

    StakingManager public stakingManager;

    /**
     * @notice Withdraw any token from Spot balance
     * @param configFile Path to the config JSON file
     * @param tokenId The token ID to withdraw
     * @param amount The amount to withdraw
     */
    function withdrawTokenFromSpot(string memory configFile, uint64 tokenId, uint64 amount) public {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load deployed contract addresses
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        // Execute the transaction
        vm.startBroadcast();
        stakingManager.withdrawTokenFromSpot(tokenId, amount);
        vm.stopBroadcast();

        console.log("Withdrawn %d of token ID %d from Spot balance to treasury", amount, tokenId);
    }

    /**
     * @notice Rescue tokens accidentally sent to the contract
     * @param configFile Path to the config JSON file
     * @param token The token address (use address(0) for native tokens)
     * @param amount The amount to rescue
     */
    function rescueToken(string memory configFile, address token, uint256 amount) public {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load deployed contract addresses
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        // Execute the transaction
        vm.startBroadcast();
        stakingManager.rescueToken(token, amount);
        vm.stopBroadcast();

        console.log("Rescued %d of token %s to treasury", amount, token);
    }
}
