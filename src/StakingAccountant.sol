// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* ========== IMPORTS ========== */

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IValidatorManager} from "./interfaces/IValidatorManager.sol";
import {IStakingAccountant} from "./interfaces/IStakingAccountant.sol";

/**
 * @title StakingAccountant
 * @notice Manages global staking accounting and exchange rate calculations
 * @dev Implements upgradeable patterns with role-based access control
 */
contract StakingAccountant is IStakingAccountant, Initializable, AccessControlEnumerableUpgradeable {
    using EnumerableMap for EnumerableMap.AddressToAddressMap;
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* ========== STATE VARIABLES ========== */

    // Constants
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    // Core contract references
    IValidatorManager public validatorManager;

    // Global accounting
    uint256 public totalStaked;
    uint256 public totalClaimed;

    // Map StakingManager to their kHYPE token
    EnumerableMap.AddressToAddressMap private _authorizedManagers;

    // Track unique kHYPE tokens
    EnumerableSet.AddressSet private _uniqueTokens;

    /* ========== MODIFIERS ========== */

    modifier onlyAuthorizedManager() {
        require(_authorizedManagers.contains(msg.sender), "Not authorized");
        _;
    }

    /* ========== INITIALIZATION ========== */

    /**
     * @notice Initializes the StakingAccountant contract
     * @param admin Address to be granted admin role
     * @param manager Address to be granted manager role
     * @param _validatorManager Address of the validator manager contract
     */
    function initialize(address admin, address manager, address _validatorManager) public initializer {
        require(admin != address(0), "Invalid admin address");
        require(manager != address(0), "Invalid manager address");
        require(_validatorManager != address(0), "Invalid validator manager");

        __AccessControlEnumerable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MANAGER_ROLE, manager);

        validatorManager = IValidatorManager(_validatorManager);
    }

    /* ========== MANAGER FUNCTIONS ========== */

    /**
     * @notice Authorize a StakingManager with its kHYPE token
     * @param manager Address of the StakingManager to authorize
     * @param kHYPEToken Address of the kHYPE token for this manager
     */
    function authorizeStakingManager(address manager, address kHYPEToken) external onlyRole(MANAGER_ROLE) {
        require(manager != address(0), "Invalid manager address");
        require(kHYPEToken != address(0), "Invalid kHYPE token address");
        require(!_authorizedManagers.contains(manager), "Already authorized");

        _authorizedManagers.set(manager, kHYPEToken);

        // Add to unique tokens set if not already there
        _uniqueTokens.add(kHYPEToken);

        emit StakingManagerAuthorized(manager, kHYPEToken);
    }

    /**
     * @notice Deauthorize a StakingManager
     * @param manager Address of the StakingManager to deauthorize
     */
    function deauthorizeStakingManager(address manager) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        // Get the token before removing the manager
        (bool exists, address token) = _authorizedManagers.tryGet(manager);
        require(exists, "Manager not found");

        _authorizedManagers.remove(manager);

        // Check if any other manager is using this token
        bool tokenStillInUse = false;
        uint256 length = _authorizedManagers.length();

        for (uint256 i = 0; i < length; i++) {
            (, address otherToken) = _authorizedManagers.at(i);
            if (otherToken == token) {
                tokenStillInUse = true;
                break;
            }
        }

        // If no other manager is using this token, remove it from unique tokens
        if (!tokenStillInUse) {
            _uniqueTokens.remove(token);
        }

        emit StakingManagerDeauthorized(manager);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function recordStake(uint256 amount) external override onlyAuthorizedManager {
        totalStaked += amount;
        emit StakeRecorded(msg.sender, amount);
    }

    function recordClaim(uint256 amount) external override onlyAuthorizedManager {
        totalClaimed += amount;
        emit ClaimRecorded(msg.sender, amount);
    }

    /* ========== VIEW FUNCTIONS ========== */

    function isAuthorizedManager(address manager) external view override returns (bool) {
        return _authorizedManagers.contains(manager);
    }

    function getManagerToken(address manager) external view returns (address) {
        (bool exists, address token) = _authorizedManagers.tryGet(manager);
        require(exists, "Manager not authorized");
        return token;
    }

    function getAuthorizedManagerCount() external view returns (uint256) {
        return _authorizedManagers.length();
    }

    function getAuthorizedManagerAt(uint256 index) external view returns (address manager, address token) {
        require(index < _authorizedManagers.length(), "Index out of bounds");
        (manager, token) = _authorizedManagers.at(index);
    }

    function getUniqueTokenCount() external view returns (uint256) {
        return _uniqueTokens.length();
    }

    function getUniqueTokenAt(uint256 index) external view returns (address) {
        require(index < _uniqueTokens.length(), "Index out of bounds");
        return _uniqueTokens.at(index);
    }

    function totalRewards() external view override returns (uint256) {
        return validatorManager.totalRewards();
    }

    function totalSlashing() external view override returns (uint256) {
        return validatorManager.totalSlashing();
    }

    /**
     * @notice Convert kHYPE to HYPE
     * @param kHYPEAmount Amount of kHYPE to convert
     * @return hypeAmount Equivalent amount of HYPE
     */
    function kHYPEToHYPE(uint256 kHYPEAmount) public view override returns (uint256) {
        return Math.mulDiv(kHYPEAmount, _getExchangeRatio(), 1e18);
    }

    function HYPEToKHYPE(uint256 HYPEAmount) public view override returns (uint256) {
        uint256 exchangeRatio = _getExchangeRatio();
        require(exchangeRatio > 0, "Invalid exchange ratio");
        return Math.mulDiv(HYPEAmount, 1e18, exchangeRatio);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    /**
     * @notice Calculate the exchange ratio between HYPE and all kHYPE tokens
     * @return ratio Exchange ratio with 18 decimals precision (HYPE/kHYPE)
     */
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
}
