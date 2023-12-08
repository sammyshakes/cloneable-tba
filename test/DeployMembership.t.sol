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

        // check BrandInfo from TronicMain
        TronicMain.BrandInfo memory brandXInfo = tronicMainContract.getBrandInfo(brandIDX);
        assertEq(brandXInfo.brandName, "Brand X");
        assertEq(brandXInfo.brandLoyaltyAddress, brandLoyaltyAddressX);
        assertEq(brandXInfo.tokenAddress, tokenAddressX);

        TronicMain.BrandInfo memory brandYInfo = tronicMainContract.getBrandInfo(brandIDY);
        assertEq(brandYInfo.brandName, "Brand Y");
        assertEq(brandYInfo.brandLoyaltyAddress, brandLoyaltyAddressY);
        assertEq(brandYInfo.tokenAddress, tokenAddressY);

        //get name and symbol
        console.log("brandXMembership name: ", brandXMembership.name());

        vm.startPrank(tronicAdmin);

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
        assertEq(uri2, "http://MembershipX.com/tier1XURI");
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
        brandLoyaltyX.transferOwnership(address(0));

        //transfer ownership of brandXMembership to user1
        brandLoyaltyX.transferOwnership(user1);

        //verify that user1 is the owner of brandXMembership
        assertEq(user1, brandLoyaltyX.owner());
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

        vm.startPrank(tronicAdmin);
        //first attempt to deploy membership with invalid brand id
        vm.expectRevert();
        (uint256 membershipID, address membershipZAddress) = tronicMainContract.deployMembership(
            100, "membershipZ", "MEMZ", "http://example.com/token/", 10_000, false, membershipTiers
        );

        // deploy membership with isBound set to false
        (membershipID, membershipZAddress) = tronicMainContract.deployMembership(
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

        // mint token to user1's brand loyalty TBA
        tronicMainContract.mintMembership(brandLoyaltyXTokenId1TBA, membershipID, tierId);

        vm.stopPrank();

        // verify that user1TBA owns token
        assertEq(membershipZERC721.balanceOf(brandLoyaltyXTokenId1TBA), 1);

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

    //test function testDeployMembership with more than the max membership tiers
    function testDeployMembershipMultipleTiers() public {
        //first deploy brand
        // deploy brandX
        vm.prank(tronicAdmin);
        (uint256 brandId, address brandXLoyaltyAddress, address brandXTokenAddress) =
        tronicMainContract.deployBrand(
            "Brand ZZZ", // brand name
            "BRDZZZ",
            "http://example.com/token/",
            false
        );

        //instance of brandLoyalty contract
        TronicBrandLoyalty brandLoyalty = TronicBrandLoyalty(brandXLoyaltyAddress);

        // Verify that the brand contract was deployed successfully
        assertTrue(brandXLoyaltyAddress != address(0), "Brand contract address should not be null");
        assertEq(brandLoyalty.owner(), tronicAdmin, "Brand contract owner should be tronicAdmin");

        // Verify brand contract properties
        assertEq(brandLoyalty.name(), "Brand ZZZ", "Brand name should match");

        //create 11 tiers for input
        ITronicMembership.MembershipTier[] memory membershipTiers =
            new ITronicMembership.MembershipTier[](11);

        //create 11 tiers
        for (uint8 i = 0; i < 11; i++) {
            membershipTiers[i] = ITronicMembership.MembershipTier(
                string(abi.encodePacked("tier", i)),
                100,
                false,
                string(abi.encodePacked("http://example.com/tier", i))
            );
        }

        // deploy membership
        vm.startPrank(tronicAdmin);
        vm.expectRevert();
        (uint256 membershipID, address membershipZAddress) = tronicMainContract.deployMembership(
            brandId,
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            membershipTiers
        );
    }
}
