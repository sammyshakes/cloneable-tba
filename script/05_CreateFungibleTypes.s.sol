// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract CreateFungibleTypes is Script {
    string public FungibleURI1X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_1");
    string public FungibleURI2X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_2");
    // string public FungibleURI3X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_3");

    // string public FungibleURI1Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_1");
    // string public FungibleURI2Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_2");
    // string public FungibleURI3Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_3");

    address public tronicMainContractAddress = vm.envAddress("TRONIC_MAIN_PROXY_ADDRESS");

    //brand Id to create fungible token types for
    uint256 brandId = vm.envUint("BRAND_X_ID");

    // this script clones an erc1155 token for a membership x and membership y
    function run() external {
        uint256 adminPrivateKey = uint256(vm.envBytes32("TRONIC_ADMIN_PRIVATE_KEY"));
        TronicMain tronicMainContract = TronicMain(tronicMainContractAddress);

        vm.startBroadcast(adminPrivateKey);

        //create fungible achievement token types for brand id
        bool isReward = false;
        tronicMainContract.createFungibleTokenType(brandId, 1_000_000, FungibleURI1X, isReward);

        //create fungible reward token types for brand id
        isReward = true;
        tronicMainContract.createFungibleTokenType(brandId, 1_000_000, FungibleURI2X, isReward);

        vm.stopBroadcast();
    }
}
