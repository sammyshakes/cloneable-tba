// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";

//This script deploys the clone factory and initializes the erc721 token
contract Initialize is Script, Test {
    // Deployments
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public erc1155;

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public erc721Address = vm.envAddress("ERC721_CLONEABLE_ADDRESS");
    address public erc1155Address = vm.envAddress("ERC1155_CLONEABLE_ADDRESS");
    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    string public baseURI = vm.envString("ERC721_BASE_URI");
    string public erc1155BaseURI = vm.envString("TRONIC_FUNGIBLE_BASE_URI");
    string public tronicFungibleUri1 = vm.envString("TRONIC_FUNGIBLE_URI_1");
    string public tronicFungibleUri2 = vm.envString("TRONIC_FUNGIBLE_URI_2");
    string public tronicFungibleUri3 = vm.envString("TRONIC_FUNGIBLE_URI_3");
    string public tronicFungibleUri4 = vm.envString("TRONIC_FUNGIBLE_URI_4");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        erc721 = ERC721CloneableTBA(erc721Address);
        erc1155 = ERC1155Cloneable(erc1155Address);

        vm.startBroadcast(deployerPrivateKey);

        //initialize erc721 for tronic member nfts
        erc721.initialize(tbaAddress, registryAddress, "TronClub", "TRNC", baseURI, tronicAddress);
        //initialize erc1155 for tronic loyalty points
        erc1155.initialize(erc1155BaseURI, tronicAddress, "TRC CLUB POINTS", "TRCP");

        //create fungible token types for tronic
        erc1155.createFungibleType(1, tronicFungibleUri1);
        erc1155.createFungibleType(2, tronicFungibleUri2);
        erc1155.createFungibleType(3, tronicFungibleUri3);
        erc1155.createFungibleType(4, tronicFungibleUri4);

        vm.stopBroadcast();
    }
}
