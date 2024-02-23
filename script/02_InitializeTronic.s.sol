// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Imports
import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/TronicBrandLoyalty.sol";
import "../src/TronicMembership.sol";
import "../src/TronicToken.sol";

// THIS SCRIPT DISABLED BECAUSE WE WILL NOT BE INITIALIZING THE CONTRACTS IN THE SCRIPT DIRECTLY

//This script deploys the clone factory and initializes the erc721 token
contract InitializeTronic is Script {
// // Deployments
// TronicBrandLoyalty public tronicBrandLoyalty;
// TronicMembership public tronicMembership;
// TronicToken public tronicToken;

// uint256 public maxSupply = 10_000;
// bool public bound = false;
// uint8 public maxTiers = 10;

// address public tronicAdminAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
// address public tronicBrandLoyaltyAddress = vm.envAddress("TRONIC_BRAND_LOYALTY_ADDRESS");
// address public tronicMembershipAddress = vm.envAddress("TRONIC_MEMBERSHIP_ERC721_ADDRESS");
// address public tronicTokenAddress = vm.envAddress("TRONIC_TOKEN_ERC1155_ADDRESS");
// address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
// address payable public tbaAddress =
//     payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

// string public baseURI = vm.envString("ERC721_BASE_URI");
// string public tronicFungibleUri1 = vm.envString("TRONIC_FUNGIBLE_URI_1");
// string public tronicFungibleUri2 = vm.envString("TRONIC_FUNGIBLE_URI_2");
// string public tronicFungibleUri3 = vm.envString("TRONIC_FUNGIBLE_URI_3");
// string public tronicFungibleUri4 = vm.envString("TRONIC_FUNGIBLE_URI_4");

// string public tronicBrandLoyaltyName = "Tronic Brand Loyalty Program";
// string public tronicBrandLoyaltySymbol = "TRONIC";

// string public tronicMembershipName = "Tronic Membership Program";
// string public tronicMembershipSymbol = "TRONIC";

// function run() external {
//     uint256 deployerPrivateKey = uint256(vm.envBytes32("TRONIC_DEPLOYER_PRIVATE_KEY"));

//     tronicBrandLoyalty = TronicBrandLoyalty(tronicBrandLoyaltyAddress);
//     tronicMembership = TronicMembership(tronicMembershipAddress);
//     tronicToken = TronicToken(tronicTokenAddress);

//     vm.startBroadcast(deployerPrivateKey);

//     //initialize brand loyalty
//     tronicBrandLoyalty.initialize(
//         tbaAddress,
//         registryAddress,
//         tronicBrandLoyaltyName,
//         tronicBrandLoyaltySymbol,
//         baseURI,
//         bound,
//         tronicAdminAddress
//     );

//     //initialize erc721 for tronic member nfts
//     tronicMembership.initialize(
//         tronicMembershipName,
//         tronicMembershipSymbol,
//         baseURI,
//         maxSupply,
//         false, //not elastic
//         maxTiers,
//         tronicAdminAddress
//     );
//     //initialize erc1155 for tronic token points
//     tronicToken.initialize(tronicAdminAddress);

//     //create fungible token types for tronic
//     tronicToken.createFungibleType(1_000_000, tronicFungibleUri1); //typeId = 1
//     tronicToken.createFungibleType(500_000, tronicFungibleUri2); //typeId = 2
//     tronicToken.createFungibleType(250_000, tronicFungibleUri3); //typeId = 3
//     tronicToken.createFungibleType(125_000, tronicFungibleUri4); //typeId = 4

//     vm.stopBroadcast();
// }
}
