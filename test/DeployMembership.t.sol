// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract DeployMembership is TronicTestBase {
    function testInitialSetup() public {
        //assert that tronicAdmin is the owner of membership erc721 and erc1155 token contracts
        assertEq(tronicAdmin, membershipXERC721.owner());
        assertEq(tronicAdmin, membershipXERC1155.owner());
        assertEq(tronicAdmin, membershipYERC721.owner());
        assertEq(tronicAdmin, membershipYERC1155.owner());

        // check if tronicMainContract isAdmin
        assertEq(membershipXERC721.isAdmin(address(tronicMainContract)), true);
        assertEq(tronicMainContract.isAdmin(tronicAdmin), true);

        //get name and symbol
        console.log("membershipXERC721 name: ", membershipXERC721.name());
        console.log("membershipXERC721 symbol: ", membershipXERC721.symbol());

        vm.startPrank(tronicAdmin);
        // // set membership tier
        // membershipXERC721.setMembershipTier(1, "tier1111");

        // // get membership tier
        // console.log("membershipXERC721 membership tier: ", membershipXERC721.getMembershipTier(1));

        (address user1TBAmembershipX,) =
            tronicMainContract.mintMembership(tronicTokenId1TBA, membershipIDX, "no_tier");
        // get tba account address
        address tbaAccount = membershipXERC721.getTBAccount(1);
        console.log("tbaAccount: ", tbaAccount);
        assertEq(tbaAccount, user1TBAmembershipX);

        // verify that user1TBA owns token
        assertEq(membershipXERC721.ownerOf(1), tronicTokenId1TBA);

        // Membership Y onboards a new user
        (address user2TBAmembershipY,) =
            tronicMainContract.mintMembership(tronicTokenId2TBA, membershipIDY, "no_tier");

        // get tba account address
        address tbaAccountY = membershipYERC721.getTBAccount(1);
        console.log("tbaAccountY: ", tbaAccountY);
        assert(tbaAccountY == user2TBAmembershipY);

        // verify that user2TBA owns token
        assertEq(membershipYERC721.ownerOf(1), tronicTokenId2TBA);

        // mint fungible tokens id=0 to user1TBAmembershipX and user2TBAmembershipY
        membershipXERC1155.mintFungible(user1TBAmembershipX, 0, 100);
        membershipYERC1155.mintFungible(user2TBAmembershipY, 0, 100);

        //verify that user1TBAmembershipX and user2TBAmembershipY have 100 tokens
        assertEq(membershipXERC1155.balanceOf(user1TBAmembershipX, 0), 100);
        assertEq(membershipYERC1155.balanceOf(user2TBAmembershipY, 0), 100);

        vm.stopPrank();
    }

    function testCreateTypesFromFromAdmin() public {
        vm.startPrank(tronicAdmin);
        // create fungible token type for membershipx
        uint256 typeId = tronicMainContract.createFungibleTokenType(
            1000, "http://example.com/token/", membershipIDX
        );

        // get fungible token type from membershipx
        TronicToken.FungibleTokenInfo memory tokenType =
            membershipXERC1155.getFungibleTokenInfo(typeId);

        console.log("tokenType.uri: ", tokenType.uri);
        console.log("tokenType.maxSupply: ", tokenType.maxSupply);
        console.log("tokenType.totalMinted: ", tokenType.totalMinted);
        console.log("tokenType.totalBurned: ", tokenType.totalBurned);

        // create non fungible token type
        typeId = tronicMainContract.createNonFungibleTokenType(
            "http://example.com/token/", 10_000, membershipIDX
        );

        // get non fungible token type from membershipx
        TronicToken.NFTokenInfo memory nonFungibleTokenType =
            membershipXERC1155.getNFTokenInfo(typeId);

        console.log("nonFungibleTokenType.startingTokenId: ", nonFungibleTokenType.startingTokenId);
        console.log("nonFungibleTokenType.maxMintable: ", nonFungibleTokenType.maxMintable);
        console.log("nonFungibleTokenType.totalMinted: ", nonFungibleTokenType.totalMinted);
        console.log("nonFungibleTokenType.baseURI: ", nonFungibleTokenType.baseURI);
    }

    function testBoundMemberships() public {
        bool isBound = true;
        string[] memory tiers;
        uint128[] memory durations;
        bool[] memory isOpens;

        // deploy membership with isBound set to false
        vm.prank(tronicAdmin);
        (uint256 membershipID, address membershipZ,) = tronicMainContract.deployMembership(
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            isBound,
            tiers,
            durations,
            isOpens
        );

        //instance of membershipZERC721
        TronicMembership membershipZERC721 = TronicMembership(membershipZ);

        // mint token to user1's TBA
        vm.prank(tronicAdmin);
        membershipZERC721.mint(tronicTokenId1TBA);

        // try to transfer token to user2's tba (should revert because token is soulbound)
        vm.startPrank(user1);
        //setPermissions for tronicMainContract to transfer membership
        bool[] memory approvedValues = new bool[](1);
        approvedValues[0] = true;
        address[] memory approved = new address[](1);
        approved[0] = address(tronicMainContract);

        IERC6551Account tokenId1TronicTBA = IERC6551Account(payable(address(tronicTokenId1TBA)));
        tokenId1TronicTBA.setPermissions(approved, approvedValues);

        // transfer user1's membershipZ nft to user2's tba
        vm.expectRevert("Token is bound");
        tronicMainContract.transferMembershipFromTronicTBA(1, membershipID, 1, tronicTokenId2TBA);
        vm.stopPrank();

        // have admin burn it
        vm.prank(tronicAdmin);
        membershipZERC721.burn(1);

        // verify that token is burned
        vm.prank(tronicAdmin);
        vm.expectRevert();
        membershipZERC721.ownerOf(1);

        // test uri now that token is burned
        vm.expectRevert();
        membershipZERC721.tokenURI(1);

        // get token membership tier
        vm.expectRevert("Token does not exist");
        membershipZERC721.getTokenMembership(1);
    }
}
