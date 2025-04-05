# Kinetiq: Liquid Staking Protocol for Hyperliquid

## Overview

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

## Development

### Prerequisites
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Build
```bash
forge build
```

### Test
```bash
forge test
```

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

## Disclaimer

This project is in active development and is not ready for production use. The final implementation may differ significantly based on Hyperliquid's official specifications and requirements.


