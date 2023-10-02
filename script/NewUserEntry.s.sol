// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMembership.sol";
import "../src/TronicToken.sol";

contract NewUserEntry is Script {
    // Deployments
    TronicMembership public tronicMembership;
    TronicToken public tronicToken;

    address public tronicMembershipAddress = vm.envAddress("TRONIC_MEMBERSHIP_ERC721_ADDRESS");
    address public tronicTokenAddress = vm.envAddress("TRONIC_TOKEN_ERC1155_ADDRESS");

    address public userAddress = vm.envAddress("SAMPLE_USER1_ADDRESS");

    // this script mints an erc721 token to the user address
    function run() external {
        tronicMembership = TronicMembership(tronicMembershipAddress);
        tronicToken = TronicToken(tronicTokenAddress);

        uint256 adminPrivateKey = vm.envUint("TRONIC_ADMIN_PRIVATE_KEY");

        vm.startBroadcast(adminPrivateKey);

        //mint tronic membership erc721 to sample userAddress
        // which returns tokenbound account address for user's minted token id
        (address tba,) = tronicMembership.mint(userAddress);

        // let's also mint 1000 tronic loyalty tokens (token typeID = 1) to the new tba
        //note: for fungible types, the token ID = typeId
        tronicToken.mintFungible(tba, 1, 1000);

        vm.stopBroadcast();
    }
}
