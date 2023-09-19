// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract ERC721Test is TronicTestBase {
    function testMinting721() public {
        console.log("SETUP - tokenbound account address: ", defaultTBAImplementationAddress);
        console.log("SETUP - Tronic erc721 token address: ", address(tronicERC721));
        console.log("SETUP - Tronic erc1155 token address: ", address(tronicERC1155));
        console.log("SETUP - registry address: ", registryAddress);

        // Mint test token
        vm.prank(address(tronicAdminContract));
        //tokenids 1-4 were already minted in the setup function to users 1-4
        uint256 tokenId = 2;

        assertEq(tronicERC721.ownerOf(tokenId), user2);

        // get tba address for token from tronicERC721 contract
        address tba = tronicERC721.getTBAccount(tokenId);
        console.log("tokenbound account created: ", tba);

        //deployed tba
        IERC6551Account tbaAccount = IERC6551Account(payable(address(tba)));

        // user1 should own tokenbound account
        assertEq(tbaAccount.owner(), user2);

        console.log("token owner: ", tronicERC721.ownerOf(tokenId));
        console.log("tbaAccount owner: ", tbaAccount.owner());

        //transfer token to another user
        vm.prank(user2);
        tronicERC721.transferFrom(user2, user3, tokenId);

        //user1 should own token and therefore control tba
        assertEq(tronicERC721.ownerOf(tokenId), user3);
        assertEq(tbaAccount.owner(), user3);
    }

    // test admin functions
    function testAdmin721() public {
        // console tronicERC721 owner
        console.log("tronicERC721 owner: ", tronicERC721.owner());

        // add admin
        vm.prank(tronicAdmin);
        tronicERC721.addAdmin(user1);
        assertEq(tronicERC721.isAdmin(user1), true);

        // remove admin
        vm.prank(tronicAdmin);
        tronicERC721.removeAdmin(user1);
        assertEq(tronicERC721.isAdmin(user1), false);
    }

    function testMembershipTiers() public {}

    function testAdminMembershipTierControls() public {
        // 1. Test that an admin can control membership tiers correctly
        // (Add tests here that check that admins can control tiers correctly)

        // 2. Test that a non-admin cannot control membership tiers
        // (Add tests here that check non-admins cannot control tiers)
    }
}
