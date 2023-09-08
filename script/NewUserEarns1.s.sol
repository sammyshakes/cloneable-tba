// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMembership.sol";

contract NewUserEarns1 is Script {
    // Deployments
    TronicMembership public membershipX;
    TronicMembership public membershipY;

    address payable public tbaAddress = payable(vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public membershipAddressX = vm.envAddress("MEMBERSHIP_X_ERC721_ADDRESS");
    address public membershipAddressY = vm.envAddress("MEMBERSHIP_Y_ERC721_ADDRESS");

    // this script mints an erc721 token to the tbaAddress address for each project,
    // which will be used to mint a tokenbound nft for each project
    function run() external {
        uint256 adminPrivateKey = vm.envUint("TRONIC_ADMIN_PRIVATE_KEY");

        // get project contracts
        membershipX = TronicMembership(membershipAddressX);
        membershipY = TronicMembership(membershipAddressY);

        vm.startBroadcast(adminPrivateKey);

        //mint membership to tbaAddress for project x
        membershipX.mint(tbaAddress);

        //mint membership to tbaAddress for project y
        membershipY.mint(tbaAddress);

        vm.stopBroadcast();
    }
}
