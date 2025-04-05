// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../../src/StakingManager.sol";
import "../../src/KHYPE.sol";

contract UserWithdrawScript is Script {
    using stdJson for string;

    StakingManager public stakingManager;
    KHYPE public kHYPE;

    function queueWithdrawal(string memory configFile, uint256 amount) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load contracts
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));
        kHYPE = KHYPE(json.readAddress(".deployed.KHYPE"));

        // Queue withdrawal
        vm.startBroadcast();
        kHYPE.approve(address(stakingManager), amount);
        stakingManager.queueWithdrawal(amount);
        console.log("Withdrawal queued:", amount);
        vm.stopBroadcast();
    }

    function confirmWithdrawal(string memory configFile, uint256 withdrawalId) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load contract
        stakingManager = StakingManager(payable(json.readAddress(".deployed.StakingManager")));

        // Confirm withdrawal
        vm.startBroadcast();
        stakingManager.confirmWithdrawal(withdrawalId);
        console.log("Withdrawal confirmed for ID:", withdrawalId);
        vm.stopBroadcast();
    }
}
