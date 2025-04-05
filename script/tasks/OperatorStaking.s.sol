// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {stdJson} from "forge-std/StdJson.sol";

import "../../src/StakingManager.sol";
import "../../src/ValidatorManager.sol";
import "../../src/interfaces/IStakingManager.sol";

contract OperatorStakingScript is Script {
    using stdJson for string;

    StakingManager public stakingManager;
    ValidatorManager public validatorManager;

    /**
     * @notice Queue L1 operations for retry
     * @param configFile Path to the config file
     * @param validators Array of validator addresses
     * @param amounts Array of amounts
     * @param operationTypes Array of operation types (0=UserDeposit, 1=UserWithdrawal, 2=RebalanceDeposit, 3=RebalanceWithdrawal)
     */
    function queueL1Operations(
        string memory configFile,
        address[] memory validators,
        uint256[] memory amounts,
        uint8[] memory operationTypes
    ) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load deployed contract addresses
        address stakingManagerAddr = json.readAddress(".deployed.StakingManager");
        stakingManager = StakingManager(payable(stakingManagerAddr));

        // Validate input arrays
        require(validators.length == amounts.length, "Array length mismatch");
        require(validators.length == operationTypes.length, "Array length mismatch");

        // Convert uint8[] to OperationType[]
        IStakingManager.OperationType[] memory types = new IStakingManager.OperationType[](operationTypes.length);
        for (uint256 i = 0; i < operationTypes.length; i++) {
            types[i] = IStakingManager.OperationType(operationTypes[i]);
        }

        vm.startBroadcast();
        stakingManager.queueL1Operations(validators, amounts, types);
        vm.stopBroadcast();

        console.log("Queued %d L1 operations", validators.length);
        for (uint256 i = 0; i < validators.length; i++) {
            console.log("Validator: %s, Amount: %d, Type: %d", validators[i], amounts[i], operationTypes[i]);
        }
    }

    /**
     * @notice Process a batch of pending L1 operations
     * @param configFile Path to the config file
     * @param batchSize Number of operations to process in this batch
     */
    function processL1Operations(string memory configFile, uint256 batchSize) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load deployed contract addresses
        address stakingManagerAddr = json.readAddress(".deployed.StakingManager");
        stakingManager = StakingManager(payable(stakingManagerAddr));

        vm.startBroadcast();
        stakingManager.processL1Operations(batchSize);
        vm.stopBroadcast();

        console.log("Processed %d L1 operations");
    }

    /**
     * @notice Process all pending L1 operations
     * @param configFile Path to the config file
     */
    function processAllL1Operations(string memory configFile) external {
        // Load config
        string memory json = vm.readFile(configFile);

        // Load deployed contract addresses
        address stakingManagerAddr = json.readAddress(".deployed.StakingManager");
        stakingManager = StakingManager(payable(stakingManagerAddr));

        vm.startBroadcast();
        stakingManager.processL1Operations(); // Call without batch size to process all
        vm.stopBroadcast();

        console.log("Processed all pending L1 operations");
    }
}
