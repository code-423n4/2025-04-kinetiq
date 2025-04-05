// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IOracleAdapter} from "./IOracleAdapter.sol";

/**
 * @notice Oracle adapter for reading and converting network data from external oracle
 */
contract OracleAdapter is IOracleAdapter {
    /* ========== STATE VARIABLES ========== */

    address public immutable defaultOracle; // External oracle contract

    /* ========== CONSTRUCTOR ========== */

    constructor(address _defaultOracle) {
        require(_defaultOracle != address(0), "Invalid oracle address");
        defaultOracle = _defaultOracle;
    }

    /* ========== ORACLE ADAPTER INTERFACE ========== */

    function getPerformance(
        address validator
    )
        external
        view
        override
        returns (
            uint256 balance,
            uint256 uptimeScore,
            uint256 speedScore,
            uint256 integrityScore,
            uint256 selfStakeScore,
            uint256 rewardAmount,
            uint256 slashAmount,
            uint256 timestamp
        )
    {
        // Read data directly from external oracle - no conversion needed
        return IDefaultOracle(defaultOracle).getValidatorMetrics(validator);
    }

    function name() external pure override returns (string memory) {
        return "Default Oracle Adapter";
    }

    function version() external pure override returns (string memory) {
        return "1.0.0";
    }

    /* ========== INTERFACE SUPPORT ========== */

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return interfaceId == type(IOracleAdapter).interfaceId;
    }
}

/**
 * @notice Interface for the external oracle
 * @dev Minimal interface - adjust based on actual external oracle contract
 */
interface IDefaultOracle {
    function getValidatorMetrics(
        address validator
    )
        external
        view
        returns (
            uint256 balance,
            uint256 uptime,
            uint256 speed,
            uint256 integrity,
            uint256 stake,
            uint256 reward,
            uint256 slashing,
            uint256 timestamp
        );
}
