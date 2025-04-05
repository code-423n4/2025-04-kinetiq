// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/StakingManager.sol";
import "../../src/KHYPE.sol";

contract UserDepositScript is Script {
    using stdJson for string;

    StakingManager public stakingManager;
    KHYPE public kHYPE;

    function run(string memory configFile, uint256 amount) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load deployed contract addresses
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));
        kHYPE = KHYPE(json.readAddress(".deployed.KHYPE"));

        // Execute stake
        vm.startBroadcast();
        stakingManager.stake{value: amount}();
        console.log("Staked:", amount);
        console.log("kHYPE Balance:", kHYPE.balanceOf(msg.sender));
        vm.stopBroadcast();
    }
}
