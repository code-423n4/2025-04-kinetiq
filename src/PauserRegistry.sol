// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* ========== IMPORTS ========== */

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IPauserRegistry} from "./interfaces/IPauserRegistry.sol";

/**
 * @title PauserRegistry
 * @notice Registry contract that manages pause states for protocol contracts
 * @dev Implements role-based access control for pausing functionality
 */
contract PauserRegistry is IPauserRegistry, Initializable, AccessControlEnumerableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* ========== LIBRARIES ========== */

    using EnumerableSet for EnumerableSet.AddressSet;

    /* ========== STATE VARIABLES ========== */

    // Constants
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");
    bytes32 public constant PAUSE_ALL_ROLE = keccak256("PAUSE_ALL_ROLE");

    // Pause state tracking
    mapping(address => bool) public isPaused;

    // Contract management
    EnumerableSet.AddressSet private _authorizedContracts;

    /* ========== INITIALIZATION ========== */

    /**
     * @notice Initializes the registry with admin and role assignments
     * @param admin Address that will receive the DEFAULT_ADMIN_ROLE
     * @param pauser Address that will receive the PAUSER_ROLE
     * @param unpauser Address that will receive the UNPAUSER_ROLE
     * @param pauseAll Address that will receive the PAUSE_ALL_ROLE
     * @param contracts Initial set of authorized contracts
     */
    function initialize(
        address admin,
        address pauser,
        address unpauser,
        address pauseAll,
        address[] memory contracts
    ) public initializer {
        // Validate input addresses
        require(admin != address(0), "Invalid admin address");
        require(pauser != address(0), "Invalid pauser address");
        require(unpauser != address(0), "Invalid unpauser address");
        require(pauseAll != address(0), "Invalid pauseAll address");

        // Initialize inherited contracts
        __AccessControlEnumerable_init();

        // Setup role hierarchy
        _setRoleAdmin(PAUSER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(UNPAUSER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PAUSE_ALL_ROLE, DEFAULT_ADMIN_ROLE);

        // Grant roles
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(UNPAUSER_ROLE, unpauser);
        _grantRole(PAUSE_ALL_ROLE, pauseAll);

        // Register initial contracts
        for (uint256 i = 0; i < contracts.length; i++) {
            _authorizedContracts.add(contracts[i]);
        }
    }

    /* ========== PAUSE FUNCTIONS ========== */

    /**
     * @notice Pauses a specific contract
     * @param contractAddress Address of the contract to pause
     */
    function pauseContract(address contractAddress) external onlyRole(PAUSER_ROLE) {
        require(_authorizedContracts.contains(contractAddress), "Contract not authorized");
        require(!isPaused[contractAddress], "Contract already paused");

        isPaused[contractAddress] = true;
        emit ContractPaused(contractAddress);
    }

    /**
     * @notice Unpauses a specific contract
     * @param contractAddress Address of the contract to unpause
     */
    function unpauseContract(address contractAddress) external onlyRole(UNPAUSER_ROLE) {
        require(_authorizedContracts.contains(contractAddress), "Contract not authorized");
        require(isPaused[contractAddress], "Contract not paused");

        isPaused[contractAddress] = false;
        emit ContractUnpaused(contractAddress);
    }

    /**
     * @notice Emergency function to pause all authorized contracts
     */
    function emergencyPauseAll() external onlyRole(PAUSE_ALL_ROLE) {
        uint256 length = _authorizedContracts.length();

        for (uint256 i = 0; i < length; i++) {
            address contractAddress = _authorizedContracts.at(i);
            if (!isPaused[contractAddress]) {
                isPaused[contractAddress] = true;
                emit ContractPaused(contractAddress);
            }
        }
    }

    /* ========== AUTHORIZATION FUNCTIONS ========== */

    /**
     * @notice Authorizes a contract to be pausable
     * @param contractAddress Address of the contract to authorize
     */
    function authorizeContract(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(contractAddress != address(0), "Invalid contract address");
        require(!_authorizedContracts.contains(contractAddress), "Contract already authorized");

        _authorizedContracts.add(contractAddress);
        emit ContractAuthorized(contractAddress);
    }

    /**
     * @notice Removes authorization from a contract
     * @param contractAddress Address of the contract to deauthorize
     */
    function deauthorizeContract(address contractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_authorizedContracts.contains(contractAddress), "Contract not authorized");

        _authorizedContracts.remove(contractAddress);
        emit ContractDeauthorized(contractAddress);
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Checks if a contract is authorized
     * @param contractAddress The address of the contract to check
     * @return bool True if the contract is authorized
     */
    function isAuthorizedContract(address contractAddress) external view returns (bool) {
        return _authorizedContracts.contains(contractAddress);
    }

    /**
     * @notice Gets all authorized contracts
     * @return address[] Array of authorized contract addresses
     */
    function getAuthorizedContracts() external view returns (address[] memory) {
        return _authorizedContracts.values();
    }

    /**
     * @notice Gets the count of authorized contracts
     * @return uint256 Number of authorized contracts
     */
    function getAuthorizedContractCount() external view returns (uint256) {
        return _authorizedContracts.length();
    }
}
