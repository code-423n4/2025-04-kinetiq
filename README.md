

# Scope

*See [scope.txt](https://github.com/code-423n4/2025-04-kinetiq/blob/main/scope.txt)*

### Files in scope


| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /src/KHYPE.sol | 1| **** | 43 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol|
| /src/OracleManager.sol | 1| **** | 212 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol<br>@openzeppelin/contracts/utils/math/Math.sol|
| /src/PauserRegistry.sol | 1| **** | 75 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol|
| /src/StakingAccountant.sol | 1| **** | 120 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/utils/math/Math.sol<br>@openzeppelin/contracts/utils/structs/EnumerableMap.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol|
| /src/StakingManager.sol | 1| **** | 543 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/utils/math/Math.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol|
| /src/ValidatorManager.sol | 1| **** | 234 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/utils/structs/EnumerableMap.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol|
| /src/oracles/DefaultAdapter.sol | 1| 1 | 24 | |@openzeppelin/contracts/utils/introspection/IERC165.sol|
| /src/oracles/DefaultOracle.sol | 1| **** | 77 | |@openzeppelin/contracts/access/AccessControl.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol|
| /src/oracles/IOracleAdapter.sol | ****| 1 | 4 | |@openzeppelin/contracts/utils/introspection/IERC165.sol|
| **Totals** | **8** | **2** | **1332** | | |

### Files out of scope

*See [out_of_scope.txt](https://github.com/code-423n4/2025-04-kinetiq/blob/main/out_of_scope.txt)*

| File         |
| ------------ |
| ./script/DeployCore.s.sol |
| ./script/DeployMockOracle.s.sol |
| ./script/DeployOracle.s.sol |
| ./script/DeployOracleAdapter.s.sol |
| ./script/DeploySanityChecker.s.sol |
| ./script/ManageRoles.s.sol |
| ./script/tasks/ManagerOracle.s.sol |
| ./script/tasks/ManagerRebalance.s.sol |
| ./script/tasks/ManagerStakingAccountant.s.sol |
| ./script/tasks/ManagerValidator.s.sol |
| ./script/tasks/ManagerWhitelist.s.sol |
| ./script/tasks/OperatorOracle.s.sol |
| ./script/tasks/OperatorPerformance.s.sol |
| ./script/tasks/OperatorStaking.s.sol |
| ./script/tasks/TreasuryOperations.s.sol |
| ./script/tasks/UserDeposit.s.sol |
| ./script/tasks/UserWithdraw.s.sol |
| ./src/interfaces/IKHYPE.sol |
| ./src/interfaces/IOracleManager.sol |
| ./src/interfaces/IPauserRegistry.sol |
| ./src/interfaces/IStakingAccountant.sol |
| ./src/interfaces/IStakingManager.sol |
| ./src/interfaces/IValidatorManager.sol |
| ./src/lib/L1Read.sol |
| ./src/lib/L1Write.sol |
| ./src/lib/MinimalImplementation.sol |
| ./src/lib/SystemOracle.sol |
| ./src/mocks/MockDefaultOracle.sol |
| ./src/validators/IValidatorSanityChecker.sol |
| ./src/validators/ValidatorSanityChecker.sol |
| ./test/Base.t.sol |
| ./test/KHYPE.t.sol |
| ./test/OracleManager.t.sol |
| ./test/PauserRegistry.t.sol |
| ./test/StakingAccountant.t.sol |
| ./test/StakingManager.t.sol |
| ./test/ValidatorManager.t.sol |
| Totals: 37 |

