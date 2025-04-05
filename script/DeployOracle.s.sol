// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {DefaultOracle} from "../src/oracles/DefaultOracle.sol";
import {OracleAdapter} from "../src/oracles/DefaultAdapter.sol";

contract DeployOracleScript is Script {
    using stdJson for string;

    DefaultOracle public oracle;

    function run(string memory configJson) external {
        // Load config
        string memory json = vm.readFile(configJson);
        address admin = json.readAddress(".roles.admin");
        address operator = json.readAddress(".roles.oracleOperator");

        console.log("\nDeploying Oracle contracts...");
        console.log("====================");
        console.log("Admin:", admin);
        console.log("Operator:", operator);
        console.log("====================\n");

        vm.startBroadcast();

        // Deploy contracts
        oracle = new DefaultOracle(admin, operator);

        vm.stopBroadcast();

        _logDeployments();
    }

    function _logDeployments() private view {
        console.log("\n=== Oracle Deployments ===");
        console.log("DefaultOracle:", address(oracle));
    }
}
