// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/ValidatorManager.sol";

contract ManagerRebalanceScript is Script {
    using stdJson for string;

    ValidatorManager public validatorManager;

    function rebalanceWithdrawal(
        string memory configFile,
        address[] calldata validators,
        uint256[] calldata amounts
    ) external {
        string memory json = vm.readFile(configFile);
        validatorManager = ValidatorManager(json.readAddress(".deployed.ValidatorManager"));
        address stakingManager = json.readAddress(".deployed.StakingManager");

        vm.startBroadcast();
        validatorManager.rebalanceWithdrawal(stakingManager, validators, amounts);
        vm.stopBroadcast();

        console.log("Rebalance initiated for", validators.length, "validators");
        for (uint256 i = 0; i < validators.length; i++) {
            console.log("Validator:", validators[i]);
            console.log("Amount:", amounts[i]);
        }
    }

    function closeRebalanceRequests(string memory configFile, address[] calldata validators) external {
        string memory json = vm.readFile(configFile);
        validatorManager = ValidatorManager(json.readAddress(".deployed.ValidatorManager"));
        address stakingManager = json.readAddress(".deployed.StakingManager");

        vm.startBroadcast();
        validatorManager.closeRebalanceRequests(stakingManager, validators);
        vm.stopBroadcast();

        console.log("Closed rebalance requests for", validators.length, "validators");
    }
}
