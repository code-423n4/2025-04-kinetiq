// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SystemOracle {
    uint256 public sysBlockNumber;
    uint256[] public markPxs;
    uint256[] public oraclePxs;
    uint256[] public spotPxs;

    modifier onlyOperator() {
        require(msg.sender == 0x2222222222222222222222222222222222222222, "Only operator allowed");
        _;
    }

    // Function to set the list of numbers, only the owner can call this
    function setValues(
        uint256 _sysBlockNumber,
        uint256[] memory _markPxs,
        uint256[] memory _oraclePxs,
        uint256[] memory _spotPxs
    ) public onlyOperator {
        sysBlockNumber = _sysBlockNumber;
        markPxs = _markPxs;
        oraclePxs = _oraclePxs;
        spotPxs = _spotPxs;
    }

    function getMarkPxs() public view returns (uint256[] memory) {
        return markPxs;
    }

    function getOraclePxs() public view returns (uint256[] memory) {
        return oraclePxs;
    }

    function getSpotPxs() public view returns (uint256[] memory) {
        return spotPxs;
    }
}
