// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* ========== IMPORTS ========== */

import {AccessControlEnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {IPauserRegistry} from "../src/interfaces/IPauserRegistry.sol";

/**
 * @title KHYPE Token
 * @notice ERC20 token representing staked HYPE with permit functionality
 * @dev Implements role-based access control for minting and burning
 */
contract KHYPE is ERC20PermitUpgradeable, AccessControlEnumerableUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* ========== STATE VARIABLES ========== */

    IPauserRegistry public pauserRegistry; // Add this state variable

    /* ========== ROLE DEFINITIONS ========== */

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // Role allowed to mint new tokens
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE"); // Role allowed to burn tokens

    /* ========== MODIFIERS ========== */

    modifier whenNotPaused() {
        require(!pauserRegistry.isPaused(address(this)), "Contract is paused");
        _;
    }

    /* ========== INITIALIZATION ========== */

    /**
     * @notice Initializes the KHYPE token with basic settings and role assignments
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param admin Address that will receive the DEFAULT_ADMIN_ROLE
     * @param minter Address that will receive the MINTER_ROLE
     * @param burner Address that will receive the BURNER_ROLE
     * @param _pauserRegistry Address of the pauser registry
     */
    function initialize(
        string calldata name,
        string calldata symbol,
        address admin,
        address minter,
        address burner,
        address _pauserRegistry
    ) public initializer {
        // Validate input addresses
        require(admin != address(0), "Invalid admin address");
        require(_pauserRegistry != address(0), "Invalid pauser registry address");
        require(minter != address(0), "Invalid minter address");
        require(burner != address(0), "Invalid burner address");

        // Initialize inherited contracts
        __ERC20_init(name, symbol);
        __ERC20Permit_init(name); // Initialize permit functionality for gasless transactions
        __AccessControlEnumerable_init();

        // Setup role hierarchy - all roles are managed by admin
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(BURNER_ROLE, DEFAULT_ADMIN_ROLE);

        // Grant roles
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(BURNER_ROLE, burner);

        // Set pauser registry
        pauserRegistry = IPauserRegistry(_pauserRegistry);
    }

    /* ========== TOKEN OPERATIONS ========== */

    /**
     * @notice Mints new tokens to the specified address
     * @param to Address to receive the minted tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount); // TODO update the logic with mirror token
    }

    /**
     * @notice Burns tokens from the specified address
     * @param from Address to burn tokens from
     * @param amount Amount of tokens to burn
     */
    function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(from, amount); // TODO update the logic with mirror token
    }

    /* ========== INTERFACE IMPLEMENTATIONS ========== */

    /**
     * @notice Implementation of ERC165 interface detection
     * @param interfaceId The interface identifier to check
     * @return bool True if the contract implements the interface
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControlEnumerableUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Override _update to add pause check
     */
    function _update(address from, address to, uint256 value) internal virtual override whenNotPaused {
        super._update(from, to, value);
    }
}
