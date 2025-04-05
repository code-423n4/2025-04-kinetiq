// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import "forge-std/StdJson.sol";
import "../src/validators/ValidatorSanityChecker.sol";
import "../src/OracleManager.sol";

contract DeploySanityChecker is Script {
    using stdJson for string;

    // Contract instances
    ValidatorSanityChecker public sanityChecker;
    OracleManager public oracleManager;

    // Config content
    string public config;
    string public configPath;

    function run(string memory _configPath) external {
        // Store config path
        configPath = _configPath;

        // Load configuration
        config = vm.readFile(configPath);

        // Deploy and configure sanity checker
        vm.startBroadcast();
        _deploySanityChecker();
        _configureSanityChecker();
        _setOracleManagerSanityChecker();
        vm.stopBroadcast();

        // Log deployments
        _logDeployments();
    }

    function _deploySanityChecker() private {
        // Get ValidatorManager address from config or deployed contracts
        address validatorManagerAddress = config.readAddress(".deployed.validatorManagerProxy");
        require(validatorManagerAddress != address(0), "ValidatorManager address not found");

        // Deploy ValidatorSanityChecker
        sanityChecker = new ValidatorSanityChecker(validatorManagerAddress);

        // Write the address to the config file
        vm.writeJson(vm.toString(address(sanityChecker)), configPath, ".deployed.validatorSanityChecker");
    }

    function _configureSanityChecker() private {
        // Set slashing tolerance (0.01% - 1 basis point)
        sanityChecker.setSlashingTolerance(1);

        // Set rewards tolerance (0.01% - 1 basis point)
        sanityChecker.setRewardsTolerance(1);

        // Set score tolerance (10% - 1000 basis points)
        sanityChecker.setScoreTolerance(1000);
    }

    function _setOracleManagerSanityChecker() private {
        // Get OracleManager address from config
        address oracleManagerAddress = config.readAddress(".deployed.oracleManagerProxy");

        if (oracleManagerAddress != address(0)) {
            // Connect to OracleManager
            oracleManager = OracleManager(oracleManagerAddress);

            // Set the sanity checker in OracleManager
            oracleManager.setSanityChecker(address(sanityChecker));
        } else {
            console.log("OracleManager address not found. Please set sanity checker manually.");
        }
    }

    function _logDeployments() private view {
        console.log("\n=== ValidatorSanityChecker Deployment ===");
        console.log("ValidatorSanityChecker:", address(sanityChecker));

        console.log("\n=== Tolerance Settings ===");
        console.log("Slashing Tolerance:", sanityChecker.slashingTolerance(), "basis points");
        console.log("Rewards Tolerance:", sanityChecker.rewardsTolerance(), "basis points");
        console.log("Score Tolerance:", sanityChecker.scoreTolerance(), "basis points");

        console.log("\n=== Connected Contracts ===");
        console.log("ValidatorManager:", address(sanityChecker.validatorManager()));

        if (address(oracleManager) != address(0)) {
            console.log("OracleManager:", address(oracleManager));
            console.log("OracleManager SanityChecker:", address(oracleManager.sanityChecker()));
        }
    }
}
