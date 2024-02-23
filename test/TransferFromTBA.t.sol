// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract TransferFromTBA is TronicTestBase {
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
        console.log("brandLoyaltyXTokenId1TBA: ", brandLoyaltyXTokenId1TBA);
        console.log("brandLoyaltyXTokenId2TBA: ", brandLoyaltyXTokenId2TBA);
        console.log("brandLoyaltyYTokenId1TBA: ", brandLoyaltyYTokenId1TBA);
        console.log("brandLoyaltyYTokenId2TBA: ", brandLoyaltyYTokenId2TBA);

        IERC6551Account tokenId1BrandXTBA = IERC6551Account(payable(brandLoyaltyXTokenId1TBA));
        IERC6551Account tokenId2BrandXTBA = IERC6551Account(payable(brandLoyaltyXTokenId2TBA));
        IERC6551Account tokenId3BrandYTBA = IERC6551Account(payable(brandLoyaltyYTokenId1TBA));
        IERC6551Account tokenId4BrandYTBA = IERC6551Account(payable(brandLoyaltyYTokenId2TBA));

        // verify that users have tokenbound accounts
        assertEq(tokenId1BrandXTBA.owner(), user1);
        assertEq(tokenId2BrandXTBA.owner(), user2);
        assertEq(tokenId3BrandYTBA.owner(), user3);
        assertEq(tokenId4BrandYTBA.owner(), user4);

        //verify tba account addresses are correct
        assertEq(brandLoyaltyX.getTBAccount(1), address(tokenId1BrandXTBA));
        assertEq(brandLoyaltyX.getTBAccount(2), address(tokenId2BrandXTBA));
        assertEq(brandLoyaltyY.getTBAccount(1), address(tokenId3BrandYTBA));
        assertEq(brandLoyaltyY.getTBAccount(2), address(tokenId4BrandYTBA));

        // users subscribe to membershipX
        // brands X and Y mints membership token to user's brand loyalty tba
        vm.startPrank(tronicAdmin);
        uint256 membershipXTokenId_1 =
            tronicMainContract.mintMembership(brandLoyaltyXTokenId1TBA, membershipIDX, 1);
        uint256 membershipXTokenId_2 =
            tronicMainContract.mintMembership(brandLoyaltyXTokenId2TBA, membershipIDX, 1);
        uint256 membershipYTokenId_1 =
            tronicMainContract.mintMembership(brandLoyaltyYTokenId1TBA, membershipIDY, 1);
        uint256 membershipYTokenId_2 =
            tronicMainContract.mintMembership(brandLoyaltyYTokenId2TBA, membershipIDY, 1);

        // verify that users' brand loyalty TBAs have membershipX nfts
        assertEq(brandXMembership.ownerOf(membershipXTokenId_1), brandLoyaltyXTokenId1TBA);
        assertEq(brandXMembership.ownerOf(membershipXTokenId_2), brandLoyaltyXTokenId2TBA);
        assertEq(brandYMembership.ownerOf(membershipYTokenId_1), brandLoyaltyYTokenId1TBA);
        assertEq(brandYMembership.ownerOf(membershipYTokenId_2), brandLoyaltyYTokenId2TBA);

        // membershipX mints loyalty tokens to user's brand loyalty tba
        brandXToken.mintFungible(brandLoyaltyXTokenId1TBA, fungibleTypeIdX1, 1000);
        brandXToken.mintFungible(brandLoyaltyXTokenId2TBA, fungibleTypeIdX1, 1000);
        brandYToken.mintFungible(brandLoyaltyYTokenId1TBA, fungibleTypeIdY1, 1000);
        brandYToken.mintFungible(brandLoyaltyYTokenId2TBA, fungibleTypeIdY1, 1000);

        // verify that users' membershipX TBAs have loyalty tokens
        assertEq(
            brandXToken.balanceOf(brandLoyaltyXTokenId1TBA, fungibleTypeIdX1),
            1000,
            "user1's tba should have 1000"
        );

        assertEq(
            brandXToken.balanceOf(brandLoyaltyXTokenId2TBA, fungibleTypeIdX1),
            1000,
            "user2's tba should have 1000"
        );

        assertEq(
            brandYToken.balanceOf(brandLoyaltyYTokenId1TBA, fungibleTypeIdY1),
            1000,
            "user3's tba should have 1000"
        );

        assertEq(
            brandYToken.balanceOf(brandLoyaltyYTokenId2TBA, fungibleTypeIdY1),
            1000,
            "user4's tba should have 1000"
        );

        vm.stopPrank();

        //----------------------------------------------------------------------------------//
        //BELOW THIS LINE ARE TESTS FOR TRANSFERRING MEMBERSHIPS AND LOYALTY TOKENS
        //COMMENTING OUT FOR NOW BECAUSE THIS FUNCTIONALITY MAY CHANGE

        //Transfer erc1155 tokens from brand Loyalty TBA
        //TronicMain contract must be an approved user for tronic tba
        //we wil also approve the tronic admin address
        address[] memory approved = new address[](2);
        approved[0] = address(tronicMainContract);
        approved[1] = tronicAdmin;
        bool[] memory approvedValues = new bool[](2);
        approvedValues[0] = true;
        approvedValues[1] = true;

        uint256 amount = 500;

        vm.prank(user1);
        tokenId1BrandXTBA.setPermissions(approved, approvedValues);

        bool isReward = false;

        // expect revert for unauthorized user
        vm.prank(unauthorizedUser);
        vm.expectRevert("Unauthorized caller");
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandIDX, brandLoyaltyXTokenId1TBA, fungibleTypeIdX1, user2, amount, isReward
        );

        //expect revert for invalid brand id
        vm.prank(user1);
        vm.expectRevert("Brand does not exist");
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            10, brandLoyaltyXTokenId1TBA, fungibleTypeIdX1, user2, amount, isReward
        );

        vm.prank(user1);
        // transfer loyalty tokens from user1's brand loyalty tba to user2's brand loyalty tba
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandIDX,
            brandLoyaltyXTokenId1TBA,
            fungibleTypeIdX1,
            brandLoyaltyXTokenId2TBA,
            amount,
            isReward
        );

        assertEq(
            brandXToken.balanceOf(brandLoyaltyXTokenId1TBA, fungibleTypeIdX1),
            amount,
            "user1's brand loyalty should have 500"
        );

        assertEq(
            brandXToken.balanceOf(brandLoyaltyXTokenId2TBA, fungibleTypeIdX1),
            1500,
            "user2's tba should have 1500"
        );

        //perform same transfer but from an approved caller other than user1
        vm.prank(tronicAdmin);
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandIDX,
            brandLoyaltyXTokenId1TBA,
            fungibleTypeIdX1,
            brandLoyaltyXTokenId2TBA,
            amount,
            isReward
        );

        assertEq(
            brandXToken.balanceOf(brandLoyaltyXTokenId1TBA, fungibleTypeIdX1),
            0,
            "user1 should have 0"
        );

        assertEq(
            brandXToken.balanceOf(brandLoyaltyXTokenId2TBA, fungibleTypeIdX1),
            2000,
            "user2's tba should have 2000"
        );

        // approve tronic admin and tronic main contract for user2's membership tba
        vm.prank(user2);
        tokenId2BrandXTBA.setPermissions(approved, approvedValues);

        // //attempt to transfer from unauthorized user
        vm.prank(unauthorizedUser);
        vm.expectRevert("Unauthorized caller");
        tronicMainContract.transferMembershipFromBrandLoyaltyTBA(
            brandLoyaltyXTokenId2TBA, membershipIDX, membershipXTokenId_2, brandLoyaltyXTokenId1TBA
        );

        // //attempt to transfer with invalid membership id
        vm.prank(user2);
        vm.expectRevert("Membership does not exist");
        tronicMainContract.transferMembershipFromBrandLoyaltyTBA(
            brandLoyaltyXTokenId2TBA, 666, membershipXTokenId_2, brandLoyaltyXTokenId1TBA
        );

        //transfer membershipX nft from user2's brand loyalty tba to user1's brand loyalty tba
        vm.prank(user2);
        tronicMainContract.transferMembershipFromBrandLoyaltyTBA(
            brandLoyaltyXTokenId2TBA, membershipIDX, membershipXTokenId_2, brandLoyaltyXTokenId1TBA
        );

        // verify that user1's tba has membershipX nft
        assertEq(brandXMembership.ownerOf(membershipXTokenId_2), brandLoyaltyXTokenId1TBA);
    }
}
