// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicLoyalty.sol";

contract MembershipConfig is Script {
    string public erc115FungibleURI1X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_1");
    string public erc115FungibleURI2X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_2");
    string public erc115FungibleURI3X = vm.envString("MEMBERSHIP_X_FUNGIBLE_URI_3");

    string public erc115FungibleURI1Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_1");
    string public erc115FungibleURI2Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_2");
    string public erc115FungibleURI3Y = vm.envString("MEMBERSHIP_Y_FUNGIBLE_URI_3");

    // erc1155 clone adress
    address public erc1155CloneX = vm.envAddress("MEMBERSHIP_X_CLONED_ERC1155_ADDRESS");
    address public erc1155CloneY = vm.envAddress("MEMBERSHIP_Y_CLONED_ERC1155_ADDRESS");

    // this script clones an erc1155 token for a membership x and membership y
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        //create fungible token types
        TronicLoyalty(erc1155CloneX).createFungibleType(1_000_000, erc115FungibleURI1X);
        TronicLoyalty(erc1155CloneX).createFungibleType(500_000, erc115FungibleURI2X);
        TronicLoyalty(erc1155CloneX).createFungibleType(250_000, erc115FungibleURI3X);

        TronicLoyalty(erc1155CloneY).createFungibleType(10_000_000, erc115FungibleURI1Y);
        TronicLoyalty(erc1155CloneY).createFungibleType(5_000_000, erc115FungibleURI2Y);
        TronicLoyalty(erc1155CloneY).createFungibleType(2_000_000, erc115FungibleURI3Y);

        vm.stopBroadcast();
    }
}
