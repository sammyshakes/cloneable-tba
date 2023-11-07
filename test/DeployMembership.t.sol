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
            tronicMainContract.mintMembership(tronicTokenId1TBA, membershipIDX, 0);
        // get tba account address
        address tbaAccount = membershipXERC721.getTBAccount(1);
        console.log("tbaAccount: ", tbaAccount);
        assertEq(tbaAccount, user1TBAmembershipX);

        // verify that user1TBA owns token
        assertEq(membershipXERC721.ownerOf(1), tronicTokenId1TBA);

        // check uri
        string memory uri = membershipXERC721.tokenURI(1);
        console.log("uri: ", uri);
        //verify uri is correct
        assertEq(uri, "http://Xclone721.com/1");

        // Membership Y onboards a new user
        (address user2TBAmembershipY,) =
            tronicMainContract.mintMembership(tronicTokenId2TBA, membershipIDY, 0);

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

        //verify uris from membershipX and membershipY erc1155s
        string memory uriX = membershipXERC1155.uri(fungibleTypeIdX1);
        console.log("uriX: ", uriX);
        console.log("fungibleTypeIdX1: ", fungibleTypeIdX1);
        assertEq(uriX, initialUriX);

        string memory uriY = membershipYERC1155.uri(fungibleTypeIdY1);
        console.log("uriY: ", uriY);
        assertEq(uriY, initialUriY);

        vm.stopPrank();
    }

    function testTransferOwnership() public {
        //attempt to transfer ownership to zero address
        vm.startPrank(tronicAdmin);
        vm.expectRevert("New owner address cannot be zero");
        tronicERC721.transferOwnership(address(0));

        //transfer ownership of membershipXERC721 to user1
        tronicERC721.transferOwnership(user1);

        //verify that user1 is the owner of membershipXERC721
        assertEq(user1, tronicERC721.owner());
        vm.stopPrank();
    }

    function testDeployMembership() public {
        // deploy membership with isBound set to false
        vm.prank(tronicAdmin);
        (uint256 membershipID, address membershipZ,) = tronicMainContract.deployMembership(
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            false,
            new string[](0),
            new uint128[](0),
            new bool[](0)
        );

        //instance of membershipZERC721
        TronicMembership membershipZERC721 = TronicMembership(membershipZ);

        // mint token to user1's TBA
        vm.prank(tronicAdmin);
        membershipZERC721.mint(tronicTokenId1TBA);

        // verify that user1TBA owns token
        assertEq(membershipZERC721.ownerOf(1), tronicTokenId1TBA);

        // Verify that the membership contract was deployed successfully
        assertTrue(membershipID > 0, "Membership ID should be greater than 0");
        assertTrue(membershipZ != address(0), "Membership contract address should not be null");
        assertEq(
            membershipZERC721.owner(),
            tronicAdmin,
            "Membership contract owner should be tronicAdmin"
        );

        // Verify membership contract properties
        assertEq(membershipZERC721.name(), "membershipZ", "Membership name should match");
        assertEq(membershipZERC721.symbol(), "MEMZ", "Membership symbol should match");
        assertEq(membershipZERC721.isElastic(), false, "IsElastic should be false");
        assertEq(membershipZERC721.isBound(), false, "IsBound should be false");

        // Verify membership tier assignment
        assertTrue(
            membershipXERC721.isAdmin(address(tronicMainContract)), "TronicMain should be an admin"
        );
    }

    function testCreateMembershipTiers() public {
        //assert the number of max tiers from main
        assertEq(tronicMainContract.maxTiersPerMembership(), 10);

        //create input arrays
        string[] memory tierIds = new string[](2);
        tierIds[0] = "tier1111";
        tierIds[1] = "tier2222";

        uint128[] memory durations = new uint128[](2);
        durations[0] = 30 days;
        durations[1] = 120 days;

        bool[] memory isOpens = new bool[](2);
        isOpens[0] = true;
        isOpens[1] = false;

        //create membership tiers
        vm.startPrank(tronicAdmin);
        membershipXERC721.createMembershipTiers(tierIds, durations, isOpens);

        //get membership tier
        console.log(
            "membershipXERC721 membership tier id: ",
            membershipXERC721.getMembershipTierDetails(1).tierId
        );

        //verify details
        assertEq(membershipXERC721.getMembershipTierDetails(1).tierId, "tier1111");
        assertEq(membershipXERC721.getMembershipTierDetails(1).duration, 30 days);
        assertEq(membershipXERC721.getMembershipTierDetails(1).isOpen, true);

        //get membership tier
        console.log(
            "membershipXERC721 membership tier id: ",
            membershipXERC721.getMembershipTierDetails(2).tierId
        );

        //verify details
        assertEq(membershipXERC721.getMembershipTierDetails(2).tierId, "tier2222");
        assertEq(membershipXERC721.getMembershipTierDetails(2).duration, 120 days);
        assertEq(membershipXERC721.getMembershipTierDetails(2).isOpen, false);

        //now set membership tier ids using setMembershipTierId function
        membershipXERC721.setMembershipTier(1, "tier3333", 30 days, true);
        membershipXERC721.setMembershipTier(2, "tier4444", 120 days, false);

        //verify that membership tier id was changed
        assertEq(membershipXERC721.getMembershipTierId(1), "tier3333");
        assertEq(membershipXERC721.getMembershipTierId(2), "tier4444");

        //get getTierIndexByTierId
        console.log(
            "membershipXERC721 membership tier index: ",
            membershipXERC721.getTierIndexByTierId("tier3333")
        );

        //verify that tier index is correct
        assertEq(membershipXERC721.getTierIndexByTierId("tier3333"), 1);
        assertEq(membershipXERC721.getTierIndexByTierId("tier4444"), 2);

        //try to get tier index for non existent tier id
        membershipXERC721.getTierIndexByTierId("tier5555");
        assertEq(membershipXERC721.getTierIndexByTierId("tier5555"), 0);

        // create 8 more  membership tiers to test max membership tiers
        string[] memory tierIds2 = new string[](8);
        tierIds2[0] = "tier5555";
        tierIds2[1] = "tier6666";
        tierIds2[2] = "tier7777";
        tierIds2[3] = "tier8888";
        tierIds2[4] = "tier9999";
        tierIds2[5] = "tier101010";
        tierIds2[6] = "tier111111";
        tierIds2[7] = "tier121212";

        uint128[] memory durations2 = new uint128[](8);
        durations2[0] = 30 days;
        durations2[1] = 120 days;
        durations2[2] = 30 days;
        durations2[3] = 120 days;
        durations2[4] = 30 days;
        durations2[5] = 120 days;
        durations2[6] = 30 days;
        durations2[7] = 120 days;

        bool[] memory isOpens2 = new bool[](8);
        isOpens2[0] = true;
        isOpens2[1] = false;
        isOpens2[2] = true;
        isOpens2[3] = false;
        isOpens2[4] = true;
        isOpens2[5] = false;
        isOpens2[6] = true;
        isOpens2[7] = false;

        //create membership tiers
        membershipXERC721.createMembershipTiers(tierIds2, durations2, isOpens2);

        //try to create multiples over max membership tiers
        vm.expectRevert("Max Tier limit reached");
        membershipXERC721.createMembershipTiers(tierIds2, durations2, isOpens2);

        vm.expectRevert();
        membershipXERC721.createMembershipTier("xxxx", 30 days, true);

        vm.stopPrank();
    }

    function testCreateMembershipTiersMismatchArrays() public {
        //create input arrays with mismatched tierId
        string[] memory tierIds = new string[](1);
        tierIds[0] = "tier1111";
        // tierIds[1] = "tier2222";

        uint128[] memory durations = new uint128[](2);
        durations[0] = 30 days;
        durations[1] = 120 days;

        bool[] memory isOpens = new bool[](2);
        isOpens[0] = true;
        isOpens[1] = false;

        //create membership tiers
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Input array mismatch");
        membershipXERC721.createMembershipTiers(tierIds, durations, isOpens);

        //create input arrays with mismatched durations
        tierIds = new string[](2);
        tierIds[0] = "tier1111";
        tierIds[1] = "tier2222";

        durations = new uint128[](1);
        durations[0] = 30 days;

        //create membership tiers
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Input array mismatch");
        membershipXERC721.createMembershipTiers(tierIds, durations, isOpens);

        //create input arrays with mismatched isOpens
        durations = new uint128[](2);
        durations[0] = 30 days;
        durations[1] = 120 days;

        isOpens = new bool[](1);
        isOpens[0] = true;

        //create membership tiers
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Input array mismatch");
        membershipXERC721.createMembershipTiers(tierIds, durations, isOpens);

        vm.stopPrank();
    }

    function testCreateTypesFromFromAdmin() public {
        vm.startPrank(tronicAdmin);
        // create fungible token type for membershipx
        uint256 typeId = tronicMainContract.createFungibleTokenType(
            1000, "http://example.com/token/", membershipIDX
        );

        //get uri from fungible token type
        string memory uri = membershipXERC1155.uri(typeId);
        console.log("uri from fungible typeid: ", uri);

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

        // create fungible token type for membershipy
        typeId = membershipYERC1155.createFungibleType(1_000_000, "http://example.com/yoyoyo/");

        //get uri from fungible token type
        uri = membershipYERC1155.uri(typeId);
        console.log("uri from fungible typeid membershipy: ", uri);

        vm.stopPrank();
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

        //test uri
        // vm.expectRevert("Token is bound");
        string memory uri = membershipZERC721.tokenURI(1);
        console.log("uri: ", uri);

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

    function testBoundTokenTransferWithApproval() public {
        // Mint a member membershipXERC721 to user1
        vm.prank(tronicAdmin);
        (address user1Token, uint256 tokenId) = membershipXERC721.mint(tronicTokenId1TBA);

        console.log("user1Token: ", user1Token);
        console.log("tokenId: ", tokenId);

        //verify that tronicTokenId1TBA owns token
        assertEq(membershipXERC721.ownerOf(tokenId), tronicTokenId1TBA);

        IERC6551Account tokenId1TronicTBA = IERC6551Account(payable(address(tronicTokenId1TBA)));

        //verify user1 is authorized to transfer token
        assertEq(tokenId1TronicTBA.isAuthorized(user1), true);

        // Set approval for TronicMainContract
        vm.startPrank(user1);
        //setPermissions for tronicMainContract to transfer membership
        bool[] memory approvedValues = new bool[](1);
        approvedValues[0] = true;
        address[] memory approved = new address[](1);
        approved[0] = address(tronicMainContract);

        tokenId1TronicTBA.setPermissions(approved, approvedValues);
        // IERC6551Account(user1Token).setPermissions([address(tronicMainContract)], [true]);

        // Transfer token from user1's tba to user2's tba via TronicMainContract

        tronicMainContract.transferMembershipFromTronicTBA(
            1, membershipIDX, tokenId, tronicTokenId2TBA
        );
        vm.stopPrank();

        // Transfer should succeed
        assertEq(membershipXERC721.ownerOf(tokenId), tronicTokenId2TBA);
    }

    function testDeployMembershipWithMismatchArrays() public {
        // set up initial inpout arrays for deployMembership on TronicMain.sol:
        string[] memory tierIds = new string[](1);
        tierIds[0] = "tier1111";

        uint128[] memory durations = new uint128[](2);
        durations[0] = 30 days;
        durations[1] = 120 days;

        bool[] memory isOpens = new bool[](2);
        isOpens[0] = true;
        isOpens[1] = false;

        // deploy membership with mismatched arrays
        vm.startPrank(tronicAdmin);
        vm.expectRevert();
        tronicMainContract.deployMembership(
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            false,
            tierIds,
            durations,
            isOpens
        );
        ///////////
        tierIds = new string[](2);
        tierIds[0] = "tier1111";
        tierIds[1] = "tier2222";

        durations = new uint128[](1);
        durations[0] = 30 days;

        // deploy membership with mismatched arrays
        vm.expectRevert();
        tronicMainContract.deployMembership(
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            false,
            tierIds,
            durations,
            isOpens
        );

        //////////////

        durations = new uint128[](2);
        durations[0] = 30 days;
        durations[1] = 120 days;

        isOpens = new bool[](1);
        isOpens[0] = true;

        // deploy membership with mismatched arrays
        vm.expectRevert();
        tronicMainContract.deployMembership(
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            false,
            tierIds,
            durations,
            isOpens
        );

        // deploy
        tronicMainContract.deployMembership(
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            false,
            new string[](0),
            new uint128[](0),
            new bool[](0)
        );

        //deploy normally
        tierIds = new string[](2);
        tierIds[0] = "tier1111";
        tierIds[1] = "tier2222";

        durations = new uint128[](2);
        durations[0] = 30 days;
        durations[1] = 120 days;

        isOpens = new bool[](2);
        isOpens[0] = true;
        isOpens[1] = false;

        // deploy membership with mismatched arrays
        vm.startPrank(tronicAdmin);
        tronicMainContract.deployMembership(
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            false,
            tierIds,
            durations,
            isOpens
        );

        //remove membership
        tronicMainContract.removeMembership(3);

        vm.stopPrank();
    }
}
