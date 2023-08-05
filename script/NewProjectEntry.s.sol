// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Imports
import "forge-std/Script.sol";
import "../src/CloneFactory.sol";
import "../src/ERC721CloneableTBA.sol";

contract NewProjectEntry is Script {
    // Deployments
    CloneFactory public cloneFactory;
    ERC721CloneableTBA public erc721;

    string public name = "Project X Clone ERC1155";
    string public symbol = "PX1155";

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public cloneFactoryAddress = vm.envAddress("CLONE_FACTORY_ADDRESS");

    string public erc115BaseURI = vm.envString("PROJECT_X_ERC1155_BASE_URI");

    string public erc115FungibleURI1 = vm.envString("PROJECT_X_FUNGIBLE_URI_1");
    string public erc115FungibleURI2 = vm.envString("PROJECT_X_FUNGIBLE_URI_2");
    string public erc115FungibleURI3 = vm.envString("PROJECT_X_FUNGIBLE_URI_3");

    // this script clones an erc1155 token for a partner
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        cloneFactory = CloneFactory(cloneFactoryAddress);

        vm.startBroadcast(deployerPrivateKey);

        //deploy partner clone erc1155
        address erc1155clone = cloneFactory.cloneERC1155(erc115BaseURI, tronicAddress, name, symbol);

        //create token types
        ERC1155Cloneable(erc1155clone).createFungibleType(1, erc115FungibleURI1);
        ERC1155Cloneable(erc1155clone).createFungibleType(2, erc115FungibleURI2);
        ERC1155Cloneable(erc1155clone).createFungibleType(3, erc115FungibleURI3);

        vm.stopBroadcast();
    }
}
