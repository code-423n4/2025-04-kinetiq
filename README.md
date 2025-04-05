# Kinetiq audit details
- Total Prize Pool: $35,000 in USDC
  - HM awards: up to $28,500 USDC
    - If no valid Highs or Mediums are found, the HM pool is $0 
  - QA awards: $1,200 in USDC
  - Judge awards: $2,900 in USDC
  - Validator awards: $1,900 in USDC
  - Scout awards: $500 in USDC
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts April 7, 2025 20:00 UTC
- Ends April 16, 2025 20:00 UTC

**Note re: risk level upgrades/downgrades**

Two important notes about judging phase risk adjustments: 
- High- or Medium-risk submissions downgraded to Low-risk (QA) will be ineligible for awards.
- Upgrading a Low-risk finding from a QA report to a Medium- or High-risk finding is not supported.

As such, wardens are encouraged to select the appropriate risk level carefully during the submission phase.

## Automated Findings / Publicly Known Issues

_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

The 4naly3er report can be found [here](https://github.com/code-423n4/2025-04-kinetiq/blob/main/4naly3er-report.md).

1. Some of the sanity checks and rules around the validator slashing mechanisms are assumptions based upon our current understanding
1. The `generatePerformance` function is a sanity check and is unrelated to rewards or funds, we understand it has complex logic but would encourage auditors not to spend too much time on this function

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

# Overview

[ ⭐️ SPONSORS: add info here ]

## Links

- **Previous audits:**  [Zenith Audit report](https://github.com/code-423n4/2025-04-kinetiq/blob/main/audits/kinetiq-zenith.pdf), [Pashov Audit Group](https://github.com/code-423n4/2025-04-kinetiq/blob/main/audits/kinetiq-pashov.pdf)
- **Documentation:** https://github.com/code-423n4/2025-04-kinetiq/tree/main/docs
- **Website:** https://kinetiq.xyz/
- **X/Twitter:** https://x.com/kinetiq_xyz

---

# Scope

[ ✅ SCOUTS: add scoping and technical details here ]

### Files in scope
- ✅ This should be completed using the `metrics.md` file
- ✅ Last row of the table should be Total: SLOC
- ✅ SCOUTS: Have the sponsor review and and confirm in text the details in the section titled "Scoping Q amp; A"

*See [scope.txt](https://github.com/code-423n4/2025-04-kinetiq/blob/main/scope.txt)*

| File   | Logic Contracts | Interfaces | nSLOC | Purpose | Libraries used |
| ------ | --------------- | ---------- | ----- | -----   | ------------ |
| /src/oracles/DefaultAdapter.sol | 1| 1 | 24 | |@openzeppelin/contracts/utils/introspection/IERC165.sol|
| /src/oracles/DefaultOracle.sol | 1| **** | 77 | |@openzeppelin/contracts/access/AccessControl.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol|
| /src/oracles/IOracleAdapter.sol | ****| 1 | 4 | |@openzeppelin/contracts/utils/introspection/IERC165.sol|
| /src/KHYPE.sol | 1| **** | 43 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol|
| /src/OracleManager.sol | 1| **** | 212 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol<br>@openzeppelin/contracts/utils/math/Math.sol|
| /src/PauserRegistry.sol | 1| **** | 75 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol|
| /src/StakingAccountant.sol | 1| **** | 120 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/utils/math/Math.sol<br>@openzeppelin/contracts/utils/structs/EnumerableMap.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol|
| /src/StakingManager.sol | 1| **** | 543 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol<br>@openzeppelin/contracts/token/ERC20/IERC20.sol<br>@openzeppelin/contracts/utils/math/Math.sol<br>@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol|
| /src/ValidatorManager.sol | 1| **** | 234 | |@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol<br>@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol<br>@openzeppelin/contracts/utils/structs/EnumerableMap.sol<br>@openzeppelin/contracts/utils/structs/EnumerableSet.sol|
| **Totals** | **8** | **2** | **1332** | | |


### Files out of scope
✅ SCOUTS: List files/directories out of scope

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

## Scoping Q &amp; A

### General questions
### Are there any ERC20's in scope?: Yes

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".

Specific tokens (please specify)
HYPE on Hyperliquid EVM

### Are there any ERC777's in scope?: No

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".



### Are there any ERC721's in scope?: No

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".



### Are there any ERC1155's in scope?: No

✅ SCOUTS: If the answer above 👆 is "Yes", please add the tokens below 👇 to the table. Otherwise, update the column with "None".



✅ SCOUTS: Once done populating the table below, please remove all the Q/A data above.

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |       🖊️             |
| Test coverage                           | ✅ SCOUTS: Please populate this after running the test coverage command                          |
| ERC721 used  by the protocol            |            🖊️              |
| ERC777 used by the protocol             |           🖊️                |
| ERC1155 used by the protocol            |              🖊️            |
| Chains the protocol will be deployed on | OtherHyperliquid EVM  |

### ERC20 token behaviors in scope

| Question                                                                                                                                                   | Answer |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| [Missing return values](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#missing-return-values)                                                      |    |
| [Fee on transfer](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#fee-on-transfer)                                                                  |   |
| [Balance changes outside of transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#balance-modifications-outside-of-transfers-rebasingairdrops) |    |
| [Upgradeability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#upgradable-tokens)                                                                 |    |
| [Flash minting](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#flash-mintable-tokens)                                                              |    |
| [Pausability](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#pausable-tokens)                                                                      |    |
| [Approval race protections](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#approval-race-protections)                                              |    |
| [Revert on approval to zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-approval-to-zero-address)                            |    |
| [Revert on zero value approvals](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-approvals)                                    |    |
| [Revert on zero value transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                    |    |
| [Revert on transfer to the zero address](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-transfer-to-the-zero-address)                    |    |
| [Revert on large approvals and/or transfers](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-large-approvals--transfers)                  |    |
| [Doesn't revert on failure](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#no-revert-on-failure)                                                   |    |
| [Multiple token addresses](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#revert-on-zero-value-transfers)                                          |    |
| [Low decimals ( < 6)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#low-decimals)                                                                 |    |
| [High decimals ( > 18)](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#high-decimals)                                                              |    |
| [Blocklists](https://github.com/d-xo/weird-erc20?tab=readme-ov-file#tokens-with-blocklists)                                                                |    |

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | Yes    |
| Pausability (e.g. Uniswap pool gets paused)               | Yes    |
| Upgradeability (e.g. Uniswap gets upgraded)               | Yes    |


### EIP compliance checklist
n/a

✅ SCOUTS: Please format the response above 👆 using the template below👇

| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| src/Token.sol                           | ERC20, ERC721                |
| src/NFT.sol                             | ERC721                       |


# Additional context

## Main invariants

As a liquid staking protocol, our primary invariant is that 1 kHYPE === 1 HYPE



✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## Attack ideas (where to focus for bugs)
future upgradeability as hyperliquid is known to change things quickly and without notice, recovery from a compromised contract

we also have some off chain components that help maintain protocol

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## All trusted roles in the protocol

Documentation to be provided

✅ SCOUTS: Please format the response above 👆 using the template below👇

| Role                                | Description                       |
| --------------------------------------- | ---------------------------- |
| Owner                          | Has superpowers                |
| Administrator                             | Can change fees                       |

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

https://github.com/kinetiq-research/lst/blob/dev/src/StakingAccountant.sol#L194-L222

✅ SCOUTS: Please format the response above 👆 so its not a wall of text and its readable.

## Running tests

Installation, setup and testing is all thoroughly documented in the README:

https://github.com/kinetiq-research/lst/blob/dev/README.md#development

✅ SCOUTS: Please format the response above 👆 using the template below👇

```bash
git clone https://github.com/code-423n4/2023-08-arbitrum
git submodule update --init --recursive
cd governance
foundryup
make install
make build
make sc-election-test
```
To run code coverage
```bash
make coverage
```
To run gas benchmarks
```bash
make gas
```

✅ SCOUTS: Add a screenshot of your terminal showing the gas report
✅ SCOUTS: Add a screenshot of your terminal showing the test coverage



## Miscellaneous
Employees of Kinetiq and employees' family members are ineligible to participate in this audit.

Code4rena's rules cannot be overridden by the contents of this README. In case of doubt, please check with C4 staff.
