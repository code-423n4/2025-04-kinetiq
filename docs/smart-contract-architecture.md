# Smart Contract Architecture

## Overview

This document details the smart contract architecture of the Kinetiq protocol, explaining the various components, their interactions, and security considerations.

> **Note:** This documentation reflects the current implementation and will evolve as the Kinetiq protocol and the broader Hyperliquid ecosystem change and upgrade.

## Core Components

The Kinetiq protocol consists of several core smart contract components:

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#252A33', 'primaryTextColor': '#ffffff', 'primaryBorderColor': '#4D5664', 'lineColor': '#88C0D0', 'tertiaryColor': '#2E333F'}}}%%
flowchart TB
    subgraph "Token Layer"
        kHYPE[kHYPE Token]
    end
    
    subgraph "Core Protocol"
        SM[StakingManager]
        VM[ValidatorManager]
        OM[OracleManager]
        SA[StakingAccountant]
    end
    
    subgraph "Access Control"
        PR[PauserRegistry]
    end
    
    subgraph "External Layer"
        L1[L1 Write Interface]
    end
    
    kHYPE <--> SM
    SM <--> VM
    SM <--> SA
    VM <--> OM
    SA <--> VM
    VM <--> L1
    PR --> SM
    PR --> VM
    PR --> OM
    PR --> kHYPE
    
    classDef token fill:#5E81AC,stroke:#4D5664,color:#ECEFF4,stroke-width:2px
    classDef core fill:#81A1C1,stroke:#4D5664,color:#2E333F,stroke-width:2px
    classDef access fill:#B48EAD,stroke:#4D5664,color:#ECEFF4,stroke-width:2px
    classDef external fill:#A3BE8C,stroke:#4D5664,color:#2E333F,stroke-width:2px
    
    class kHYPE token
    class SM,VM,OM,SA core
    class PR access
    class L1 external
    
    %% Style for connections
    linkStyle default stroke:#88C0D0,stroke-width:2px;
```

### StakingManager

The StakingManager is the central component of the protocol:

- Manages deposits and withdrawals of HYPE tokens
- Coordinates with kHYPE token for minting and burning
- Tracks user balances and withdrawal requests
- Manages the buffer for liquidity
- Handles L1 operations queue for deposits and withdrawals
- Enforces staking limits and whitelist if enabled

**Key Functions**:
```solidity
function stake(uint256 amount) external;
function requestWithdrawal(uint256 kHYPEAmount) external returns (uint256 requestId);
function confirmWithdrawal(uint256 requestId) external;
function cancelWithdrawal(uint256 requestId) external;
function queueL1Operations(address[] calldata validators, uint256[] calldata amounts, OperationType[] calldata operationTypes) external;
function executeL1Operations(uint256 count) external;
```

### ValidatorManager

The ValidatorManager handles validator operations:

- Maintains the set of active validators
- Tracks validator balances and performance metrics
- Processes rewards and slashing events
- Manages validator delegation
- Provides validator selection for staking operations
- Handles rebalancing of funds between validators

**Key Functions**:
```solidity
function activateValidator(address validator) external;
function deactivateValidator(address validator) external;
function reportRewardEvent(address validator, uint256 amount) external;
function reportSlashingEvent(address validator, uint256 amount) external;
function setDelegation(address stakingManager, address validator) external;
function rebalanceWithdrawal(address stakingManager, address[] calldata validators, uint256[] calldata withdrawalAmounts) external;
```

### OracleManager

The OracleManager serves as the validator performance reporting mechanism:

- Collects and aggregates validator performance metrics from oracle adapters
- Manages authorized oracle adapters and their active status
- Enforces performance bounds and data freshness requirements
- Performs sanity checks on validator metrics
- Reports validated rewards and slashing events to the ValidatorManager
- Updates validator performance metrics in the ValidatorManager

**Key Functions**:
```solidity
function authorizeOracleAdapter(address adapter) external;
function deauthorizeOracle(address adapter) external;
function setOracleActive(address adapter, bool active) external;
function generatePerformance(address validator) external returns (bool);
function setSanityChecker(address newChecker) external;
function setMinValidOracles(uint256 newMinimum) external;
```

### StakingAccountant

The StakingAccountant manages global accounting and exchange rates:

- Tracks total staked HYPE across all staking managers
- Tracks total claimed HYPE
- Calculates the exchange ratio between HYPE and kHYPE tokens
- Manages multiple kHYPE tokens for different staking managers
- Provides conversion functions between HYPE and kHYPE
- Tracks unique kHYPE tokens to avoid double-counting

**Key Functions**:
```solidity
function authorizeStakingManager(address manager, address kHYPEToken) external;
function deauthorizeStakingManager(address manager) external;
function recordStake(uint256 amount) external;
function recordClaim(uint256 amount) external;
function kHYPEToHYPE(uint256 kHYPEAmount) external view returns (uint256);
function HYPEToKHYPE(uint256 HYPEAmount) external view returns (uint256);
```

### kHYPE Token

The kHYPE token is an ERC-20 token representing staked HYPE:

- Standard ERC-20 functions with permit functionality
- Minted when users stake HYPE
- Burned when users withdraw HYPE
- Pausable via PauserRegistry
- Role-based access control for minting and burning
- Multiple kHYPE tokens can exist for different staking managers

**Key Functions**:
```solidity
function mint(address to, uint256 amount) external;
function burn(address from, uint256 amount) external;
function initialize(string calldata name, string calldata symbol, address admin, address minter, address burner, address _pauserRegistry) external;
```

## Access Control System

The protocol implements a robust access control system:

### PauserRegistry

The PauserRegistry provides emergency pause functionality:

- Maintains a registry of pausable contracts
- Manages pauser and unpauser roles
- Allows pausing and unpausing of registered contracts
- Provides emergency pause-all capability
- Tracks pause states for all registered contracts

**Key Functions**:
```solidity
function pause(address contractAddress) external;
function unpause(address contractAddress) external;
function pauseAll() external;
function unpauseAll() external;
function isPaused(address contractAddress) external view returns (bool);
function authorizeContract(address contractAddress) external;
function deauthorizeContract(address contractAddress) external;
```

## Contract Interactions

### Staking Flow

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#252A33', 'primaryTextColor': '#ffffff', 'primaryBorderColor': '#4D5664', 'lineColor': '#88C0D0', 'tertiaryColor': '#2E333F'}}}%%
sequenceDiagram
    actor User
    participant SM as StakingManager
    participant kHYPE as kHYPE Token
    participant SA as StakingAccountant
    participant VM as ValidatorManager
    participant L1 as L1 Write Interface
    
    User->>SM: stake(amount)
    SM->>SM: handle buffer
    SM->>L1: send HYPE to L1
    SM->>kHYPE: mint(user, kHYPEAmount)
    SM->>SA: recordStake(amount)
    SM->>VM: getDelegation(address(this))
    VM-->>SM: validator
    SM->>SM: queueL1Operation(validator, amount, UserDeposit)
    SM-->>User: staking queued
    
    Note over SM,L1: Later, by operator
    
    SM->>L1: executeL1Operations()
    L1-->>SM: operations executed
    
    %% Style for participants
    activate User
    activate SM
    activate kHYPE
    activate SA
    activate VM
    activate L1
    deactivate User
    deactivate SM
    deactivate kHYPE
    deactivate SA
    deactivate VM
    deactivate L1
```

### Withdrawal Flow

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#252A33', 'primaryTextColor': '#ffffff', 'primaryBorderColor': '#4D5664', 'lineColor': '#88C0D0', 'tertiaryColor': '#2E333F'}}}%%
sequenceDiagram
    actor User
    participant SM as StakingManager
    participant kHYPE as kHYPE Token
    participant SA as StakingAccountant
    participant VM as ValidatorManager
    participant L1 as L1 Write Interface
    
    User->>SM: requestWithdrawal(kHYPEAmount)
    SM->>SA: kHYPEToHYPE(kHYPEAmount)
    SA-->>SM: hypeAmount
    SM->>SM: createWithdrawalRequest(user, kHYPEAmount, hypeAmount)
    SM-->>User: requestId
    
    Note over User,L1: After delay period
    
    User->>SM: confirmWithdrawal(requestId)
    SM->>SM: validateWithdrawalRequest(requestId)
    SM->>VM: getDelegation(address(this))
    VM-->>SM: validator
    SM->>SM: queueL1Operation(validator, amount, UserWithdrawal)
    
    Note over SM,L1: Later, by operator
    
    SM->>L1: executeL1Operations()
    L1-->>SM: operations executed
    SM->>kHYPE: burn(user, kHYPEAmount)
    SM->>SA: recordClaim(hypeAmount)
    SM->>User: Transfer HYPE
    SM-->>User: withdrawal complete
    
    %% Style for participants
    activate User
    activate SM
    activate kHYPE
    activate SA
    activate VM
    activate L1
    deactivate User
    deactivate SM
    deactivate kHYPE
    deactivate SA
    deactivate VM
    deactivate L1
```

### Oracle Reporting Flow

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#252A33', 'primaryTextColor': '#ffffff', 'primaryBorderColor': '#4D5664', 'lineColor': '#88C0D0', 'tertiaryColor': '#2E333F'}}}%%
sequenceDiagram
    actor Operator
    participant OM as OracleManager
    participant OA as Oracle Adapters
    participant SC as SanityChecker
    participant VM as ValidatorManager
    
    Operator->>OM: generatePerformance(validator)
    
    loop For each active oracle adapter
        OM->>OA: getPerformance(validator)
        OA-->>OM: performance metrics
        OM->>OM: validate freshness & bounds
    end
    
    OM->>OM: aggregate metrics
    
    alt SanityChecker configured
        OM->>SC: checkValidatorSanity(metrics)
        SC-->>OM: validation result
    end
    
    alt Validation successful
        OM->>VM: updateValidatorPerformance(metrics)
        OM->>VM: reportRewardEvent(validator, amount)
        OM->>VM: reportSlashingEvent(validator, amount)
        OM-->>Operator: true (success)
    else Validation failed
        OM-->>Operator: false (failure)
    end
    
    %% Style for participants
    activate Operator
    activate OM
    activate OA
    activate SC
    activate VM
    deactivate Operator
    deactivate OM
    deactivate OA
    deactivate SC
    deactivate VM
```

## Exchange Ratio Calculation

The StakingAccountant calculates the exchange ratio between HYPE and kHYPE tokens:

```solidity
function _getExchangeRatio() internal view returns (uint256) {
    // Calculate total kHYPE supply across all unique tokens
    uint256 totalKHYPESupply = 0;
    uint256 uniqueTokenCount = _uniqueTokens.length();
    
    // Sum up the supply of each unique token
    for (uint256 i = 0; i < uniqueTokenCount; i++) {
        address tokenAddress = _uniqueTokens.at(i);
        totalKHYPESupply += IERC20(tokenAddress).totalSupply();
    }
    
    // Return 1:1 ratio when no kHYPE has been minted yet
    if (totalKHYPESupply == 0) {
        return 1e18; // 1:1 ratio with 18 decimals precision
    }
    
    // Calculate total HYPE (in 8 decimals)
    uint256 rewardsAmount = validatorManager.totalRewards();
    uint256 slashingAmount = validatorManager.totalSlashing();
    uint256 totalHYPE = totalStaked + rewardsAmount - totalClaimed - slashingAmount;
    
    // Calculate ratio with 18 decimals precision
    return Math.mulDiv(totalHYPE, 1e18, totalKHYPESupply);
}
```

This ratio ensures that kHYPE tokens automatically increase in value as rewards accrue and decrease in value if slashing occurs.

## Contract Deployed Addresses

| Contract | Testnet Address | Mainnet Address |
|----------|-----------------|-----------------|
| StakingManager | TBD | TBD |
| ValidatorManager | TBD | TBD |
| OracleManager | TBD | TBD |
| StakingAccountant | TBD | TBD |
| kHYPE Token | TBD | TBD |
| PauserRegistry | TBD | TBD |
| SanityChecker | TBD | TBD | 