// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/oracles/DefaultAdapter.sol";

contract DeployOracleAdapterScript is Script {
    // Oracle instances
    OracleAdapter public defaultAdapter;

    function run(address oracleAddress) external {
        require(oracleAddress != address(0), "Invalid oracle address");

        vm.startBroadcast();

        // Deploy Default adapter using provided oracle address
        defaultAdapter = new OracleAdapter(oracleAddress);

        vm.stopBroadcast();

        _logDeployments(oracleAddress);
    }

    function _logDeployments(address oracleAddress) private view {
        console.log("\n=== Oracle Adapter Implementations ===");
        console.log("Oracle Address:", oracleAddress);
        console.log("Oracle Adapter:", address(defaultAdapter));
    }
}
