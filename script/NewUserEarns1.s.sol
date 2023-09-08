// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMembership.sol";

contract NewUserEarns1 is Script {
    // Deployments
    TronicMembership public erc721X;
    TronicMembership public erc721Y;

    address payable public tbaAddress = payable(vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public clonedERC721AddressX = vm.envAddress("MEMBERSHIP_X_ERC721_ADDRESS");
    address public clonedERC721AddressY = vm.envAddress("MEMBERSHIP_Y_ERC721_ADDRESS");

    // this script mints an erc721 token to the tbaAddress address for each project,
    // which will be used to mint a tokenbound nft for each project
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        // get project contracts
        erc721X = TronicMembership(clonedERC721AddressX);
        erc721Y = TronicMembership(clonedERC721AddressY);

        vm.startBroadcast(deployerPrivateKey);

        //mint erc721 to tbaAddress for project x
        erc721X.mint(tbaAddress);

        //mint erc721 to tbaAddress for project y
        erc721Y.mint(tbaAddress);

        vm.stopBroadcast();
    }
}
