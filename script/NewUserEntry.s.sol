// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";

contract NewUserEntry is Script {
    // Deployments
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public erc1155Clone;

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public clonedERC1155Address = vm.envAddress("CLONED_ERC1155_ADDRESS");
    address public erc721Address = vm.envAddress("ERC721_CLONEABLE_ADDRESS");
    address payable public tbaAddress = payable(vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1"));

    string public erc115BaseURI = vm.envString("ERC1155_BASE_URI");

    // this script mints an erc721 token to the tronic address and mints 100 of each level of premium token to the tronic address
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        erc721 = ERC721CloneableTBA(erc721Address);
        erc1155Clone = ERC1155Cloneable(clonedERC1155Address);

        vm.startBroadcast(deployerPrivateKey);

        //mint erc721 to tronic address (tronic will also be our first user for demo purposes)
        erc721.mint(tronicAddress, 1);

        //mint 100 level 1 premium tokens to tronic address
        ERC1155Cloneable(erc1155Clone).mintFungible(tbaAddress, 1, 100);

        //mint 100 level 2 premium tokens to tronic address
        ERC1155Cloneable(erc1155Clone).mintFungible(tbaAddress, 2, 100);

        //mint 100 level 3 premium tokens to tronic address
        // ERC1155Cloneable(erc1155Clone).mintFungible(tronicAddress, 3, 100);

        vm.stopBroadcast();
    }
}
