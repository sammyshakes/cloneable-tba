// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract MembershipConfig is Script {
    string public FungibleURI1X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_1");
    // string public FungibleURI2X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_2");
    // string public FungibleURI3X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_3");

    // string public FungibleURI1Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_1");
    // string public FungibleURI2Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_2");
    // string public FungibleURI3Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_3");

    address public tronicMainContractAddress = vm.envAddress("TRONIC_MAIN_CONTRACT_ADDRESS");

    // Membership Loyalty Token adresses
    address public tokenXAddress = vm.envAddress("MEMBERSHIP_X_ERC1155_ADDRESS");
    address public tokenYAddress = vm.envAddress("MEMBERSHIP_Y_ERC1155_ADDRESS");

    // this script clones an erc1155 token for a membership x and membership y
    function run() external {
        uint256 adminPrivateKey = vm.envUint("TRONIC_ADMIN_PRIVATE_KEY");

        // TronicToken tokenX = TronicToken(tokenXAddress);
        // TronicToken tokenY = TronicToken(tokenYAddress);
        TronicMain tronicMainContract = TronicMain(tronicMainContractAddress);

        vm.startBroadcast(adminPrivateKey);
        tronicMainContract.createFungibleTokenType(1_000_000, FungibleURI1X, 0);

        //create fungible token types
        // tokenX.createFungibleType(1_000_000, FungibleURI1X);
        // tokenX.createFungibleType(500_000, FungibleURI2X);
        // tokenX.createFungibleType(250_000, FungibleURI3X);

        // tokenY.createFungibleType(10_000_000, FungibleURI1Y);
        // tokenY.createFungibleType(5_000_000, FungibleURI2Y);
        // tokenY.createFungibleType(2_000_000, FungibleURI3Y);

        vm.stopBroadcast();
    }
}
