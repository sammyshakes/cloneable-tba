// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract TokenboundAccountTest is TronicTestBase {
    function testBasicTBA() public {
        console.log("SETUP - tokenbound account address: ", defaultTBAImplementationAddress);
        console.log("SETUP -  brand x Loyalty token address: ", address(brandLoyaltyX));
        console.log("SETUP - Tronic erc1155 token address: ", address(tronicToken));
        console.log("SETUP - registry address: ", registryAddress);

        // Mint test token
        vm.prank(address(tronicMainContract));
        //tokenid 1 was already minted in the setup function
        uint256 tokenId = 2;
        assertEq(brandLoyaltyX.ownerOf(tokenId), user2);

        // get tba address for token from tronicERC721 contract
        address tba = brandLoyaltyX.getTBAccount(tokenId);
        console.log("tokenbound account created: ", tba);
        //deployed tba
        IERC6551Account tbaAccount = IERC6551Account(payable(address(tba)));

        // user2 should own tokenbound account
        assertEq(tbaAccount.owner(), user2);

        console.log("token owner: ", brandLoyaltyX.ownerOf(tokenId));
        console.log("tbaAccount owner: ", tbaAccount.owner());

        //transfer token to another user
        vm.prank(user2);
        brandLoyaltyX.transferFrom(user2, user3, tokenId);

        //user3 should own token and therefore control tba
        assertEq(brandLoyaltyX.ownerOf(tokenId), user3);
        assertEq(tbaAccount.owner(), user3);

        //get totalSupply
        console.log("total supply: ", brandLoyaltyX.totalSupply());

        //burn token
        vm.prank(tronicAdmin);
        brandLoyaltyX.burn(tokenId);

        //get totalSupply
        console.log("total supply: ", brandLoyaltyX.totalSupply());
    }
}
