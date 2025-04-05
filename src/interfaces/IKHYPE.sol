// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title IKHYPEToken
 * @notice Interface for the KHYPE token contract
 */
interface IKHYPEToken is IERC20, IAccessControl {
    /**
     * @notice Mints new tokens to the specified address
     * @param to Address to receive the minted tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice Burns tokens from the specified address
     * @param from Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burn(address from, uint256 amount) external;

    /**
     * @notice Role identifier for addresses allowed to mint tokens
     */
    function MINTER_ROLE() external view returns (bytes32);

    /**
     * @notice Role identifier for addresses allowed to burn tokens
     */
    function BURNER_ROLE() external view returns (bytes32);
}
