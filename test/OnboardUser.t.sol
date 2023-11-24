// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract OnboardUser is TronicTestBase {
    function testOnboarding() public {
        console.log(
            "SETUP - Default tokenbound account implementation address: ",
            defaultTBAImplementationAddress
        );
        console.log(
            "SETUP - Tronic Member ERC721 address: ", address(tronicBrandLoyaltyImplementation)
        );
        console.log("SETUP - Tronic Token ERC1155 address: ", address(tronicToken));

        //these users are created in the setup function
        //they have tronic memberships and can start subscribing to memberships
        console.log("tronicTokenId1TBA: ", tronicTokenId1TBA);
        console.log("tronicTokenId2TBA: ", tronicTokenId2TBA);
        console.log("tronicTokenId3TBA: ", tronicTokenId3TBA);
        console.log("tronicTokenId4TBA: ", tronicTokenId4TBA);

        // verify that users have tronic membership nfts
        assertEq(tronicBrandLoyaltyImplementation.ownerOf(1), user1);
        assertEq(tronicBrandLoyaltyImplementation.ownerOf(2), user2);
        assertEq(tronicBrandLoyaltyImplementation.ownerOf(3), user3);
        assertEq(tronicBrandLoyaltyImplementation.ownerOf(4), user4);

        IERC6551Account tokenId1TronicTBA = IERC6551Account(payable(address(tronicTokenId1TBA)));
        IERC6551Account tokenId2TronicTBA = IERC6551Account(payable(address(tronicTokenId2TBA)));
        IERC6551Account tokenId3TronicTBA = IERC6551Account(payable(address(tronicTokenId3TBA)));
        IERC6551Account tokenId4TronicTBA = IERC6551Account(payable(address(tronicTokenId4TBA)));

        // verify that users have tokenbound accounts
        assertEq(tokenId1TronicTBA.owner(), user1);
        assertEq(tokenId2TronicTBA.owner(), user2);
        assertEq(tokenId3TronicTBA.owner(), user3);
        assertEq(tokenId4TronicTBA.owner(), user4);

        //verify tba account addresses are correct
        assertEq(tronicBrandLoyaltyImplementation.getTBAccount(1), address(tokenId1TronicTBA));
        assertEq(tronicBrandLoyaltyImplementation.getTBAccount(2), address(tokenId2TronicTBA));
        assertEq(tronicBrandLoyaltyImplementation.getTBAccount(3), address(tokenId3TronicTBA));
        assertEq(tronicBrandLoyaltyImplementation.getTBAccount(4), address(tokenId4TronicTBA));

        // users subscribe to membershipX
        // membershipX mints a membership token to user's tronic tba
        vm.startPrank(address(tronicMainContract));
        (address membershipXTokenId1TBA,) = brandLoyaltyX.mint(address(tokenId1TronicTBA));
        (address membershipXTokenId2TBA,) = brandLoyaltyX.mint(address(tokenId2TronicTBA));
        (address membershipXTokenId3TBA,) = brandLoyaltyX.mint(address(tokenId3TronicTBA));
        (address membershipXTokenId4TBA,) = brandLoyaltyX.mint(address(tokenId4TronicTBA));

        // verify that users' tronic TBAs have membershipX nfts
        assertEq(brandLoyaltyX.ownerOf(1), address(tokenId1TronicTBA));
        assertEq(brandLoyaltyX.ownerOf(2), address(tokenId2TronicTBA));
        assertEq(brandLoyaltyX.ownerOf(3), address(tokenId3TronicTBA));
        assertEq(brandLoyaltyX.ownerOf(4), address(tokenId4TronicTBA));

        // verify tba account addresses are correct
        assertEq(membershipXTokenId1TBA, brandLoyaltyX.getTBAccount(1));
        assertEq(membershipXTokenId2TBA, brandLoyaltyX.getTBAccount(2));
        assertEq(membershipXTokenId3TBA, brandLoyaltyX.getTBAccount(3));
        assertEq(membershipXTokenId4TBA, brandLoyaltyX.getTBAccount(4));

        // membershipX mints loyalty tokens to user's membershipx tba
        brandXToken.mintFungible(membershipXTokenId1TBA, fungibleTypeIdX1, 1000);
        brandXToken.mintFungible(membershipXTokenId2TBA, fungibleTypeIdX1, 1000);
        brandXToken.mintFungible(membershipXTokenId3TBA, fungibleTypeIdX1, 1000);
        brandXToken.mintFungible(membershipXTokenId4TBA, fungibleTypeIdX1, 1000);

        // verify that users' membershipX TBAs have loyalty tokens
        assertEq(
            brandXToken.balanceOf(membershipXTokenId1TBA, fungibleTypeIdX1),
            1000,
            "user1 should have 1000"
        );

        assertEq(
            brandXToken.balanceOf(membershipXTokenId2TBA, fungibleTypeIdX1),
            1000,
            "user2 should have 1000"
        );

        assertEq(
            brandXToken.balanceOf(membershipXTokenId3TBA, fungibleTypeIdX1),
            1000,
            "user3 should have 1000"
        );

        assertEq(
            brandXToken.balanceOf(membershipXTokenId4TBA, fungibleTypeIdX1),
            1000,
            "user4 should have 1000"
        );

        vm.stopPrank();

        //Transfer erc1155 tokens from nested membership TBA
        //TronicMain contract must be an approved user for tronic tba
        //we wil also approve the tronic admin address
        address[] memory approved = new address[](2);
        approved[0] = address(tronicMainContract);
        approved[1] = tronicAdmin;
        bool[] memory approvedValues = new bool[](2);
        approvedValues[0] = true;
        approvedValues[1] = true;

        vm.prank(user1);
        tokenId1TronicTBA.setPermissions(approved, approvedValues);

        // expect revert for unauthorized user
        vm.prank(unauthorizedUser);
        vm.expectRevert();
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            1, brandIDX, 1, membershipXTokenId2TBA, fungibleTypeIdX1, 500
        );

        //expect revert for invalid membership id
        vm.prank(user1);
        vm.expectRevert();
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            1, 3, 1, membershipXTokenId2TBA, fungibleTypeIdX1, 500
        );

        vm.prank(user1);
        // transfer loyalty tokens from user1's member tba to user2's member tba
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            1, membershipIDX, 1, membershipXTokenId2TBA, fungibleTypeIdX1, 500
        );

        // verify that user1 has 500 loyalty tokens
        assertEq(
            brandXToken.balanceOf(membershipXTokenId1TBA, fungibleTypeIdX1),
            500,
            "user1 should have 500"
        );

        // verify that user2 has 500 loyalty tokens
        assertEq(
            brandXToken.balanceOf(membershipXTokenId2TBA, fungibleTypeIdX1),
            1500,
            "user2 should have 1500"
        );

        //perform same transfer but from an approved caller other than user1
        vm.prank(tronicAdmin);
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            1, membershipIDX, 1, membershipXTokenId2TBA, fungibleTypeIdX1, 500
        );

        // verify that user1 has 0 loyalty tokens
        assertEq(
            brandXToken.balanceOf(membershipXTokenId1TBA, fungibleTypeIdX1),
            0,
            "user1 should have 0"
        );

        // verify that user2 has 2000 loyalty tokens
        assertEq(
            brandXToken.balanceOf(membershipXTokenId2TBA, fungibleTypeIdX1),
            2000,
            "user2 should have 2000"
        );

        // approve tronic admin and tronic main contract for user2's membership tba
        vm.prank(user2);
        tokenId2TronicTBA.setPermissions(approved, approvedValues);

        //attempt to transfer from unauthorized user
        vm.prank(unauthorizedUser);
        vm.expectRevert();
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(2, membershipIDX, 2, user5);

        //attempt to transfer with invalid membership id
        vm.prank(user2);
        vm.expectRevert();
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(2, 3, 2, user5);

        // transfer user2's membershipX nft to user5
        vm.prank(user2);
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(2, membershipIDX, 2, user5);

        // verify that user5 has membershipX nft
        assertEq(brandLoyaltyX.ownerOf(2), user5);

        // verify that user5 has 2000 loyalty tokens
        assertEq(
            brandXToken.balanceOf(membershipXTokenId2TBA, fungibleTypeIdX1),
            2000,
            "user5 should have 2000"
        );

        // test transferTokensFromTronicTBA function
        //create a fungible type for tronicToken
        vm.startPrank(address(tronicMainContract));
        uint256 typeId = tronicToken.createFungibleType(1_000_000, "testFungibleURI");
        //mint fungible tokens to user1's tronic tba
        tronicToken.mintFungible(address(tokenId1TronicTBA), typeId, 1000);
        //verify that user5 has 1000 fungible tokens
        assertEq(
            tronicToken.balanceOf(address(tokenId1TronicTBA), typeId),
            1000,
            "user1 should have 1000"
        );

        vm.stopPrank();

        //attempt to transfer from unauthorized user
        vm.prank(unauthorizedUser);
        vm.expectRevert();
        tronicMainContract.transferTokensFromTronicTBA(1, typeId, 500, address(tokenId2TronicTBA));

        // transfer loyalty tokens from user1's member tba to user2's member tba
        vm.prank(user1);
        tronicMainContract.transferTokensFromTronicTBA(1, typeId, 500, address(tokenId2TronicTBA));

        // verify that user1 has 500 loyalty tokens
        assertEq(
            tronicToken.balanceOf(address(tokenId1TronicTBA), typeId), 500, "user1 should have 500"
        );

        // verify that user2 has 500 loyalty tokens
        assertEq(
            tronicToken.balanceOf(address(tokenId2TronicTBA), typeId), 500, "user2 should have 500"
        );

        //perform same transfer but from an approved caller other than user1
        vm.prank(tronicAdmin);
        tronicMainContract.transferTokensFromTronicTBA(1, typeId, 500, address(tokenId2TronicTBA));

        // verify that user1 has 0 loyalty tokens
        assertEq(
            tronicToken.balanceOf(address(tokenId1TronicTBA), typeId), 0, "user1 should have 0"
        );

        // verify that user2 has 2000 loyalty tokens
        assertEq(
            tronicToken.balanceOf(address(tokenId2TronicTBA), typeId),
            1000,
            "user2 should have 1000"
        );

        //user tries to transfer tronicBrandLoyaltyImplementation with safetransferfrom
        vm.prank(user1);
        tronicBrandLoyaltyImplementation.safeTransferFrom(user1, user2, 1, "");
    }
}
