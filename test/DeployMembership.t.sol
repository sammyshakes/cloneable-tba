// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract DeployMembership is TronicTestBase {
    function testInitialSetup() public {
        //assert that tronicAdmin is the owner of membership erc721 and erc1155 token contracts
        assertEq(tronicAdmin, brandXMembership.owner());
        assertEq(tronicAdmin, brandXToken.owner());
        assertEq(tronicAdmin, brandYMembership.owner());
        assertEq(tronicAdmin, brandYToken.owner());
        assertEq(tronicAdmin, brandLoyaltyX.owner());
        assertEq(tronicAdmin, brandLoyaltyY.owner());
        //verify membershiptier uris for brandx
        assertEq(brandXMembership.getMembershipTierDetails(1).tierURI, tier1XURI);
        assertEq(brandXMembership.getMembershipTierDetails(2).tierURI, tier2XURI);

        // check if tronicMainContract isAdmin
        assertEq(brandXMembership.isAdmin(address(tronicMainContract)), true);
        assertEq(tronicMainContract.isAdmin(tronicAdmin), true);

        //get name and symbol
        console.log("brandXMembership name: ", brandXMembership.name());

        vm.startPrank(tronicAdmin);
        // // set membership tier
        // brandXMembership.setMembershipTier(1, "tier1111");

        // // get membership tier
        // console.log("brandXMembership membership tier: ", brandXMembership.getMembershipTier(1));

        // Mint a brand loyalty nft to user1
        (address user1TBALoyaltyX, uint256 brandXTokenId) =
            tronicMainContract.mintBrandLoyaltyToken(user1, brandIDX);

        // get tba account address from brand x loyalty contract
        address tbaAccount = brandLoyaltyX.getTBAccount(brandXTokenId);
        console.log("tbaAccount: ", tbaAccount);
        //verify tba account is correct
        assertEq(tbaAccount, user1TBALoyaltyX);

        // verify that user1TBA owns membershiptoken
        assertEq(brandLoyaltyX.ownerOf(brandXTokenId), user1);

        // check uri
        string memory uri = brandLoyaltyX.tokenURI(brandXTokenId);
        console.log("uri: ", uri);
        //verify uri is correct
        assertEq(uri, "http://BrandX.com/3");

        // Mint membership to user1's Brand X TBA
        uint256 membershipTokenIdUser1 =
            tronicMainContract.mintMembership(user1TBALoyaltyX, membershipIDX, 1);

        //verify that user1TBA owns token
        assertEq(brandXMembership.ownerOf(membershipTokenIdUser1), user1TBALoyaltyX);

        //check total supply of membershipX
        assertEq(brandXMembership.totalSupply(), 3);

        //get membership tier
        console.log(
            "brandXMembership membership tier id: ",
            brandXMembership.getMembershipTierDetails(1).tierId
        );

        //get token membership tier
        console.log(
            "brandXMembership membership tier index: ",
            brandXMembership.getMembershipToken(membershipTokenIdUser1).tierIndex
        );

        //check uri of membershipTokenIdUser1
        string memory uri2 = brandXMembership.tokenURI(membershipTokenIdUser1);
        assertEq(uri2, tier1XURI);
        console.log("uri2: ", tier1XURI);

        // Mint a brand loyalty nft to user2
        (address user2TBAmembershipY, uint256 BrandYTokenId) =
            tronicMainContract.mintBrandLoyaltyToken(user2, brandIDY);

        uint256 membershipTokenIdUser2 =
            tronicMainContract.mintMembership(user2TBAmembershipY, membershipIDY, 0);

        // get tba account address
        address tbaAccountY = brandLoyaltyY.getTBAccount(BrandYTokenId);
        console.log("tbaAccountY: ", tbaAccountY);
        assert(tbaAccountY == user2TBAmembershipY);

        // verify that user2TBA owns token
        assertEq(brandLoyaltyY.ownerOf(membershipTokenIdUser2), user2);

        // mint fungible tokens id=0 to user1TBALoyaltyX and user2TBAmembershipY
        brandXToken.mintFungible(user1TBALoyaltyX, 0, 100);
        brandYToken.mintFungible(user2TBAmembershipY, 0, 100);

        //verify that user1TBALoyaltyX and user2TBAmembershipY have 100 tokens
        assertEq(brandXToken.balanceOf(user1TBALoyaltyX, 0), 100);
        assertEq(brandYToken.balanceOf(user2TBAmembershipY, 0), 100);

        //verify uris from membershipX and membershipY erc1155s
        string memory uriX = brandXToken.uri(fungibleTypeIdX1);
        console.log("uriX: ", uriX);
        console.log("fungibleTypeIdX1: ", fungibleTypeIdX1);
        assertEq(uriX, initialUriX);

        string memory uriY = brandYToken.uri(fungibleTypeIdY1);
        console.log("uriY: ", uriY);
        assertEq(uriY, initialUriY);

        vm.stopPrank();
    }

    function testTransferOwnershipofBrandLoyaltyContract() public {
        //attempt to transfer ownership to zero address
        vm.startPrank(tronicAdmin);
        vm.expectRevert("New owner address cannot be zero");
        tronicBrandLoyaltyImplementation.transferOwnership(address(0));

        //transfer ownership of brandXMembership to user1
        tronicBrandLoyaltyImplementation.transferOwnership(user1);

        //verify that user1 is the owner of brandXMembership
        assertEq(user1, tronicBrandLoyaltyImplementation.owner());
        vm.stopPrank();
    }

    function testDeployBrand() public {
        // deploy brandX
        vm.prank(tronicAdmin);
        (uint256 brandid, address brandXLoyaltyAddress, address brandXTokenAddress) =
        tronicMainContract.deployBrand(
            "Brand X", // brand name
            "BRDX",
            "http://example.com/token/",
            false
        );

        //instance of brandLoyalty contract
        TronicBrandLoyalty brandLoyalty = TronicBrandLoyalty(brandXLoyaltyAddress);

        // Verify that the brand contract was deployed successfully
        assertTrue(brandXLoyaltyAddress != address(0), "Brand contract address should not be null");
        assertEq(brandLoyalty.owner(), tronicAdmin, "Brand contract owner should be tronicAdmin");

        // Verify brand contract properties
        assertEq(brandLoyalty.name(), "Brand X", "Brand name should match");

        // Verify brand membership tier assignment
        assertTrue(
            brandLoyalty.isAdmin(address(tronicMainContract)), "TronicMain should be an admin"
        );
    }

    function testDeployMembership() public {
        //first deploy brand
        // deploy brandX
        vm.prank(tronicAdmin);
        (uint256 brandId, address brandXLoyaltyAddress, address brandXTokenAddress) =
        tronicMainContract.deployBrand(
            "Brand X", // brand name
            "BRDX",
            "http://example.com/token/",
            false
        );

        //instance of brandLoyalty contract
        TronicBrandLoyalty brandLoyalty = TronicBrandLoyalty(brandXLoyaltyAddress);

        // Verify that the brand contract was deployed successfully
        assertTrue(brandXLoyaltyAddress != address(0), "Brand contract address should not be null");
        assertEq(brandLoyalty.owner(), tronicAdmin, "Brand contract owner should be tronicAdmin");

        // Verify brand contract properties
        assertEq(brandLoyalty.name(), "Brand X", "Brand name should match");

        // Verify brand membership tier assignment
        assertTrue(
            brandLoyalty.isAdmin(address(tronicMainContract)), "TronicMain should be an admin"
        );

        // deploy membership with isBound set to false
        vm.prank(tronicAdmin);
        (uint256 membershipID, address membershipZAddress) = tronicMainContract.deployMembership(
            brandId,
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            membershipTiers
        );

        //instance of membershipZERC721
        TronicMembership membershipZERC721 = TronicMembership(membershipZAddress);

        uint8 tierId = 0;

        // mint token to user1's TBA
        vm.prank(tronicAdmin);
        tronicMainContract.mintMembership(tronicTokenId1TBA, membershipID, tierId);

        // verify that user1TBA owns token
        assertEq(membershipZERC721.balanceOf(tronicTokenId1TBA), 1);

        // Verify that the membership contract was deployed successfully
        assertTrue(membershipID > 0, "Membership ID should be greater than 0");
        assertTrue(
            membershipZAddress != address(0), "Membership contract address should not be null"
        );
        assertEq(
            membershipZERC721.owner(),
            tronicAdmin,
            "Membership contract owner should be tronicAdmin"
        );

        // Verify membership contract properties
        assertEq(membershipZERC721.name(), "membershipZ", "Membership name should match");

        // Verify membership tier assignment
        assertTrue(
            brandXMembership.isAdmin(address(tronicMainContract)), "TronicMain should be an admin"
        );
    }

    // function testCreateMembershipTiers() public {
    //     //create input arrays
    //     string[] memory tierIds = new string[](2);
    //     tierIds[0] = "tier1111";
    //     tierIds[1] = "tier2222";

    //     uint128[] memory durations = new uint128[](2);
    //     durations[0] = 30 days;
    //     durations[1] = 120 days;

    //     bool[] memory isOpens = new bool[](2);
    //     isOpens[0] = true;
    //     isOpens[1] = false;

    //     string[] memory tierURIs = new string[](2);
    //     tierURIs[0] = "http://example.com/tier1111/";
    //     tierURIs[1] = "http://example.com/tier2222/";

    //     //create membership tiers
    //     vm.startPrank(tronicAdmin);
    //     brandXMembership.createMembershipTiers(tierIds, durations, isOpens, tierURIs);

    //     //get membership tier
    //     console.log(
    //         "brandXMembership membership tier id: ",
    //         brandXMembership.getMembershipTierDetails(1).tierId
    //     );

    //     //verify details
    //     assertEq(brandXMembership.getMembershipTierDetails(1).tierId, "tier1111");
    //     assertEq(brandXMembership.getMembershipTierDetails(1).duration, 30 days);
    //     assertEq(brandXMembership.getMembershipTierDetails(1).isOpen, true);

    //     //get membership tier
    //     console.log(
    //         "brandXMembership membership tier id: ",
    //         brandXMembership.getMembershipTierDetails(2).tierId
    //     );

    //     //verify details
    //     assertEq(brandXMembership.getMembershipTierDetails(2).tierId, "tier2222");
    //     assertEq(brandXMembership.getMembershipTierDetails(2).duration, 120 days);
    //     assertEq(brandXMembership.getMembershipTierDetails(2).isOpen, false);

    //     //now set membership tier ids using setMembershipTierId function
    //     brandXMembership.setMembershipTier(
    //         1, "tier3333", 30 days, true, "http://example.com/tier3333/"
    //     );
    //     brandXMembership.setMembershipTier(
    //         2, "tier4444", 120 days, false, "http://example.com/tier4444/"
    //     );

    //     //verify that membership tier id was changed
    //     assertEq(brandXMembership.getMembershipTierId(1), "tier3333");
    //     assertEq(brandXMembership.getMembershipTierId(2), "tier4444");

    //     //get getTierIndexByTierId
    //     console.log(
    //         "brandXMembership membership tier index: ",
    //         brandXMembership.getTierIndexByTierId("tier3333")
    //     );

    //     //verify that tier index is correct
    //     assertEq(brandXMembership.getTierIndexByTierId("tier3333"), 1);
    //     assertEq(brandXMembership.getTierIndexByTierId("tier4444"), 2);

    //     //try to get tier index for non existent tier id
    //     brandXMembership.getTierIndexByTierId("tier5555");
    //     assertEq(brandXMembership.getTierIndexByTierId("tier5555"), 0);

    //     // create 8 more  membership tiers to test max membership tiers
    //     string[] memory tierIds2 = new string[](8);
    //     tierIds2[0] = "tier5555";
    //     tierIds2[1] = "tier6666";
    //     tierIds2[2] = "tier7777";
    //     tierIds2[3] = "tier8888";
    //     tierIds2[4] = "tier9999";
    //     tierIds2[5] = "tier101010";
    //     tierIds2[6] = "tier111111";
    //     tierIds2[7] = "tier121212";

    //     uint128[] memory durations2 = new uint128[](8);
    //     durations2[0] = 30 days;
    //     durations2[1] = 120 days;
    //     durations2[2] = 30 days;
    //     durations2[3] = 120 days;
    //     durations2[4] = 30 days;
    //     durations2[5] = 120 days;
    //     durations2[6] = 30 days;
    //     durations2[7] = 120 days;

    //     bool[] memory isOpens2 = new bool[](8);
    //     isOpens2[0] = true;
    //     isOpens2[1] = false;
    //     isOpens2[2] = true;
    //     isOpens2[3] = false;
    //     isOpens2[4] = true;
    //     isOpens2[5] = false;
    //     isOpens2[6] = true;
    //     isOpens2[7] = false;

    //     string[] memory tierURIs2 = new string[](8);
    //     tierURIs2[0] = "http://example.com/tier5555/";
    //     tierURIs2[1] = "http://example.com/tier6666/";
    //     tierURIs2[2] = "http://example.com/tier7777/";
    //     tierURIs2[3] = "http://example.com/tier8888/";
    //     tierURIs2[4] = "http://example.com/tier9999/";
    //     tierURIs2[5] = "http://example.com/tier101010/";
    //     tierURIs2[6] = "http://example.com/tier111111/";
    //     tierURIs2[7] = "http://example.com/tier121212/";

    //     //create membership tiers
    //     brandXMembership.createMembershipTiers(tierIds2, durations2, isOpens2, tierURIs2);

    //     //try to create multiples over max membership tiers
    //     vm.expectRevert("Max Tier limit reached");
    //     brandXMembership.createMembershipTiers(tierIds2, durations2, isOpens2, tierURIs2);

    //     vm.expectRevert();
    //     brandXMembership.createMembershipTier("xxxx", 30 days, true, "http://example.com/xxxx/");

    //     vm.stopPrank();
    // }

    // function testCreateMembershipTiersMismatchArrays() public {
    //     //create input arrays with mismatched tierId
    //     string[] memory tierIds = new string[](1);
    //     tierIds[0] = "tier1111";
    //     // tierIds[1] = "tier2222";

    //     uint128[] memory durations = new uint128[](2);
    //     durations[0] = 30 days;
    //     durations[1] = 120 days;

    //     bool[] memory isOpens = new bool[](2);
    //     isOpens[0] = true;
    //     isOpens[1] = false;

    //     //create membership tiers
    //     vm.startPrank(tronicAdmin);
    //     vm.expectRevert("Input array mismatch");
    //     brandXMembership.createMembershipTiers(tierIds, durations, isOpens, new string[](0));

    //     //create input arrays with mismatched durations
    //     tierIds = new string[](2);
    //     tierIds[0] = "tier1111";
    //     tierIds[1] = "tier2222";

    //     durations = new uint128[](1);
    //     durations[0] = 30 days;

    //     //create membership tiers
    //     vm.startPrank(tronicAdmin);
    //     vm.expectRevert("Input array mismatch");
    //     brandXMembership.createMembershipTiers(tierIds, durations, isOpens, new string[](0));

    //     //create input arrays with mismatched isOpens
    //     durations = new uint128[](2);
    //     durations[0] = 30 days;
    //     durations[1] = 120 days;

    //     isOpens = new bool[](1);
    //     isOpens[0] = true;

    //     //create membership tiers
    //     vm.startPrank(tronicAdmin);
    //     vm.expectRevert("Input array mismatch");
    //     brandXMembership.createMembershipTiers(tierIds, durations, isOpens, new string[](0));

    //     vm.stopPrank();
    // }

    // function testCreateTypesFromFromAdmin() public {
    //     vm.startPrank(tronicAdmin);
    //     // create fungible token type for membershipx
    //     uint256 typeId = tronicMainContract.createFungibleTokenType(
    //         1000, "http://example.com/token/", membershipIDX
    //     );

    //     //get uri from fungible token type
    //     string memory uri = membershipXERC1155.uri(typeId);
    //     console.log("uri from fungible typeid: ", uri);

    //     // get fungible token type from membershipx
    //     TronicToken.FungibleTokenInfo memory tokenType =
    //         membershipXERC1155.getFungibleTokenInfo(typeId);

    //     console.log("tokenType.uri: ", tokenType.uri);
    //     console.log("tokenType.maxSupply: ", tokenType.maxSupply);
    //     console.log("tokenType.totalMinted: ", tokenType.totalMinted);
    //     console.log("tokenType.totalBurned: ", tokenType.totalBurned);

    //     // create non fungible token type
    //     typeId = tronicMainContract.createNonFungibleTokenType(
    //         "http://example.com/token/", 10_000, membershipIDX
    //     );

    //     // get non fungible token type from membershipx
    //     TronicToken.NFTokenInfo memory nonFungibleTokenType =
    //         membershipXERC1155.getNFTokenInfo(typeId);

    //     console.log("nonFungibleTokenType.startingTokenId: ", nonFungibleTokenType.startingTokenId);
    //     console.log("nonFungibleTokenType.maxMintable: ", nonFungibleTokenType.maxMintable);
    //     console.log("nonFungibleTokenType.totalMinted: ", nonFungibleTokenType.totalMinted);
    //     console.log("nonFungibleTokenType.baseURI: ", nonFungibleTokenType.baseURI);

    //     // create fungible token type for membershipy
    //     typeId = membershipYERC1155.createFungibleType(1_000_000, "http://example.com/yoyoyo/");

    //     //get uri from fungible token type
    //     uri = membershipYERC1155.uri(typeId);
    //     console.log("uri from fungible typeid membershipy: ", uri);

    //     vm.stopPrank();
    // }

    // function testBoundMemberships() public {
    //     bool isBound = true;
    //     string[] memory tiers;
    //     uint128[] memory durations;
    //     bool[] memory isOpens;
    //     string[] memory tierURIs;

    //     // deploy membership with isBound set to false
    //     vm.prank(tronicAdmin);
    //     (, uint256 membershipID, address membershipZ,,) = tronicMainContract.deployMembership(
    //         "membershipZ",
    //         "brand z", // brand name
    //         "MEMZ",
    //         "http://example.com/token/",
    //         10_000,
    //         false,
    //         isBound,
    //         tiers,
    //         durations,
    //         isOpens,
    //         tierURIs
    //     );

    //     //instance of membershipZERC721
    //     TronicMembership membershipZERC721 = TronicMembership(membershipZ);

    //     // mint token to user1's TBA
    //     vm.prank(tronicAdmin);
    //     tronicMainContract.mintMembership(tronicTokenId1TBA, membershipID, 0);

    //     // try to transfer token to user2's tba (should revert because token is soulbound)
    //     vm.startPrank(user1);
    //     //setPermissions for tronicMainContract to transfer membership
    //     bool[] memory approvedValues = new bool[](1);
    //     approvedValues[0] = true;
    //     address[] memory approved = new address[](1);
    //     approved[0] = address(tronicMainContract);

    //     IERC6551Account tokenId1TronicTBA = IERC6551Account(payable(address(tronicTokenId1TBA)));
    //     tokenId1TronicTBA.setPermissions(approved, approvedValues);

    //     // transfer user1's membershipZ nft to user2's tba
    //     vm.expectRevert("Token is bound");
    //     tronicMainContract.transferMembershipFromTronicTBA(1, membershipID, 1, tronicTokenId2TBA);
    //     vm.stopPrank();

    //     //test uri
    //     // vm.expectRevert("Token is bound");
    //     string memory uri = membershipZERC721.uri(1);
    //     console.log("uri: ", uri);

    //     // have admin burn it
    //     vm.prank(tronicAdmin);
    //     membershipZERC721.burn(1);

    //     // verify that token is burned
    //     vm.prank(tronicAdmin);
    //     vm.expectRevert();
    //     membershipZERC721.ownerOf(1);

    //     // test uri now that token is burned
    //     vm.expectRevert();
    //     membershipZERC721.tokenURI(1);

    //     // get token membership tier
    //     vm.expectRevert("Token does not exist");
    //     membershipZERC721.getMembershipToken(1);
    // }

    // function testBoundTokenTransferWithApproval() public {
    //     // Mint a member membershipXERC721 to user1
    //     vm.prank(tronicAdmin);
    //     (address user1Token, uint256 tokenId) = membershipXERC721.mint(tronicTokenId1TBA);

    //     console.log("user1Token: ", user1Token);
    //     console.log("tokenId: ", tokenId);

    //     //verify that tronicTokenId1TBA owns token
    //     assertEq(membershipXERC721.ownerOf(tokenId), tronicTokenId1TBA);

    //     IERC6551Account tokenId1TronicTBA = IERC6551Account(payable(address(tronicTokenId1TBA)));

    //     //verify user1 is authorized to transfer token
    //     assertEq(tokenId1TronicTBA.isAuthorized(user1), true);

    //     // Set approval for TronicMainContract
    //     vm.startPrank(user1);
    //     //setPermissions for tronicMainContract to transfer membership
    //     bool[] memory approvedValues = new bool[](1);
    //     approvedValues[0] = true;
    //     address[] memory approved = new address[](1);
    //     approved[0] = address(tronicMainContract);

    //     tokenId1TronicTBA.setPermissions(approved, approvedValues);
    //     // IERC6551Account(user1Token).setPermissions([address(tronicMainContract)], [true]);

    //     // Transfer token from user1's tba to user2's tba via TronicMainContract

    //     tronicMainContract.transferMembershipFromTronicTBA(
    //         1, membershipIDX, tokenId, tronicTokenId2TBA
    //     );
    //     vm.stopPrank();

    //     // Transfer should succeed
    //     assertEq(membershipXERC721.ownerOf(tokenId), tronicTokenId2TBA);
    // }

    // function testDeployMembershipWithMismatchArrays() public {
    //     // set up initial inpout arrays for deployMembership on TronicMain.sol:
    //     string[] memory tierIds = new string[](1);
    //     tierIds[0] = "tier1111";

    //     uint128[] memory durations = new uint128[](2);
    //     durations[0] = 30 days;
    //     durations[1] = 120 days;

    //     bool[] memory isOpens = new bool[](2);
    //     isOpens[0] = true;
    //     isOpens[1] = false;

    //     // deploy membership with mismatched arrays
    //     vm.startPrank(tronicAdmin);
    //     vm.expectRevert();
    //     tronicMainContract.deployMembership(
    //         "membershipZ",
    //         "MEMZ",
    //         "http://example.com/token/",
    //         10_000,
    //         false,
    //         false,
    //         tierIds,
    //         durations,
    //         isOpens
    //     );
    //     ///////////
    //     tierIds = new string[](2);
    //     tierIds[0] = "tier1111";
    //     tierIds[1] = "tier2222";

    //     durations = new uint128[](1);
    //     durations[0] = 30 days;

    //     // deploy membership with mismatched arrays
    //     vm.expectRevert();
    //     tronicMainContract.deployMembership(
    //         "membershipZ",
    //         "MEMZ",
    //         "http://example.com/token/",
    //         10_000,
    //         false,
    //         false,
    //         tierIds,
    //         durations,
    //         isOpens
    //     );

    //     //////////////

    //     durations = new uint128[](2);
    //     durations[0] = 30 days;
    //     durations[1] = 120 days;

    //     isOpens = new bool[](1);
    //     isOpens[0] = true;

    //     // deploy membership with mismatched arrays
    //     vm.expectRevert();
    //     tronicMainContract.deployMembership(
    //         "membershipZ",
    //         "MEMZ",
    //         "http://example.com/token/",
    //         10_000,
    //         false,
    //         false,
    //         tierIds,
    //         durations,
    //         isOpens
    //     );

    //     // deploy
    //     tronicMainContract.deployMembership(
    //         "membershipZ",
    //         "MEMZ",
    //         "http://example.com/token/",
    //         10_000,
    //         false,
    //         false,
    //         new string[](0),
    //         new uint128[](0),
    //         new bool[](0)
    //     );

    //     //deploy normally
    //     tierIds = new string[](2);
    //     tierIds[0] = "tier1111";
    //     tierIds[1] = "tier2222";

    //     durations = new uint128[](2);
    //     durations[0] = 30 days;
    //     durations[1] = 120 days;

    //     isOpens = new bool[](2);
    //     isOpens[0] = true;
    //     isOpens[1] = false;

    //     // deploy membership with mismatched arrays
    //     vm.startPrank(tronicAdmin);
    //     tronicMainContract.deployMembership(
    //         "membershipZ",
    //         "MEMZ",
    //         "http://example.com/token/",
    //         10_000,
    //         false,
    //         false,
    //         tierIds,
    //         durations,
    //         isOpens
    //     );

    //     //remove membership
    //     tronicMainContract.removeMembership(3);

    //     vm.stopPrank();
    // }
}
