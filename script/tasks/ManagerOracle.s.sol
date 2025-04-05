// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/OracleManager.sol";

contract ManagerOracleScript is Script {
    using stdJson for string;

    OracleManager public oracleManager;

    function authorizeAdapter(string memory configFile, address adapter) external {
        string memory json = vm.readFile(configFile);
        oracleManager = OracleManager(json.readAddress(".deployed.OracleManager"));

        vm.startBroadcast();
        oracleManager.authorizeOracleAdapter(adapter);
        vm.stopBroadcast();

        console.log("Authorized oracle adapter:", adapter);
    }

    function deauthorizeOracle(string memory configFile, address adapter) external {
        string memory json = vm.readFile(configFile);
        oracleManager = OracleManager(json.readAddress(".deployed.OracleManager"));

        vm.startBroadcast();
        oracleManager.deauthorizeOracle(adapter);
        vm.stopBroadcast();

        console.log("Deauthorized oracle adapter:", adapter);
    }

    function setOracleActive(string memory configFile, address adapter, bool active) external {
        string memory json = vm.readFile(configFile);
        oracleManager = OracleManager(json.readAddress(".deployed.OracleManager"));

        vm.startBroadcast();
        oracleManager.setOracleActive(adapter, active);
        vm.stopBroadcast();

        console.log("Set oracle adapter active state:", adapter, active);
    }
}
