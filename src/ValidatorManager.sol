// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IValidatorManager} from "./interfaces/IValidatorManager.sol";
import {IPauserRegistry} from "./interfaces/IPauserRegistry.sol";
import {IStakingManager} from "./interfaces/IStakingManager.sol";

/**
 * @title ValidatorManager
 * @notice Manages validator registration, performance tracking, and rebalancing
 * @dev This contract handles validator lifecycle and stake rebalancing
 */
contract ValidatorManager is
    IValidatorManager,
    Initializable,
    AccessControlEnumerableUpgradeable,
    ReentrancyGuardUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* ========== LIBRARIES ========== */

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    /* ========== CONSTANTS ========== */

    /// @notice Basis points denominator (100%)
    uint256 public constant BASIS_POINTS = 10000;

    /* ========== ROLES ========== */

    /// @notice Role that can manage validators and operational parameters
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice Role that can update validator performance
    bytes32 public constant ORACLE_MANAGER_ROLE = keccak256("ORACLE_MANAGER_ROLE");

    /* ========== STATE VARIABLES ========== */

    /// @notice Registry for pausing functionality
    IPauserRegistry public pauserRegistry;

    /// @notice Total amount slashed across all validators
    uint256 public totalSlashing; // In 8 decimals

    /// @notice Total rewards across all validators
    uint256 public totalRewards; // In 8 decimals

    /// @notice Mapping of staking manager to delegation target
    mapping(address => address) public delegations;

    /// @notice Mapping of validator to rebalance request
    mapping(address => RebalanceRequest) public validatorRebalanceRequests;

    /// @notice Mapping of validator to performance report
    mapping(address => PerformanceReport) public validatorPerformance;

    /// @notice Mapping of validator to total slashing amount
    mapping(address => uint256) public validatorSlashing;

    /// @notice Mapping of validator to total rewards
    mapping(address => uint256) public validatorRewards;

    /// @dev Array of all validators
    Validator[] internal _validators;

    /// @dev Mapping of validator address to index in _validators array
    EnumerableMap.AddressToUintMap internal _validatorIndexes;

    /// @dev Set of validators with pending rebalance
    EnumerableSet.AddressSet internal _validatorsWithPendingRebalance;

    /* ========== MODIFIERS ========== */

    modifier whenNotPaused() {
        require(!pauserRegistry.isPaused(address(this)), "Contract is paused");
        _;
    }

    modifier validatorExists(address validator) {
        require(_validatorIndexes.contains(validator), "Validator does not exist");
        _;
    }

    modifier validatorActive(address validator) {
        require(validatorActiveState(validator), "Validator not active");
        _;
    }

    /* ========== INITIALIZATION ========== */

    /**
     * @notice Initialize the contract with initial configuration
     * @param admin Address that will have admin role
     * @param manager Address that will have manager role
     * @param _oracle Address that will have oracle role
     * @param _pauserRegistry Address of the pauser registry contract
     */
    function initialize(address admin, address manager, address _oracle, address _pauserRegistry) external initializer {
        require(admin != address(0), "Invalid admin address");
        require(manager != address(0), "Invalid manager address");
        require(_oracle != address(0), "Invalid oracle address");
        require(_pauserRegistry != address(0), "Invalid pauser registry");

        __AccessControlEnumerable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MANAGER_ROLE, manager);
        _grantRole(ORACLE_MANAGER_ROLE, _oracle);

        pauserRegistry = IPauserRegistry(_pauserRegistry);
    }

    /* ========== VALIDATOR MANAGEMENT ========== */

    /**
     * @notice Activate a new validator in the system
     * @param validator Address of the validator to activate
     */
    function activateValidator(address validator) external whenNotPaused onlyRole(MANAGER_ROLE) {
        require(validator != address(0), "Invalid validator address");
        require(!_validatorIndexes.contains(validator), "Validator already exists");

        Validator memory newValidator = Validator({
            balance: 0,
            uptimeScore: 0,
            speedScore: 0,
            integrityScore: 0,
            selfStakeScore: 0,
            lastUpdateTime: block.timestamp,
            active: true
        });

        _validators.push(newValidator);
        _validatorIndexes.set(validator, _validators.length - 1);

        emit ValidatorActivated(validator);
    }

    /**
     * @notice Deactivate a validator
     * @param validator Address of the validator to deactivate
     */
    function deactivateValidator(address validator) external whenNotPaused nonReentrant validatorExists(validator) {
        // limit the msg.sender to MANAGER_ROLE
        require(hasRole(MANAGER_ROLE, msg.sender), "Not authorized");

        (bool exists, uint256 index) = _validatorIndexes.tryGet(validator);
        require(exists, "Validator does not exist");

        Validator storage validatorData = _validators[index];
        require(validatorData.active, "Validator already inactive");

        // Update state after withdrawal request
        validatorData.active = false;

        emit ValidatorDeactivated(validator);
    }

    /**
     * @notice Reactivate a previously deactivated validator
     * @param validator Address of the validator to reactivate
     */
    function reactivateValidator(
        address validator
    ) external whenNotPaused nonReentrant onlyRole(MANAGER_ROLE) validatorExists(validator) {
        (bool exists, uint256 index) = _validatorIndexes.tryGet(validator);
        require(exists, "Validator does not exist");

        Validator storage validatorData = _validators[index];
        require(!validatorData.active, "Validator already active");
        require(!_validatorsWithPendingRebalance.contains(validator), "Validator has pending rebalance");

        // Reactivate the validator
        validatorData.active = true;

        emit ValidatorReactivated(validator);
    }

    /* ========== REBALANCING ========== */

    /**
     * @notice Request withdrawals for multiple validators
     * @param stakingManager Address of the staking manager contract
     * @param validators Array of validator addresses
     * @param withdrawalAmounts Array of amounts to withdraw
     */
    function rebalanceWithdrawal(
        address stakingManager,
        address[] calldata validators,
        uint256[] calldata withdrawalAmounts
    ) external whenNotPaused nonReentrant onlyRole(MANAGER_ROLE) {
        require(validators.length == withdrawalAmounts.length, "Length mismatch");
        require(validators.length > 0, "Empty arrays");

        for (uint256 i = 0; i < validators.length; ) {
            require(validators[i] != address(0), "Invalid validator address");

            // Add rebalance request (this will check for duplicates)
            _addRebalanceRequest(stakingManager, validators[i], withdrawalAmounts[i]);

            unchecked {
                ++i;
            }
        }

        // Trigger withdrawals through StakingManager
        IStakingManager(stakingManager).processValidatorWithdrawals(validators, withdrawalAmounts);
    }

    /**
     * @dev Internal function to add a rebalance request
     * @param validator Address of the validator
     * @param withdrawalAmount Amount to withdraw
     */
    function _addRebalanceRequest(address staking, address validator, uint256 withdrawalAmount) internal {
        require(!_validatorsWithPendingRebalance.contains(validator), "Validator has pending rebalance");
        require(withdrawalAmount > 0, "Invalid withdrawal amount");

        (bool exists /* uint256 index */, ) = _validatorIndexes.tryGet(validator);
        require(exists, "Validator does not exist");

        validatorRebalanceRequests[validator] = RebalanceRequest({
            staking: staking,
            validator: validator,
            amount: withdrawalAmount
        });
        _validatorsWithPendingRebalance.add(validator);

        emit RebalanceRequestAdded(validator, withdrawalAmount);
    }

    /**
     * @notice Close multiple rebalance requests and redelegate
     * @param stakingManager Address of the staking manager contract
     * @param validators Array of validator addresses
     * @dev Clears the rebalance requests and triggers redelegation through stakingManager
     */
    function closeRebalanceRequests(
        address stakingManager,
        address[] calldata validators
    ) external whenNotPaused nonReentrant onlyRole(MANAGER_ROLE) {
        require(_validatorsWithPendingRebalance.length() > 0, "No pending requests");
        require(validators.length > 0, "Empty array");

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < validators.length; ) {
            address validator = validators[i];
            require(_validatorsWithPendingRebalance.contains(validator), "No pending request");

            // Add amount to total for redelegation
            RebalanceRequest memory request = validatorRebalanceRequests[validator];
            require(request.staking == stakingManager, "Invalid staking manager for rebalance");

            totalAmount += request.amount;

            // Clear the rebalance request
            delete validatorRebalanceRequests[validator];
            _validatorsWithPendingRebalance.remove(validator);

            emit RebalanceRequestClosed(validator, request.amount);

            unchecked {
                ++i;
            }
        }

        // Trigger redelegation through StakingManager if there's an amount to delegate
        if (totalAmount > 0) {
            IStakingManager(stakingManager).processValidatorRedelegation(totalAmount);
        }
    }

    /**
     * @notice Check if a validator has a pending rebalance request
     * @param validator Address of the validator to check
     * @return bool True if the validator has a pending rebalance request
     */
    function hasPendingRebalance(address validator) external view returns (bool) {
        return _validatorsWithPendingRebalance.contains(validator);
    }

    /* ========== PERFORMANCE MONITORING ========== */

    /// @notice Updates performance scores for a validator
    /// @param validator Address of validator
    /// @param balance Current balance of the validator
    /// @param uptimeScore New uptime score (0-10000)
    /// @param speedScore New speed score (0-10000)
    /// @param integrityScore New integrity score (0-10000)
    /// @param selfStakeScore New self stake score (0-10000)
    function updateValidatorPerformance(
        address validator,
        uint256 balance,
        uint256 uptimeScore,
        uint256 speedScore,
        uint256 integrityScore,
        uint256 selfStakeScore
    ) external whenNotPaused onlyRole(ORACLE_MANAGER_ROLE) validatorActive(validator) {
        // Validate scores are within bounds
        require(
            uptimeScore <= BASIS_POINTS &&
                speedScore <= BASIS_POINTS &&
                integrityScore <= BASIS_POINTS &&
                selfStakeScore <= BASIS_POINTS,
            "Score exceeds maximum"
        );

        uint256 index = _validatorIndexes.get(validator);

        // Update validator struct in one storage write
        _validators[index] = Validator({
            balance: balance,
            uptimeScore: uptimeScore,
            speedScore: speedScore,
            integrityScore: integrityScore,
            selfStakeScore: selfStakeScore,
            lastUpdateTime: block.timestamp,
            active: _validators[index].active // Preserve active state
        });

        // Update performance report in one storage write
        validatorPerformance[validator] = PerformanceReport({
            balance: balance,
            uptimeScore: uptimeScore,
            speedScore: speedScore,
            integrityScore: integrityScore,
            selfStakeScore: selfStakeScore,
            timestamp: block.timestamp
        });

        emit ValidatorPerformanceUpdated(validator, block.timestamp, block.number);
    }

    /* ========== PERFORMANCE QUERIES ========== */

    function validatorScores(
        address validator
    )
        external
        view
        validatorExists(validator)
        returns (uint256 uptimeScore, uint256 speedScore, uint256 integrityScore, uint256 selfStakeScore)
    {
        Validator memory val = _validators[_validatorIndexes.get(validator)];
        return (val.uptimeScore, val.speedScore, val.integrityScore, val.selfStakeScore);
    }

    function validatorLastUpdateTime(address validator) external view validatorExists(validator) returns (uint256) {
        return _validators[_validatorIndexes.get(validator)].lastUpdateTime;
    }

    function validatorBalance(address validator) external view validatorExists(validator) returns (uint256) {
        return _validators[_validatorIndexes.get(validator)].balance;
    }

    function validatorActiveState(address validator) public view validatorExists(validator) returns (bool) {
        return _validators[_validatorIndexes.get(validator)].active;
    }

    function activeValidatorsCount() external view returns (uint256) {
        uint256 count;
        uint256 length = _validators.length;
        for (uint256 i; i < length; ) {
            if (_validators[i].active) {
                count++;
            }
            unchecked {
                ++i;
            }
        }
        return count;
    }

    function validatorCount() public view returns (uint256) {
        return _validators.length;
    }

    function validatorAt(uint256 index) public view returns (address validator, Validator memory data) {
        uint256 length = _validators.length;
        require(index < length, "Index out of bounds");

        (validator, ) = _validatorIndexes.at(index);
        data = _validators[index];
        return (validator, data);
    }

    function validatorInfo(address validator) public view validatorExists(validator) returns (Validator memory) {
        return _validators[_validatorIndexes.get(validator)];
    }

    /* ========== REWARDS ========== */

    /// @notice Report a reward event for a validator
    /// @param validator Address of the validator to be rewarded
    /// @param amount Amount of rewards for the validator
    function reportRewardEvent(
        address validator,
        uint256 amount
    ) external onlyRole(ORACLE_MANAGER_ROLE) validatorActive(validator) {
        require(amount > 0, "Invalid reward amount");

        // Update reward amounts
        totalRewards += amount;
        validatorRewards[validator] += amount;

        emit RewardEventReported(validator, amount);
    }

    /* ========== SLASHING ========== */

    /// @notice Report a slashing event for a validator
    /// @param validator Address of the validator to be slashed
    /// @param amount Amount to slash from the validator
    function reportSlashingEvent(
        address validator,
        uint256 amount
    ) external onlyRole(ORACLE_MANAGER_ROLE) validatorActive(validator) {
        require(amount > 0, "Invalid slash amount");

        // Update slashing amounts
        totalSlashing += amount;
        validatorSlashing[validator] += amount;

        emit SlashingEventReported(validator, amount);
    }

    /* ========== DELEGATION MANAGEMENT ========== */

    /**
     * @notice Set delegation target for a staking manager
     * @param stakingManager Address of the staking manager
     * @param validator Address of the validator to delegate to
     */
    function setDelegation(
        address stakingManager,
        address validator
    ) external whenNotPaused onlyRole(MANAGER_ROLE) validatorActive(validator) {
        require(stakingManager != address(0), "Invalid staking manager");
        address oldDelegation = delegations[stakingManager];
        delegations[stakingManager] = validator;

        emit DelegationUpdated(stakingManager, oldDelegation, validator);
    }

    /**
     * @notice Get delegation target for a staking manager
     * @param stakingManager Address of the staking manager
     * @return Address of the validator to delegate to
     */
    function getDelegation(address stakingManager) external view returns (address) {
        address validator = delegations[stakingManager];
        require(validator != address(0), "No delegation set");
        require(validatorActiveState(validator), "Delegated validator not active");
        return validator;
    }
}
