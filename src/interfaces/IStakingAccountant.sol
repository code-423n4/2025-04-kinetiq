// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStakingAccountant {
    // Events
    event StakingManagerAuthorized(address indexed manager, address indexed token);
    event StakingManagerDeauthorized(address indexed manager);
    event StakeRecorded(address indexed manager, uint256 amount);
    event ClaimRecorded(address indexed manager, uint256 amount);

    // View functions
    function totalStaked() external view returns (uint256);
    function totalClaimed() external view returns (uint256);
    function totalRewards() external view returns (uint256);
    function totalSlashing() external view returns (uint256);
    function isAuthorizedManager(address manager) external view returns (bool);
    function getManagerToken(address manager) external view returns (address);
    function getAuthorizedManagerCount() external view returns (uint256);
    function getAuthorizedManagerAt(uint256 index) external view returns (address manager, address token);
    function getUniqueTokenCount() external view returns (uint256);
    function getUniqueTokenAt(uint256 index) external view returns (address);

    // Exchange ratio functions
    function kHYPEToHYPE(uint256 kHYPEAmount) external view returns (uint256);
    function HYPEToKHYPE(uint256 HYPEAmount) external view returns (uint256);

    // State changing functions
    function authorizeStakingManager(address manager, address kHYPEToken) external;
    function deauthorizeStakingManager(address manager) external;
    function recordStake(uint256 amount) external;
    function recordClaim(uint256 amount) external;
}
