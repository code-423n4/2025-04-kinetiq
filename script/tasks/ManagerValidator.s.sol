// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/ValidatorManager.sol";
import "../../src/StakingManager.sol";

contract ManagerValidatorScript is Script {
    using stdJson for string;

    ValidatorManager public validatorManager;
    StakingManager public stakingManager;

    function activateValidator(string memory configFile, address validator) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load contract
        validatorManager = ValidatorManager(json.readAddress(".deployed.ValidatorManager"));

        vm.startBroadcast();
        validatorManager.activateValidator(validator);
        vm.stopBroadcast();

        console.log("Activated validator:", validator);
    }

    function deactivateValidator(string memory configFile, address validator) external {
        string memory json = vm.readFile(configFile);
        validatorManager = ValidatorManager(json.readAddress(".deployed.ValidatorManager"));

        vm.startBroadcast();
        validatorManager.deactivateValidator(validator);
        vm.stopBroadcast();

        console.log("Deactivated validator:", validator);
    }

    function reactivateValidator(string memory configFile, address validator) external {
        string memory json = vm.readFile(configFile);
        validatorManager = ValidatorManager(json.readAddress(".deployed.ValidatorManager"));

        vm.startBroadcast();
        validatorManager.reactivateValidator(validator);
        vm.stopBroadcast();

        console.log("Reactivated validator:", validator);
    }

    function setDelegation(string memory configFile, address validator) external {
        string memory json = vm.readFile(configFile);
        validatorManager = ValidatorManager(json.readAddress(".deployed.ValidatorManager"));
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        vm.startBroadcast();
        validatorManager.setDelegation(address(stakingManager), validator);
        vm.stopBroadcast();

        console.log("Set delegation to:", validator);
    }

    function setWithdrawalDelay(string memory configFile, uint256 newDelay) external {
        string memory json = vm.readFile(configFile);
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        vm.startBroadcast();
        stakingManager.setWithdrawalDelay(newDelay);
        vm.stopBroadcast();

        console.log("Set withdrawal delay to:", newDelay, "seconds");
    }
}
