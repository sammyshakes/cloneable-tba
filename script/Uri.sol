// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicToken.sol";

contract Uri is Script {
    TronicToken public tronicTokenContract;

    address public tronicTokenContractAddress = vm.envAddress();

    uint256 public id = 1;

    function run() external {
        string memory uri = tronicTokenContract.uri(id);
    }
}
