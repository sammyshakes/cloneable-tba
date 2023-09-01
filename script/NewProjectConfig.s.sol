// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC1155Cloneable.sol";

contract NewProjectConfig is Script {
    string public erc115FungibleURI1X = vm.envString("PARTNER_X_FUNGIBLE_URI_1");
    string public erc115FungibleURI2X = vm.envString("PARTNER_X_FUNGIBLE_URI_2");
    string public erc115FungibleURI3X = vm.envString("PARTNER_X_FUNGIBLE_URI_3");

    string public erc115FungibleURI1Y = vm.envString("PARTNER_Y_FUNGIBLE_URI_1");
    string public erc115FungibleURI2Y = vm.envString("PARTNER_Y_FUNGIBLE_URI_2");
    string public erc115FungibleURI3Y = vm.envString("PARTNER_Y_FUNGIBLE_URI_3");

    // erc1155 clone adress
    address public erc1155CloneX = vm.envAddress("PARTNER_X_CLONED_ERC1155_ADDRESS");
    address public erc1155CloneY = vm.envAddress("PARTNER_Y_CLONED_ERC1155_ADDRESS");

    // this script clones an erc1155 token for a partner x and partner y
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        //create fungible token types
        ERC1155Cloneable(erc1155CloneX).createFungibleType(1_000_000, erc115FungibleURI1X);
        ERC1155Cloneable(erc1155CloneX).createFungibleType(500_000, erc115FungibleURI2X);
        ERC1155Cloneable(erc1155CloneX).createFungibleType(250_000, erc115FungibleURI3X);

        ERC1155Cloneable(erc1155CloneY).createFungibleType(10_000_000, erc115FungibleURI1Y);
        ERC1155Cloneable(erc1155CloneY).createFungibleType(5_000_000, erc115FungibleURI2Y);
        ERC1155Cloneable(erc1155CloneY).createFungibleType(2_000_000, erc115FungibleURI3Y);

        vm.stopBroadcast();
    }
}
