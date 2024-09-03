// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "library/Math.sol";

contract Calculator {
    function calculateSum(uint256 a, uint256 b) public pure returns (uint256) {
        return MathLibrary.add(a, b); // Kütüphaneyi kullan
    }

    function calculateDifference(uint256 a, uint256 b) public pure returns (uint256) {
        return MathLibrary.subtract(a, b); // Kütüphaneyi kullan
    }
}