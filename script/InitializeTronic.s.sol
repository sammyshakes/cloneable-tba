// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/TronicMembership.sol";
import "../src/TronicToken.sol";

//This script deploys the clone factory and initializes the erc721 token
contract InitializeTronic is Script {
    // Deployments
    TronicMembership public erc721;
    TronicToken public erc1155;

    // max Supply
    uint256 public maxSupply = 10_000;

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public erc721Address = vm.envAddress("TRONIC_MEMBERSHIP_ERC721_ADDRESS");
    address public erc1155Address = vm.envAddress("TRONIC_TOKEN_ERC1155_ADDRESS");
    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    string public baseURI = vm.envString("ERC721_BASE_URI");
    string public erc1155BaseURI = vm.envString("TRONIC_ERC1155_BASE_URI");
    string public tronicFungibleUri1 = vm.envString("TRONIC_FUNGIBLE_URI_1");
    string public tronicFungibleUri2 = vm.envString("TRONIC_FUNGIBLE_URI_2");
    string public tronicFungibleUri3 = vm.envString("TRONIC_FUNGIBLE_URI_3");
    string public tronicFungibleUri4 = vm.envString("TRONIC_FUNGIBLE_URI_4");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        erc721 = TronicMembership(erc721Address);
        erc1155 = TronicToken(erc1155Address);

        vm.startBroadcast(deployerPrivateKey);

        //initialize erc721 for tronic member nfts
        erc721.initialize(
            tbaAddress, registryAddress, "Tronic Members", "TRON", baseURI, maxSupply, tronicAddress
        );
        //initialize erc1155 for tronic token points
        erc1155.initialize(tronicAddress);

        //create fungible token types for tronic
        erc1155.createFungibleType(1_000_000, tronicFungibleUri1);
        erc1155.createFungibleType(500_000, tronicFungibleUri2);
        erc1155.createFungibleType(250_000, tronicFungibleUri3);
        erc1155.createFungibleType(125_000, tronicFungibleUri4);

        vm.stopBroadcast();
    }
}
