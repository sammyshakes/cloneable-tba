// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/CloneFactory.sol";

contract NewProjectEntry is Script {
    // Deployments
    CloneFactory public cloneFactory;
    ERC721CloneableTBA public erc721;

    string public nameX = "Project X Clone ERC1155";
    string public symbolX = "PX1155";

    string public nameY = "Project Y Clone ERC1155";
    string public symbolY = "PY1155";

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

        //deploy partner x
        cloneFactory.deployPartner(
            tronicAddress, "Project X", "PRJX", erc721URIX, nameX, symbolX, erc115BaseURIX
        );

        //deploy partner y
        cloneFactory.deployPartner(
            tronicAddress, "Project Y", "PRJY", erc721URIY, nameY, symbolY, erc115BaseURIY
        );

        vm.stopBroadcast();
    }
}
