// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TronicBeacon {
    address private _owner;
    address private _implementation;

    constructor(address initialImplementation) {
        _owner = msg.sender;
        _implementation = initialImplementation;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function.");
        _;
    }

    function implementation() external view returns (address) {
        return _implementation;
    }

    function updateImplementation(address newImplementation) external onlyOwner {
        _implementation = newImplementation;
    }
}
