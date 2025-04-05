// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "../src/StakingManager.sol";
import "../src/ValidatorManager.sol";
import "../src/OracleManager.sol";

contract ManageRolesScript is Script {
    using stdJson for string;

    function run(string memory configPath) external {
        string memory config = vm.readFile(configPath);
        // address admin = config.readAddress(".addresses.admin");

        vm.startBroadcast();

        // Get contract instances
        StakingManager stakingManager = StakingManager(payable(config.readAddress(".deployed.stakingManagerProxy")));
        ValidatorManager validatorManager = ValidatorManager(config.readAddress(".deployed.validatorManagerProxy"));
        OracleManager oracleManager = OracleManager(config.readAddress(".deployed.oracleManagerProxy"));

        // Grant roles for StakingManager
        bytes32 STAKING_OPERATOR_ROLE = stakingManager.OPERATOR_ROLE();
        bytes32 STAKING_MANAGER_ROLE = stakingManager.MANAGER_ROLE();

        stakingManager.grantRole(STAKING_OPERATOR_ROLE, config.readAddress(".addresses.operator"));
        stakingManager.grantRole(STAKING_MANAGER_ROLE, config.readAddress(".addresses.manager"));

        // Grant roles for ValidatorManager
        bytes32 VALIDATOR_MANAGER_ROLE = validatorManager.MANAGER_ROLE();
        bytes32 VALIDATOR_ORACLE_ROLE = validatorManager.ORACLE_MANAGER_ROLE();

        validatorManager.grantRole(VALIDATOR_MANAGER_ROLE, config.readAddress(".addresses.validatorManager"));
        validatorManager.grantRole(VALIDATOR_ORACLE_ROLE, config.readAddress(".addresses.oracleManager"));

        // Grant roles for OracleManager
        bytes32 ORACLE_MANAGER_ROLE = oracleManager.MANAGER_ROLE();
        bytes32 ORACLE_OPERATOR_ROLE = oracleManager.OPERATOR_ROLE();

        oracleManager.grantRole(ORACLE_MANAGER_ROLE, config.readAddress(".addresses.oracleManager"));
        oracleManager.grantRole(ORACLE_OPERATOR_ROLE, config.readAddress(".addresses.oracleOperator"));

        vm.stopBroadcast();
    }
}
