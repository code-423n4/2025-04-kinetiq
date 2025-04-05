// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/StakingAccountant.sol";

contract ManagerStakingAccountantScript is Script {
    using stdJson for string;

    function authorizeStakingManager(string memory configPath, address manager, address kHYPEToken) external {
        // Load config and contracts
        string memory config = vm.readFile(configPath);
        address stakingAccountant = config.readAddress(".deployed.stakingAccountantProxy");

        // Execute transaction
        vm.broadcast();
        StakingAccountant(stakingAccountant).authorizeStakingManager(manager, kHYPEToken);
    }

    function deauthorizeStakingManager(string memory configPath, address manager) external {
        // Load config and contracts
        string memory config = vm.readFile(configPath);
        address stakingAccountant = config.readAddress(".deployed.stakingAccountantProxy");

        // Execute transaction
        vm.broadcast();
        StakingAccountant(stakingAccountant).deauthorizeStakingManager(manager);
    }

    function checkExchangeRatio(string memory configPath) external view {
        // Load config and contracts
        string memory config = vm.readFile(configPath);
        address stakingAccountant = config.readAddress(".deployed.stakingAccountantProxy");

        // Get total amounts
        StakingAccountant accountant = StakingAccountant(stakingAccountant);
        uint256 totalStaked = accountant.totalStaked();
        uint256 totalClaimed = accountant.totalClaimed();
        uint256 totalRewards = accountant.totalRewards();
        uint256 totalSlashing = accountant.totalSlashing();

        // Log current state
        console.log("=== StakingAccountant State ===");
        console.log("Total Staked:", totalStaked);
        console.log("Total Claimed:", totalClaimed);
        console.log("Total Rewards:", totalRewards);
        console.log("Total Slashing:", totalSlashing);
    }

    function convertKHYPEToHYPE(string memory configPath, uint256 kHYPEAmount) external view {
        // Load config and contracts
        string memory config = vm.readFile(configPath);
        address stakingAccountant = config.readAddress(".deployed.stakingAccountantProxy");

        // Calculate and log conversion
        uint256 hypeAmount = StakingAccountant(stakingAccountant).kHYPEToHYPE(kHYPEAmount);
        console.log("=== kHYPE to HYPE Conversion ===");
        console.log("kHYPE Amount:", kHYPEAmount);
        console.log("HYPE Amount:", hypeAmount);
    }

    function convertHYPEToKHYPE(string memory configPath, uint256 hypeAmount) external view {
        // Load config and contracts
        string memory config = vm.readFile(configPath);
        address stakingAccountant = config.readAddress(".deployed.stakingAccountantProxy");

        // Calculate and log conversion
        uint256 kHYPEAmount = StakingAccountant(stakingAccountant).HYPEToKHYPE(hypeAmount);
        console.log("=== HYPE to kHYPE Conversion ===");
        console.log("HYPE Amount:", hypeAmount);
        console.log("kHYPE Amount:", kHYPEAmount);
    }
}
