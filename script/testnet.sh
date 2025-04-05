#!/bin/bash

# Set environment variables
export RPC_URL="https://rpc.hyperliquid-testnet.xyz/evm"
export FOUNDRY_RPC_URL=$RPC_URL
export CONFIG_PATH="script/testnet.json"

# Then do deployment
forge script script/DeployCore.s.sol \
  --sig "run(string)" $CONFIG_PATH \
  --rpc-url $RPC_URL \
  --slow \
  --private-key=$KEY


# Then do the actual deployment
forge script script/DeployCore.s.sol \
  --sig "run(string)" $CONFIG_PATH \
  --rpc-url $RPC_URL \
  -vvvv \
  --slow \
  --verify \
  --verifier blockscout \
  --verifier-url "https://evm.hyperstats.xyz/api?module=contract&action=verify" \
  --private-key=$KEY \
  --broadcast


# Deploy Oracle Adapter
forge script script/DeployOracle.s.sol:DeployOraclesScript \
  --sig "run(address)" $ORACLE \
  --rpc-url $RPC_URL \
  -vvvv \
  --private-key=$KEY \
  --verify --verifier blockscout \
  --verifier-url "https://evm.hyperstats.xyz/api?module=contract&action=verify" \
  --broadcast


# Deploy Mock Oracle
forge script script/DeployOracle.s.sol:DeployMockOracleScript \
  --sig "run()" \
  --rpc-url $RPC_URL \
  -vvvv \
  --private-key=$KEY \
  --verify --verifier blockscout \
  --verifier-url "https://evm.hyperstats.xyz/api?module=contract&action=verify" \
  --broadcast

