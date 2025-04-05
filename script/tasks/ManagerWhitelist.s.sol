// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/StakingManager.sol";

contract ManagerWhitelistScript is Script {
    using stdJson for string;

    StakingManager public stakingManager;

    function enableWhitelist(string memory configFile) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load contract
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        vm.startBroadcast();
        stakingManager.enableWhitelist();
        vm.stopBroadcast();

        console.log("Whitelist enabled");
    }

    function disableWhitelist(string memory configFile) external {
        string memory json = vm.readFile(configFile);
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        vm.startBroadcast();
        stakingManager.disableWhitelist();
        vm.stopBroadcast();

        console.log("Whitelist disabled");
    }

    function addToWhitelist(string memory configFile, address[] calldata accounts) external {
        string memory json = vm.readFile(configFile);
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        vm.startBroadcast();
        stakingManager.addToWhitelist(accounts);
        vm.stopBroadcast();

        console.log("Added addresses to whitelist:");
        for (uint256 i = 0; i < accounts.length; i++) {
            console.log(accounts[i]);
        }
    }

    function removeFromWhitelist(string memory configFile, address[] calldata accounts) external {
        string memory json = vm.readFile(configFile);
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        vm.startBroadcast();
        stakingManager.removeFromWhitelist(accounts);
        vm.stopBroadcast();

        console.log("Removed addresses from whitelist:");
        for (uint256 i = 0; i < accounts.length; i++) {
            console.log(accounts[i]);
        }
    }
}
