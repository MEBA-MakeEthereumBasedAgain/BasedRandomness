// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBasedEntrophy {
    function getEntropy() external view returns (bytes32);
}