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
    TronicMembership public tronicMembership;
    TronicToken public tronicToken;

    // max Supply
    uint256 public maxSupply = 10_000;

    // is bound
    bool public bound = false;

    //max tiers
    uint8 public maxTiers = 10;

    address public tronicAdminAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public tronicMembershipAddress = vm.envAddress("TRONIC_MEMBERSHIP_ERC721_ADDRESS");
    address public tronicTokenAddress = vm.envAddress("TRONIC_TOKEN_ERC1155_ADDRESS");
    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    string public baseURI = vm.envString("ERC721_BASE_URI");
    string public tronicFungibleUri1 = vm.envString("TRONIC_FUNGIBLE_URI_1");
    string public tronicFungibleUri2 = vm.envString("TRONIC_FUNGIBLE_URI_2");
    string public tronicFungibleUri3 = vm.envString("TRONIC_FUNGIBLE_URI_3");
    string public tronicFungibleUri4 = vm.envString("TRONIC_FUNGIBLE_URI_4");

    string public tronicMembershipName = "Tronic Membership Program";
    string public tronicMembershipSymbol = "TRONIC";

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("TRONIC_DEPLOYER_PRIVATE_KEY");

        tronicMembership = TronicMembership(tronicMembershipAddress);
        tronicToken = TronicToken(tronicTokenAddress);

        vm.startBroadcast(deployerPrivateKey);

        //initialize erc721 for tronic member nfts
        tronicMembership.initialize(
            tbaAddress,
            registryAddress,
            tronicMembershipName,
            tronicMembershipSymbol,
            baseURI,
            maxTiers,
            maxSupply,
            false, //not elastic
            bound,
            tronicAdminAddress
        );
        //initialize erc1155 for tronic token points
        tronicToken.initialize(tronicAdminAddress);

        //create fungible token types for tronic
        tronicToken.createFungibleType(1_000_000, tronicFungibleUri1); //typeId = 1
        tronicToken.createFungibleType(500_000, tronicFungibleUri2); //typeId = 2
        tronicToken.createFungibleType(250_000, tronicFungibleUri3); //typeId = 3
        tronicToken.createFungibleType(125_000, tronicFungibleUri4); //typeId = 4

        vm.stopBroadcast();
    }
}
