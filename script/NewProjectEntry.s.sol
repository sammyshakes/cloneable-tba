// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/CloneFactory.sol";

contract NewProjectEntry is Script {
    // Deployments
    CloneFactory public cloneFactory;
    ERC721CloneableTBA public erc721;

    string public name = "Project X Clone ERC1155";
    string public symbol = "PX1155";

    // erc721 token uris
    string public erc721URIX = vm.envString("PROJECT_X_ERC721_BASE_URI");
    string public erc721URIY = vm.envString("PROJECT_Y_ERC721_BASE_URI");

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public cloneFactoryAddress = vm.envAddress("CLONE_FACTORY_ADDRESS");

    string public erc115BaseURIX = vm.envString("PROJECT_X_ERC1155_BASE_URI");
    string public erc115BaseURIY = vm.envString("PROJECT_Y_ERC1155_BASE_URI");

    string public erc115FungibleURI1X = vm.envString("PROJECT_X_FUNGIBLE_URI_1");
    string public erc115FungibleURI2X = vm.envString("PROJECT_X_FUNGIBLE_URI_2");
    string public erc115FungibleURI3X = vm.envString("PROJECT_X_FUNGIBLE_URI_3");

    string public erc115FungibleURI1Y = vm.envString("PROJECT_Y_FUNGIBLE_URI_1");
    string public erc115FungibleURI2Y = vm.envString("PROJECT_Y_FUNGIBLE_URI_2");
    string public erc115FungibleURI3Y = vm.envString("PROJECT_Y_FUNGIBLE_URI_3");

    // this script clones an erc1155 token for a partner x and partner y
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        cloneFactory = CloneFactory(cloneFactoryAddress);

        vm.startBroadcast(deployerPrivateKey);

        //deploy partner x clone erc721
        cloneFactory.cloneERC721("Project X", "PRJX", erc721URIX, tronicAddress);

        //deploy partner y clone erc721
        cloneFactory.cloneERC721("Project Y", "PRJY", erc721URIY, tronicAddress);

        //deploy partner x clone erc1155
        address erc1155cloneX =
            cloneFactory.cloneERC1155(erc115BaseURIX, tronicAddress, name, symbol);

        //deploy partner y clone erc1155
        address erc1155cloneY =
            cloneFactory.cloneERC1155(erc115BaseURIY, tronicAddress, name, symbol);

        //create token types
        ERC1155Cloneable(erc1155cloneX).createFungibleType(1, erc115FungibleURI1X);
        ERC1155Cloneable(erc1155cloneX).createFungibleType(2, erc115FungibleURI2X);
        ERC1155Cloneable(erc1155cloneX).createFungibleType(3, erc115FungibleURI3X);

        ERC1155Cloneable(erc1155cloneY).createFungibleType(1, erc115FungibleURI1Y);
        ERC1155Cloneable(erc1155cloneY).createFungibleType(2, erc115FungibleURI2Y);
        ERC1155Cloneable(erc1155cloneY).createFungibleType(3, erc115FungibleURI3Y);

        vm.stopBroadcast();
    }
}
