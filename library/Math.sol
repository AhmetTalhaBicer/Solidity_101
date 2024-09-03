// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

library MathLibrary {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function subtract(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
}
