// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";

contract NewUserEarns is Script {
    // Deployments
    ERC721CloneableTBA public erc721X;
    ERC1155Cloneable public erc1155CloneX;

    ERC721CloneableTBA public erc721Y;
    ERC1155Cloneable public erc1155CloneY;

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address payable public tbaAddress = payable(vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public clonedERC721AddressX = vm.envAddress("PROJECT_X_CLONED_ERC721_ADDRESS");
    address public clonedERC721AddressY = vm.envAddress("PROJECT_Y_CLONED_ERC721_ADDRESS");

    address public clonedERC1155AddressX = vm.envAddress("PROJECT_X_CLONED_ERC1155_ADDRESS");
    address public clonedERC1155AddressY = vm.envAddress("PROJECT_Y_CLONED_ERC1155_ADDRESS");

    // this script mints an erc721 token to the tronic address and mints 100 of each level of premium token to the tronic address
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        erc721X = ERC721CloneableTBA(clonedERC721AddressX);
        erc721Y = ERC721CloneableTBA(clonedERC721AddressY);

        erc1155CloneX = ERC1155Cloneable(clonedERC1155AddressX);
        erc1155CloneY = ERC1155Cloneable(clonedERC1155AddressY);

        vm.startBroadcast(deployerPrivateKey);

        //mint erc721 to tbaAddress for project x
        address tbaAccountX = erc721X.mint(tbaAddress, 2);

        //mint erc721 to tbaAddress for project y
        address tbaAccountY = erc721Y.mint(tbaAddress, 2);

        //mint 100 level 1 premium tokens to tbaAccountX address
        ERC1155Cloneable(erc1155CloneX).mintFungible(tbaAccountX, 1, 100);

        //mint 50 level 2 premium tokens to tronic address
        ERC1155Cloneable(erc1155CloneX).mintFungible(tbaAccountX, 2, 50);

        //mint 100 level 1 premium tokens to tbaAccountY address
        ERC1155Cloneable(erc1155CloneY).mintFungible(tbaAccountY, 1, 100);

        //mint 50 level 2 premium tokens to tronic address
        ERC1155Cloneable(erc1155CloneY).mintFungible(tbaAccountY, 2, 50);

        //mint 100 level 3 premium tokens to tronic address
        // ERC1155Cloneable(erc1155Clone).mintFungible(tronicAddress, 3, 100);

        vm.stopBroadcast();
    }
}
