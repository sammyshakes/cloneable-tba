// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ITronicBeacon {
    function implementation() external view returns (address);
    function updateImplementation(address newImplementation) external;
}
