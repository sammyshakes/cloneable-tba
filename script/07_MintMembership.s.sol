// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract MintMembership is Script {
    address public tronicMainContractAddress = vm.envAddress("TRONIC_MAIN_PROXY_ADDRESS");
    address public userAddress = vm.envAddress("SAMPLE_USER1_ADDRESS");

    uint256 public membershipXId = vm.envUint("MEMBERSHIP_X_ID");
    uint8 public tierIndex = 0;

    // this script mints an erc721 token to the user address
    function run() external returns (uint256 tokenId) {
        uint256 adminPrivateKey = uint256(vm.envBytes32("TRONIC_ADMIN_PRIVATE_KEY"));
        TronicMain tronicMainContract = TronicMain(tronicMainContractAddress);

        vm.startBroadcast(adminPrivateKey);

        //mint tronic membership erc721 to sample userAddress
        // which returns tokenbound account address for user's minted token id
        (tokenId) = tronicMainContract.mintMembership(userAddress, membershipXId, tierIndex);

        vm.stopBroadcast();
    }
}
