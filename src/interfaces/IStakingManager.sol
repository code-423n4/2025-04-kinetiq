// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStakingManager {
    /* ========== STRUCTS ========== */

    struct WithdrawalRequest {
        uint256 hypeAmount; // Amount in HYPE to withdraw
        uint256 kHYPEAmount; // Amount in kHYPE to burn (excluding fee)
        uint256 kHYPEFee; // Fee amount in kHYPE tokens
        uint256 timestamp; // Request timestamp
    }

    // Define the enum on operation type
    enum OperationType {
        UserDeposit, // 0: User deposit operation; from EVM to Validator
        SpotDeposit, // 1: Deposit operation from SpotAccount to Validator(handling dusts)
        RebalanceDeposit, // 2: Rebalancing deposit operation; from StakingAccount to Validator
        UserWithdrawal, // 3: User withdrawal; From Validator to EVM
        RebalanceWithdrawal // 4: Rebalancing withdrawal; From Validator to StakingAccount
    }

    // Update the L1Operation struct to use the enum
    struct L1Operation {
        address validator;
        uint256 amount;
        OperationType operationType;
    }

    /* ========== EVENTS ========== */

    event StakeReceived(address indexed staking, address indexed staker, uint256 amount);
    event WithdrawalQueued(
        address indexed staking,
        address indexed user,
        uint256 indexed withdrawalId,
        uint256 kHYPEAmount,
        uint256 hypeAmount,
        uint256 feeAmount
    );
    event WithdrawalConfirmed(address indexed user, uint256 indexed withdrawalId, uint256 amount);
    event WithdrawalCancelled(
        address indexed user,
        uint256 indexed withdrawalId,
        uint256 amount,
        uint256 totalCancelAmount
    );
    event StakingLimitUpdated(uint256 newStakingLimit);
    event MinStakeAmountUpdated(uint256 newMinStakeAmount);
    event MaxStakeAmountUpdated(uint256 newMaxStakeAmount);
    event WithdrawalDelayUpdated(uint256 newDelay);
    event Delegate(address indexed staking, address indexed validator, uint256 amount);
    event TargetBufferUpdated(uint256 newTargetBuffer);
    event BufferIncreased(uint256 amountAdded, uint256 newTotal);
    event BufferDecreased(uint256 amountRemoved, uint256 newTotal);
    event ValidatorWithdrawal(address indexed staking, address indexed validator, uint256 amount);
    event WhitelistEnabled();
    event WhitelistDisabled();
    event AddressWhitelisted(address indexed account);
    event AddressRemovedFromWhitelist(address indexed account);
    // Add events for pause state changes
    event StakingPaused(address indexed by);
    event StakingUnpaused(address indexed by);
    event WithdrawalPaused(address indexed by);
    event WithdrawalUnpaused(address indexed by);
    event WithdrawalRedelegated(uint256 amount);
    event UnstakeFeeRateUpdated(uint256 newRate);
    // Add event for treasury updates
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    // Add event for stake & unstake queued L1 operations, amount is decimal 8 here
    event L1DelegationQueued(
        address indexed staking,
        address indexed validator,
        uint256 amount,
        OperationType operationType
    );
    event L1DelegationProcessed(
        address indexed staking,
        address indexed validator,
        uint256 amount,
        OperationType operationType
    );
    event SpotWithdrawn(uint256 amount);
    // Add events for airdrops
    /**
     * @notice Emitted when a token is withdrawn from spot balance
     * @param tokenId The ID of the token withdrawn
     * @param amount The amount withdrawn
     * @param recipient The address receiving the tokens
     */
    event TokenWithdrawnFromSpot(uint64 indexed tokenId, uint64 amount, address indexed recipient);
    /**
     * @notice Emitted when a token is rescued from the contract
     * @param token The address of the token rescued (address(0) for native tokens)
     * @param amount The amount rescued
     * @param recipient The address receiving the tokens
     */
    event TokenRescued(address indexed token, uint256 amount, address indexed recipient);
    /**
     * @notice Emitted when L1 operations are queued for retry
     * @param validators Array of validator addresses
     * @param amounts Array of amounts
     * @param operationTypes Array of operation types
     */
    event L1OperationsQueued(address[] validators, uint256[] amounts, OperationType[] operationTypes);
    /**
     * @notice Emitted when L1 operations are processed in batch
     * @param processedCount Number of operations processed
     * @param remainingCount Number of operations remaining
     */
    event L1OperationsBatchProcessed(uint256 processedCount, uint256 remainingCount);
    /**
     * @notice Emitted when the L1 operations queue is reset
     * @param queueLength Length of the queue before reset
     */
    event L1OperationsQueueReset(uint256 queueLength);
    /**
     * @notice Emitted when an emergency withdrawal is executed
     * @param validator Address of the validator
     * @param amount Amount withdrawn
     */
    event EmergencyWithdrawalExecuted(address indexed validator, uint256 amount);

    /* ========== VIEW FUNCTIONS ========== */

    /// @notice Gets the total amount of HYPE staked
    function totalStaked() external view returns (uint256);

    /// @notice Gets the total amount of HYPE claimed
    function totalClaimed() external view returns (uint256);

    /// @notice Gets the total amount of queued withdrawals
    function totalQueuedWithdrawals() external view returns (uint256);

    /// @notice Gets the current HYPE buffer amount
    function hypeBuffer() external view returns (uint256);

    /// @notice Gets the target buffer size
    function targetBuffer() external view returns (uint256);

    /// @notice Gets the maximum total staking limit
    function stakingLimit() external view returns (uint256);

    /// @notice Gets the minimum stake amount per transaction
    function minStakeAmount() external view returns (uint256);

    /// @notice Gets the maximum stake amount per transaction
    function maxStakeAmount() external view returns (uint256);

    /// @notice Gets the withdrawal delay period
    function withdrawalDelay() external view returns (uint256);

    /// @notice Gets withdrawal request details for a user
    function withdrawalRequests(address user, uint256 id) external view returns (WithdrawalRequest memory);

    /// @notice Gets the next withdrawal ID for a user
    function nextWithdrawalId(address user) external view returns (uint256);

    /// @notice Gets the current unstake fee rate
    function unstakeFeeRate() external view returns (uint256);

    /* ========== MUTATIVE FUNCTIONS ========== */

    /// @notice Stakes HYPE tokens
    function stake() external payable;

    /// @notice Queues a withdrawal request
    function queueWithdrawal(uint256 amount) external;

    /// @notice Confirms a withdrawal request
    function confirmWithdrawal(uint256 withdrawalId) external;

    /**
     * @notice Process validator withdrawals requested by ValidatorManager
     * @param validators Array of validator addresses
     * @param amounts Array of amounts to withdraw
     */
    function processValidatorWithdrawals(address[] calldata validators, uint256[] calldata amounts) external;

    /**
     * @notice Delegate available balance to current validator
     * @param amount Amount to delegate
     */
    function processValidatorRedelegation(uint256 amount) external;

    /**
     * @notice Queue L1 operations directly for retrying failed operations
     * @param validators Array of validator addresses
     * @param amounts Array of amounts to process
     * @param operationTypes Array of operation types
     */
    function queueL1Operations(
        address[] calldata validators,
        uint256[] calldata amounts,
        OperationType[] calldata operationTypes
    ) external;

    /* ========== WHITELIST FUNCTIONS ========== */

    function enableWhitelist() external;
    function disableWhitelist() external;
    function addToWhitelist(address[] calldata accounts) external;
    function removeFromWhitelist(address[] calldata accounts) external;
    function isWhitelisted(address account) external view returns (bool);
    function whitelistLength() external view returns (uint256);
}
