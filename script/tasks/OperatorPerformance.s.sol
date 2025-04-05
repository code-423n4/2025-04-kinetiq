// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/OracleManager.sol";
import "../../src/validators/ValidatorSanityChecker.sol";

contract OperatorPerformanceScript is Script {
    using stdJson for string;

    OracleManager public oracleManager;
    ValidatorSanityChecker public sanityChecker;

    function generatePerformance(string memory configFile, address validator) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load deployed contract addresses
        address oracleManagerAddr = json.readAddress(".deployed.OracleManager");
        oracleManager = OracleManager(oracleManagerAddr);

        vm.startBroadcast();
        bool success = oracleManager.generatePerformance(validator);
        vm.stopBroadcast();

        console.log("Performance update success:", success);
        console.log("Validator:", validator);
    }

    // Add a helper function to generate performance for multiple validators
    function generatePerformanceForAll(string memory configFile, address[] calldata validators) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load deployed contract addresses
        address oracleManagerAddr = json.readAddress(".deployed.OracleManager");
        oracleManager = OracleManager(oracleManagerAddr);

        vm.startBroadcast();
        for (uint256 i = 0; i < validators.length; i++) {
            bool success = oracleManager.generatePerformance(validators[i]);
            console.log("Performance update for validator", validators[i], ":", success);
        }
        vm.stopBroadcast();
    }

    function setMaxPerformanceBound(string memory configFile, uint256 newBound) external {
        string memory json = vm.readFile(configFile);
        oracleManager = OracleManager(json.readAddress(".deployed.OracleManager"));

        vm.startBroadcast();
        oracleManager.setMaxPerformanceBound(newBound);
        vm.stopBroadcast();

        console.log("Set max performance bound to:", newBound);
    }

    // Replace the OracleManager tolerance functions with ValidatorSanityChecker functions
    function setSlashingTolerance(string memory configFile, uint256 newTolerance) external {
        string memory json = vm.readFile(configFile);
        sanityChecker = ValidatorSanityChecker(json.readAddress(".deployed.validatorSanityChecker"));

        vm.startBroadcast();
        sanityChecker.setSlashingTolerance(newTolerance);
        vm.stopBroadcast();

        console.log("Set slashing tolerance to:", newTolerance, "basis points");
    }

    function setRewardsTolerance(string memory configFile, uint256 newTolerance) external {
        string memory json = vm.readFile(configFile);
        sanityChecker = ValidatorSanityChecker(json.readAddress(".deployed.validatorSanityChecker"));

        vm.startBroadcast();
        sanityChecker.setRewardsTolerance(newTolerance);
        vm.stopBroadcast();

        console.log("Set rewards tolerance to:", newTolerance, "basis points");
    }

    function setScoreTolerance(string memory configFile, uint256 newTolerance) external {
        string memory json = vm.readFile(configFile);
        sanityChecker = ValidatorSanityChecker(json.readAddress(".deployed.validatorSanityChecker"));

        vm.startBroadcast();
        sanityChecker.setScoreTolerance(newTolerance);
        vm.stopBroadcast();

        console.log("Set score tolerance to:", newTolerance, "basis points");
    }

    function setMinUpdateInterval(string memory configFile, uint256 newInterval) external {
        string memory json = vm.readFile(configFile);
        oracleManager = OracleManager(json.readAddress(".deployed.OracleManager"));

        vm.startBroadcast();
        oracleManager.setMinUpdateInterval(newInterval);
        vm.stopBroadcast();

        console.log("Set minimum update interval to:", newInterval, "seconds");
    }

    function setMaxOracleStaleness(string memory configFile, uint256 newStaleness) external {
        string memory json = vm.readFile(configFile);
        oracleManager = OracleManager(json.readAddress(".deployed.OracleManager"));

        vm.startBroadcast();
        oracleManager.setMaxOracleStaleness(newStaleness);
        vm.stopBroadcast();

        console.log("Set maximum oracle staleness to:", newStaleness, "seconds");
    }

    function setSanityChecker(string memory configFile, address newChecker) external {
        string memory json = vm.readFile(configFile);
        oracleManager = OracleManager(json.readAddress(".deployed.OracleManager"));

        vm.startBroadcast();
        oracleManager.setSanityChecker(newChecker);
        vm.stopBroadcast();

        console.log("Set sanity checker to:", newChecker);
    }
}
