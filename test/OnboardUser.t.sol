// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract OnboardUser is TronicTestBase {
    function testOnboarding() public {
        console.log(
            "SETUP - Default tokenbound account implementation address: ",
            defaultTBAImplementationAddress
        );
        console.log("SETUP - Tronic Member ERC721 address: ", address(tronicERC721));
        console.log("SETUP - Tronic Token ERC1155 address: ", address(tronicERC1155));

        //these users are created in the setup function
        //they have tronic memberships and can start subscribing to memberships
        console.log("tronicTokenId1TBA: ", tronicTokenId1TBA);
        console.log("tronicTokenId2TBA: ", tronicTokenId2TBA);
        console.log("tronicTokenId3TBA: ", tronicTokenId3TBA);
        console.log("tronicTokenId4TBA: ", tronicTokenId4TBA);

        // verify that users have tronic membership nfts
        assertEq(tronicERC721.ownerOf(1), user1);
        assertEq(tronicERC721.ownerOf(2), user2);
        assertEq(tronicERC721.ownerOf(3), user3);
        assertEq(tronicERC721.ownerOf(4), user4);

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
        assertEq(tronicERC721.getTBAccount(1), address(tokenId1TronicTBA));
        assertEq(tronicERC721.getTBAccount(2), address(tokenId2TronicTBA));
        assertEq(tronicERC721.getTBAccount(3), address(tokenId3TronicTBA));
        assertEq(tronicERC721.getTBAccount(4), address(tokenId4TronicTBA));

        // users subscribe to membershipX
        // membershipX mints a membership token to user's tronic tba
        vm.startPrank(address(tronicAdminContract));
        address membershipXTokenId1TBA = membershipXERC721.mint(address(tokenId1TronicTBA));
        address membershipXTokenId2TBA = membershipXERC721.mint(address(tokenId2TronicTBA));
        address membershipXTokenId3TBA = membershipXERC721.mint(address(tokenId3TronicTBA));
        address membershipXTokenId4TBA = membershipXERC721.mint(address(tokenId4TronicTBA));

        // verify that users' tronic TBAs have membershipX nfts
        assertEq(membershipXERC721.ownerOf(1), address(tokenId1TronicTBA));
        assertEq(membershipXERC721.ownerOf(2), address(tokenId2TronicTBA));
        assertEq(membershipXERC721.ownerOf(3), address(tokenId3TronicTBA));
        assertEq(membershipXERC721.ownerOf(4), address(tokenId4TronicTBA));

        // verify tba account addresses are correct
        assertEq(membershipXTokenId1TBA, membershipXERC721.getTBAccount(1));
        assertEq(membershipXTokenId2TBA, membershipXERC721.getTBAccount(2));
        assertEq(membershipXTokenId3TBA, membershipXERC721.getTBAccount(3));
        assertEq(membershipXTokenId4TBA, membershipXERC721.getTBAccount(4));

        // membershipX mints loyalty tokens to user's membershipx tba
        membershipXERC1155.mintFungible(membershipXTokenId1TBA, fungibleTypeIdX1, 1000);
        membershipXERC1155.mintFungible(membershipXTokenId2TBA, fungibleTypeIdX1, 1000);
        membershipXERC1155.mintFungible(membershipXTokenId3TBA, fungibleTypeIdX1, 1000);
        membershipXERC1155.mintFungible(membershipXTokenId4TBA, fungibleTypeIdX1, 1000);

        // verify that users' membershipX TBAs have loyalty tokens
        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId1TBA, fungibleTypeIdX1),
            1000,
            "user1 should have 1000"
        );

        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId2TBA, fungibleTypeIdX1),
            1000,
            "user2 should have 1000"
        );

        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId3TBA, fungibleTypeIdX1),
            1000,
            "user3 should have 1000"
        );

        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId4TBA, fungibleTypeIdX1),
            1000,
            "user4 should have 1000"
        );

        vm.stopPrank();

        //TronicMain contract must be an approved user for tronic tba
        //we wil also approve the tronic admin address
        address[] memory approved = new address[](2);
        approved[0] = address(tronicAdminContract);
        approved[1] = tronicAdmin;
        bool[] memory approvedValues = new bool[](2);
        approvedValues[0] = true;
        approvedValues[1] = true;

        vm.prank(user1);
        tokenId1TronicTBA.setPermissions(approved, approvedValues);

        // expect revert for unauthorized user
        vm.prank(unauthorizedUser);
        vm.expectRevert();
        tronicAdminContract.transferTokensFromMembershipTBA(
            1, membershipIDX, 1, membershipXTokenId2TBA, fungibleTypeIdX1, 500
        );

        vm.prank(user1);
        // transfer loyalty tokens from user1's member tba to user2's member tba
        tronicAdminContract.transferTokensFromMembershipTBA(
            1, membershipIDX, 1, membershipXTokenId2TBA, fungibleTypeIdX1, 500
        );

        // verify that user1 has 500 loyalty tokens
        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId1TBA, fungibleTypeIdX1),
            500,
            "user1 should have 500"
        );

        // verify that user2 has 500 loyalty tokens
        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId2TBA, fungibleTypeIdX1),
            1500,
            "user2 should have 1500"
        );

        //perform same transfer but from an approved caller other than user1
        vm.prank(tronicAdmin);
        tronicAdminContract.transferTokensFromMembershipTBA(
            1, membershipIDX, 1, membershipXTokenId2TBA, fungibleTypeIdX1, 500
        );

        // verify that user1 has 0 loyalty tokens
        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId1TBA, fungibleTypeIdX1),
            0,
            "user1 should have 0"
        );

        // verify that user2 has 2000 loyalty tokens
        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId2TBA, fungibleTypeIdX1),
            2000,
            "user2 should have 2000"
        );

        // approve tronic admin and tronic main contract for user2's membership tba
        vm.prank(user2);
        tokenId2TronicTBA.setPermissions(approved, approvedValues);

        // transfer user2's membershipX nft to user5
        vm.prank(user2);
        tronicAdminContract.transferMembershipFromTronicTBA(2, membershipIDX, 2, user5);

        // verify that user5 has membershipX nft
        assertEq(membershipXERC721.ownerOf(2), user5);

        // verify that user5 has 2000 loyalty tokens
        assertEq(
            membershipXERC1155.balanceOf(membershipXTokenId2TBA, fungibleTypeIdX1),
            2000,
            "user5 should have 2000"
        );

        // test transferTokensFromTronicTBA function
        //create a fungible type for tronicerc1155
        vm.startPrank(address(tronicAdminContract));
        uint256 typeId = tronicERC1155.createFungibleType(1_000_000, "testFungibleURI");
        //mint fungible tokens to user1's tronic tba
        tronicERC1155.mintFungible(address(tokenId1TronicTBA), typeId, 1000);
        //verify that user5 has 1000 fungible tokens
        assertEq(
            tronicERC1155.balanceOf(address(tokenId1TronicTBA), typeId),
            1000,
            "user1 should have 1000"
        );

        vm.stopPrank();

        // transfer loyalty tokens from user1's member tba to user2's member tba
        vm.prank(user1);
        tronicAdminContract.transferTokensFromTronicTBA(1, typeId, 500, address(tokenId2TronicTBA));

        // verify that user1 has 500 loyalty tokens
        assertEq(
            tronicERC1155.balanceOf(address(tokenId1TronicTBA), typeId),
            500,
            "user1 should have 500"
        );

        // verify that user2 has 500 loyalty tokens
        assertEq(
            tronicERC1155.balanceOf(address(tokenId2TronicTBA), typeId),
            500,
            "user2 should have 500"
        );

        //perform same transfer but from an approved caller other than user1
        vm.prank(tronicAdmin);
        tronicAdminContract.transferTokensFromTronicTBA(1, typeId, 500, address(tokenId2TronicTBA));

        // verify that user1 has 0 loyalty tokens
        assertEq(
            tronicERC1155.balanceOf(address(tokenId1TronicTBA), typeId), 0, "user1 should have 0"
        );

        // verify that user2 has 2000 loyalty tokens
        assertEq(
            tronicERC1155.balanceOf(address(tokenId2TronicTBA), typeId),
            1000,
            "user2 should have 1000"
        );
    }
}
