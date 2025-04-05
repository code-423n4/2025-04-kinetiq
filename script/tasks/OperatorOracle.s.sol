// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/oracles/DefaultOracle.sol";

contract OperatorOracleScript is Script {
    using stdJson for string;

    DefaultOracle public oracle;

    function updateMetrics(
        address validator,
        uint256 balance,
        uint256 uptime,
        uint256 speed,
        uint256 integrity,
        uint256 stake,
        uint256 reward,
        uint256 slashing
    ) external {
        string memory json = vm.readFile("script/testnet.json");
        oracle = DefaultOracle(json.readAddress(".deployed.DefaultOracle"));

        vm.startBroadcast();
        oracle.updateValidatorMetrics(validator, balance, uptime, speed, integrity, stake, reward, slashing);
        vm.stopBroadcast();

        console.log("Updated metrics for validator:", validator);
        console.log("Balance:", balance);
        console.log("Uptime:", uptime);
        console.log("Speed:", speed);
        console.log("Integrity:", integrity);
        console.log("Stake:", stake);
        console.log("Reward:", reward);
        console.log("Slashing:", slashing);
    }
}
