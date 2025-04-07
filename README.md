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
2. The `generatePerformance` function is a sanity check and is unrelated to rewards or funds, we understand it has complex logic but would encourage auditors not to spend too much time on this function


# Overview


Kinetiq is a Liquid Staking protocol building on Hyperliquid. It allows users to stake their HYPE tokens and receive kHYPE tokens in return, enabling them to participate in network security while maintaining liquidity.

## Features

### Core Features
- Deposit HYPE tokens to mint and receive kHYPE tokens
- Liquid staking allows users to utilize their staked assets
- Oracle-based performance tracking and reward distribution
- Upgradeable smart contracts
- Role-based access control

### Advanced Features
- Sophisticated validator management system
- Performance-based stake allocation
- Emergency withdrawal system with queue management
- Historical performance tracking
- Gas-optimized rebalancing mechanism

## Smart Contracts

1. **StakingManager**: 
   - Manages staking and unstaking of HYPE tokens
   - Implements HYPE buffer concept
   - Handles withdrawal queuing and processing
   - Manages validator delegation

2. **StakingAccountant**:
   - Tracks total staked HYPE across all staking managers
   - Tracks total claimed HYPE
   - Calculates the exchange ratio between HYPE and kHYPE tokens
   - Manages multiple kHYPE tokens for different staking managers
   - Provides conversion functions between HYPE and kHYPE
   - Tracks unique kHYPE tokens to avoid double-counting

2. **KHYPE**: 
   - ERC20 token representing Kinetiq staked HYPE
   - Implements ERC20Permit for gasless approvals
   - Role-based minting and burning

3. **ValidatorManager**: 
   - Performance tracking (uptime, speed, integrity, self-stake)
   - Performance-based stake allocation
   - Emergency withdrawal system
   - Rebalancing mechanism
   - Slashing protection

4. **OracleManager**: 
   - Manages oracle adapters
   - Aggregates performance data
   - Validates and processes updates
   - Handles rewards and slashing events

5. **PauserRegistry**: 
   - Manages contract pause states
   - Role-based pause control
   - Emergency pause functionality

## Key Mechanisms

### Validator Management
- Score-based stake allocation using Stakehub metrics
- Dynamic rebalancing with gas optimization
- Performance history tracking
- Emergency withdrawal system with cooldown periods
- Slashing protection mechanism

### Oracle System
- External data feeds for critical parameters
- Challenge period for updates
- Data integrity validation
- Multiple source aggregation

### Security Features
- Emergency withdrawal system
- Flexible pausing mechanism
- Slashing protection
- Performance monitoring
- Stake limits and rebalancing thresholds

## Links

- **Previous audits:**
  * [Zenith Audit report](https://github.com/code-423n4/2025-04-kinetiq/blob/main/audits/kinetiq-zenith.pdf)
  * [Pashov Audit Group](https://github.com/code-423n4/2025-04-kinetiq/blob/main/audits/kinetiq-pashov.pdf)
- **Documentation:** https://github.com/code-423n4/2025-04-kinetiq/tree/main/docs
- **Website:** https://kinetiq.xyz/
- **X/Twitter:** https://x.com/kinetiq_xyz

---

# Scope


### Files in scope

*See [scope.txt](https://github.com/code-423n4/2025-04-kinetiq/blob/main/scope.txt)*

| File                            | Logic Contracts | Interfaces | nSLOC    |
|---------------------------------|-----------------|------------|----------|
| /src/oracles/DefaultAdapter.sol | 1               | 1          | 24       |
| /src/oracles/DefaultOracle.sol  | 1               | ****       | 77       |
| /src/oracles/IOracleAdapter.sol | ****            | 1          | 4        |
| /src/KHYPE.sol                  | 1               | ****       | 43       |
| /src/OracleManager.sol          | 1               | ****       | 212      |
| /src/PauserRegistry.sol         | 1               | ****       | 75       |
| /src/StakingAccountant.sol      | 1               | ****       | 120      |
| /src/StakingManager.sol         | 1               | ****       | 543      |
| /src/ValidatorManager.sol       | 1               | ****       | 234      |
| **Totals**                      | **8**           | **2**      | **1332** |


### Files out of scope

*See [out_of_scope.txt](https://github.com/code-423n4/2025-04-kinetiq/blob/main/out_of_scope.txt)*


## Scoping Q &amp; A

### General questions



| Question                                | Answer                       |
| --------------------------------------- | ---------------------------- |
| ERC20 used by the protocol              |       HYPE on Hyperliquid EVM             |
| Test coverage                           | 52% (495/952 statements)              |
| ERC721 used  by the protocol            |            None              |
| ERC777 used by the protocol             |           None                |
| ERC1155 used by the protocol            |              None            |
| Chains the protocol will be deployed on | Hyperliquid EVM  |

### External integrations (e.g., Uniswap) behavior in scope:


| Question                                                  | Answer |
| --------------------------------------------------------- | ------ |
| Enabling/disabling fees (e.g. Blur disables/enables fees) | Yes    |
| Pausability (e.g. Uniswap pool gets paused)               | Yes    |
| Upgradeability (e.g. Uniswap gets upgraded)               | Yes    |


### EIP compliance checklist
n/a



# Additional context

## Main invariants
As a liquid staking protocol, our primary invariant is that 1 kHYPE === 1 HYPE


## Attack ideas (where to focus for bugs)
future upgradeability as hyperliquid is known to change things quickly and without notice, recovery from a compromised contract

we also have some off chain components that help maintain protocol


## All trusted roles in the protocol

Roles hierarchy:
```
DEFAULT_ADMIN_ROLE
├── StakingManager
│   ├── OPERATOR_ROLE
│   ├── MANAGER_ROLE
│   ├── TREASURY_ROLE
│   └── SENTINEL_ROLE
├── ValidatorManager
│   ├── MANAGER_ROLE
│   └── ORACLE_MANAGER_ROLE(contract)
├── OracleManager
│   ├── MANAGER_ROLE
│   └── OPERATOR_ROLE
├── StakingAccountant
│   └── MANAGER_ROLE
├── KHYPE Token
│   ├── MINTER_ROLE(contract)
│   └── BURNER_ROLE(contract)
└── PauserRegistry
    ├── PAUSER_ROLE
    ├── UNPAUSER_ROLE
    └── PAUSE_ALL_ROLE
```

1) Admin Trust: The DEFAULT_ADMIN_ROLE has full control over the protocol and must be a highly trusted entity, ideally a multi-sig or governance contract.
2) Operational Trust:
    * OPERATOR_ROLE: Must reliably execute L1 operations and manage the operation queue
    * MANAGER_ROLE: Has significant control over protocol parameters across multiple contracts
    * ORACLE_MANAGER_ROLE: Controls the flow of external data into the protocol
3) Emergency Controls:
    * SENTINEL_ROLE: Likely has emergency powers to protect the protocol
    * PAUSER_ROLE/PAUSE_ALL_ROLE: Can halt protocol operations in emergencies
4) Financial Trust:
    * TREASURY_ROLE: Receives protocol revenues
    * MINTER_ROLE/BURNER_ROLE: Controls token supply 

## Describe any novel or unique curve logic or mathematical models implemented in the contracts:

See [StakingAccountant.sol#L194-L222](https://github.com/code-423n4/2025-04-kinetiq/blob/main/src/StakingAccountant.sol#L194-L222)


## Running tests



```bash
git clone https://github.com/code-423n4/2025-04-kinetiq.git
cd 2025-04-kinetiq

foundryup
forge test

# get coverage
forge coverage
```

Coverage:
| File                                        | % Lines           | % Statements      | % Branches      | % Funcs         |
|---------------------------------|-----------------|------------|----------| ---- |
| src/KHYPE.sol                               | 84.62% (22/26)    | 80.00% (16/20)    | 10.00% (1/10)   | 85.71% (6/7)    |
| src/OracleManager.sol                       | 79.37% (100/126)  | 79.85% (107/134)  | 12.50% (5/40)   | 76.47% (13/17)  |
| src/PauserRegistry.sol                      | 95.92% (47/49)    | 95.83% (46/48)    | 4.35% (1/23)    | 100.00% (10/10) |
| src/StakingAccountant.sol                   | 79.22% (61/77)    | 82.14% (69/84)    | 11.11% (3/27)   | 72.22% (13/18)  |
| src/StakingManager.sol                      | 44.24% (165/373)  | 44.65% (171/383)  | 10.86% (19/175) | 42.55% (20/47)  |
| src/ValidatorManager.sol                    | 76.74% (99/129)   | 76.58% (85/111)   | 6.06% (4/66)    | 80.00% (20/25)  |
| src/lib/L1Read.sol                          | 0.00% (0/60)      | 0.00% (0/60)      | 0.00% (0/20)    | 0.00% (0/10)    |
| src/lib/L1Write.sol                         | 14.29% (2/14)     | 14.29% (1/7)      | 100.00% (0/0)   | 14.29% (1/7)    |
| src/lib/MinimalImplementation.sol           | 0.00% (0/1)       | 100.00% (0/0)     | 100.00% (0/0)   | 0.00% (0/1)     |
| src/lib/SystemOracle.sol                    | 0.00% (0/13)      | 0.00% (0/8)       | 0.00% (0/2)     | 0.00% (0/5)     |
| src/oracles/DefaultAdapter.sol              | 0.00% (0/11)      | 0.00% (0/8)       | 0.00% (0/2)     | 0.00% (0/5)     |
| src/oracles/DefaultOracle.sol               | 0.00% (0/23)      | 0.00% (0/20)      | 0.00% (0/16)    | 0.00% (0/5)     |
| src/validators/ValidatorSanityChecker.sol   | 0.00% (0/65)      | 0.00% (0/69)      | 0.00% (0/31)    | 0.00% (0/6)     |



### Deploy
```bash
# Deploy core contracts
forge script script/DeployCore.s.sol \
  --sig "run(string)" config/testnet.json \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify
```

### Integration Tasks

#### User Operations
```bash
# Stake HYPE
task deposit AMOUNT=1000000000000000000

# Queue withdrawal
task queue-withdrawal AMOUNT=1000000000000000000

# Confirm withdrawal
task confirm-withdrawal WITHDRAWAL_ID=0

# Cancel withdrawal
task cancel-withdrawal WITHDRAWAL_ID=0
```

#### Operator Operations
```bash
# Generate performance update
task generate-performance

# Set performance bound
task set-performance-bound BOUND=10000
```

#### Manager Operations
```bash
# Validator management
task activate-validator VALIDATOR=0x...
task deactivate-validator VALIDATOR=0x...
task set-delegation VALIDATOR=0x...

# Rebalancing
task rebalance-withdrawal VALIDATORS="[0x...]" AMOUNTS="[1000000000000000000]"
task close-rebalance VALIDATORS="[0x...]"
```

## Project Structure

```
├── src/                # Smart contracts
│   ├── interfaces/     # Contract interfaces
│   ├── mocks/         # Mock contracts for testing
│   └── oracles/       # Oracle adapters
├── script/            # Deployment and task scripts
│   ├── tasks/        # Integration task scripts
│   └── Config.sol    # Configuration handling
├── test/             # Test files
└── config/           # Deployment configurations
```

## Miscellaneous
Employees of Kinetiq and employees' family members are ineligible to participate in this audit.

Code4rena's rules cannot be overridden by the contents of this README. In case of doubt, please check with C4 staff.
