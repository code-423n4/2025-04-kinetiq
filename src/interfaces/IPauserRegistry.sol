// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPauserRegistry
 * @notice Interface for the PauserRegistry contract that manages protocol pause states
 */
interface IPauserRegistry {
    /* ========== EVENTS ========== */

    event ContractPaused(address indexed contractAddress);
    event ContractUnpaused(address indexed contractAddress);
    event ContractAuthorized(address indexed contractAddress);
    event ContractDeauthorized(address indexed contractAddress);

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Checks if a contract is paused
     * @param contractAddress The address of the contract to check
     * @return bool True if the contract is paused
     */
    function isPaused(address contractAddress) external view returns (bool);

    /**
     * @notice Checks if a contract is authorized
     * @param contractAddress The address of the contract to check
     * @return bool True if the contract is authorized
     */
    function isAuthorizedContract(address contractAddress) external view returns (bool);

    /**
     * @notice Gets all authorized contracts
     * @return address[] Array of authorized contract addresses
     */
    function getAuthorizedContracts() external view returns (address[] memory);

    /**
     * @notice Gets the count of authorized contracts
     * @return uint256 Number of authorized contracts
     */
    function getAuthorizedContractCount() external view returns (uint256);

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @notice Pauses a specific contract
     * @param contractAddress The address of the contract to pause
     */
    function pauseContract(address contractAddress) external;

    /**
     * @notice Unpauses a specific contract
     * @param contractAddress The address of the contract to unpause
     */
    function unpauseContract(address contractAddress) external;

    /**
     * @notice Pauses all authorized contracts
     */
    function emergencyPauseAll() external;
}
