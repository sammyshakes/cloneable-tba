// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract MintBrandLoyalty is Script {
    address public tronicMainContractAddress = vm.envAddress("TRONIC_MAIN_PROXY_ADDRESS");
    address public userAddress = vm.envAddress("SAMPLE_USER1_ADDRESS");

    uint256 public brandXId = vm.envUint("BRAND_X_ID");

    // this script mints an erc721 token to the user address
    function run() external {
        uint256 adminPrivateKey = uint256(vm.envBytes32("TRONIC_ADMIN_PRIVATE_KEY"));
        TronicMain tronicMainContract = TronicMain(tronicMainContractAddress);

        vm.startBroadcast(adminPrivateKey);

        //mint tronic membership erc721 to sample userAddress
        // which returns tokenbound account address for user's minted token id
        (address tba,) = tronicMainContract.mintBrandLoyaltyToken(userAddress, brandXId);

        vm.stopBroadcast();
    }
}
