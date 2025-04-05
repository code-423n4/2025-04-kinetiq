// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/mocks/MockDefaultOracle.sol";

contract DeployMockOracleScript is Script {
    MockDefaultOracle public mockOracle;

    function run() external {
        vm.startBroadcast();

        // Deploy mock oracle
        mockOracle = new MockDefaultOracle();

        vm.stopBroadcast();

        _logDeployments();
    }

    function _logDeployments() private view {
        console.log("\n=== Mock Oracle Implementations ===");
        console.log("Mock Oracle:", address(mockOracle));
    }
}
