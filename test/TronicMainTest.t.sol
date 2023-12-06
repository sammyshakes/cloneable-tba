// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract TronicMainTest is TronicTestBase {
    function testInitialSetup() public {
        assertEq(tronicMainContract.owner(), tronicOwner);
        assertEq(tronicMainContract.membershipCounter(), 2);
        console.log("tronicMainContract address: ", address(tronicMainContract));
        console.log("tronicMembership address: ", address(tronicMembership));
        console.log("tronicBrandLoyalty address: ", address(tronicBrandLoyaltyImplementation));
        console.log("defaultTBAImplementationAddress: ", defaultTBAImplementationAddress);
        console.log("registryAddress: ", registryAddress);
        console.log("brandLoyaltyAddressX: ", brandLoyaltyAddressX);
        console.log("brandXMembershipAddress: ", address(brandXMembership));
        console.log("brandXTokenAddress: ", address(brandXToken));
        console.log("brandLoyaltyAddressY: ", brandLoyaltyAddressY);
        console.log("brandYMembershipAddress: ", address(brandYMembership));
        console.log("brandYTokenAddress: ", address(brandYToken));

        // check that the membership details are correctly set
        assertEq(membershipX.membershipAddress, address(brandXMembership));
        assertEq(membershipY.membershipAddress, address(brandYMembership));

        //assert that TronicAdmin Contract is the owner of membership erc721 and erc1155 token contracts
        assertEq(tronicAdmin, brandLoyaltyX.owner());
        assertEq(tronicAdmin, brandXToken.owner());
        assertEq(tronicAdmin, brandLoyaltyY.owner());
        assertEq(tronicAdmin, brandYToken.owner());

        // get owner of tokenid 1
        address owner = brandLoyaltyX.ownerOf(1);
        console.log("owner of tokenid 1: ", owner);
    }

    //test getBrandLoyaltyTBA from tronicmain
    function testGetBrandLoyaltyTBA() public {
        //attempt to get brand loyalty tba from invalid brand id
        vm.expectRevert("Brand does not exist");
        tronicMainContract.getBrandLoyaltyTBA(100, 1);

        //get the token bound account address (from tokenId) and verify that it is correct
        address brandTBAddress = tronicMainContract.getBrandLoyaltyTBA(brandIDX, 1);
        console.log("brandTBAddress: ", brandTBAddress);
    }

    function testCreateFungibleType() public {
        // Set up initial state
        uint64 initialMaxSupply = 1000;
        string memory initialUriX = "http://exampleX.com/token/";
        string memory initialUriY = "http://exampleY.com/token/";

        // Admin creates a fungible token type for membershipX and membershipY
        vm.startPrank(tronicAdmin);
        uint256 fungibleIDX =
            tronicMainContract.createFungibleTokenType(brandIDX, initialMaxSupply, initialUriX);

        //create a new fungible token type for membershipY
        uint256 fungibleIDY =
            tronicMainContract.createFungibleTokenType(brandIDY, initialMaxSupply, initialUriY);

        vm.stopPrank();

        // Verify that the new token type has the correct attributes
        TronicToken.FungibleTokenInfo memory tokenInfo =
            brandXToken.getFungibleTokenInfo(fungibleIDX);

        assertEq(tokenInfo.maxSupply, initialMaxSupply, "Incorrect maxSupply");
        assertEq(tokenInfo.uri, initialUriX, "Incorrect URI");
        assertEq(tokenInfo.totalMinted, 0, "Incorrect totalMinted");
        assertEq(tokenInfo.totalBurned, 0, "Incorrect totalBurned");

        // Verify that the new token type has the correct attributes
        TronicToken.FungibleTokenInfo memory tokenInfoY =
            brandYToken.getFungibleTokenInfo(fungibleIDY);

        assertEq(tokenInfoY.maxSupply, initialMaxSupply, "Incorrect maxSupply");
        assertEq(tokenInfoY.uri, initialUriY, "Incorrect URI");
        assertEq(tokenInfoY.totalMinted, 0, "Incorrect totalMinted");
        assertEq(tokenInfoY.totalBurned, 0, "Incorrect totalBurned");

        // mint 100 tokens to user1's tba
        vm.startPrank(tronicAdmin);
        tronicMainContract.mintFungibleToken(
            membershipIDX, brandLoyaltyXTokenId1TBA, fungibleIDX, 100
        );

        assertEq(brandXToken.balanceOf(brandLoyaltyXTokenId1TBA, fungibleIDX), 100);

        // attempt to mint from invalid membership
        vm.expectRevert("Brand does not exist");
        tronicMainContract.mintFungibleToken(100, brandLoyaltyXTokenId1TBA, fungibleIDX, 100);

        vm.stopPrank();
    }

    function testCreateNonFungibleType() public {
        // Set up initial state
        string memory initialUriX = "http://exampleNFTX.com/token";
        string memory initialUriY = "http://exampleNFTY.com/token";
        uint64 maxMintable = 1000;

        // Admin creates a non-fungible token type for membershipX and membershipY
        vm.startPrank(tronicAdmin);
        uint256 nonFungibleIDX =
            tronicMainContract.createNonFungibleTokenType(brandIDX, initialUriX, maxMintable);

        //create a new non-fungible token type for membershipY
        uint256 nonFungibleIDY =
            tronicMainContract.createNonFungibleTokenType(brandIDY, initialUriY, maxMintable);

        vm.stopPrank();

        // Verify that the new token type has the correct attributes
        TronicToken.NFTokenInfo memory tokenInfo = brandXToken.getNFTokenInfo(nonFungibleIDX);

        assertEq(tokenInfo.baseURI, initialUriX, "Incorrect URI");
        assertEq(tokenInfo.maxMintable, maxMintable, "Incorrect maxMintable");
        assertEq(tokenInfo.totalMinted, 0, "Incorrect totalMinted");

        // Verify that the new token type has the correct attributes
        TronicToken.NFTokenInfo memory tokenInfoY = brandYToken.getNFTokenInfo(nonFungibleIDY);

        assertEq(tokenInfoY.baseURI, initialUriY, "Incorrect URI");
        assertEq(tokenInfoY.maxMintable, maxMintable, "Incorrect maxMintable");
        assertEq(tokenInfoY.totalMinted, 0, "Incorrect totalMinted");

        // uint256 userBalanceBefore = brandXToken.balanceOf(user1, nonFungibleIDX);

        // mint a non-fungible token to user1
        // vm.prank(tronicAdmin);
        // tronicMainContract.mintNonFungibleERC1155(membershipIDX, user1, nonFungibleIDX, 1);

        // assertEq(brandXToken.balanceOf(user1, nonFungibleIDX), userBalanceBefore + 1);
    }

    function testDeployAndAddMembership() public {
        // get membership count
        uint256 membershipCount = tronicMainContract.membershipCounter();

        // Define membership details
        string memory name721 = "TestClone721";
        string memory symbol721 = "TCL721";
        string memory uri721 = "http://testclone721.com/";

        // maxsupply for membership erc721
        uint64 maxSupply = 10_000;

        //create tiers for membershipX
        ITronicMembership.MembershipTier[] memory tiers = new ITronicMembership.MembershipTier[](2);
        ITronicMembership.MembershipTier memory tier1 =
            ITronicMembership.MembershipTier("tier1", 1 days, true, "tier1URI");

        ITronicMembership.MembershipTier memory tier2 =
            ITronicMembership.MembershipTier("tier2", 2 days, true, "tier2URI");

        tiers[0] = tier1;
        tiers[1] = tier2;

        // Simulate as admin
        vm.prank(tronicAdmin);

        // vm.expectEmit();
        // Call the deployAndAddMembership function
        (uint256 membershipIDX, address testClone721Address) = tronicMainContract.deployMembership(
            brandIDX, name721, symbol721, uri721, maxSupply, true, tiers
        );

        // Make sure membershipCount was next index
        assertEq(membershipIDX, membershipCount + 1);

        // Retrieve the added membership's details
        TronicMain.MembershipInfo memory membership =
            tronicMainContract.getMembershipInfo(membershipIDX);

        // Assert that the membership's details are correctly set
        assertEq(membership.membershipAddress, testClone721Address);

        //get tier index by tier id from tronicMain
        uint8 tierIndex = tronicMainContract.getTierIndexByTierId(membershipIDX, "tier1");

        //attempt to get tier index by tier id from tronicMain with invalid membership id
        vm.expectRevert("Membership does not exist");
        tierIndex = tronicMainContract.getTierIndexByTierId(100, "tier3");
    }

    //test deploy membership with multiple tiers
    function testDeployAndAddMembershipWithMultipleTiers() public {
        // get membership count
        uint256 membershipCount = tronicMainContract.membershipCounter();

        // Define membership tiers
        ITronicMembership.MembershipTier[] memory tiers = new ITronicMembership.MembershipTier[](2);
        ITronicMembership.MembershipTier memory tier1 =
            ITronicMembership.MembershipTier("tier1", 1 days, true, "tier1URI");

        ITronicMembership.MembershipTier memory tier2 =
            ITronicMembership.MembershipTier("tier2", 2 days, true, "tier2URI");

        tiers[0] = tier1;
        tiers[1] = tier2;

        // Define membership details
        string memory name721 = "TestClone721";
        string memory symbol721 = "TCL721";
        string memory uri721 = "http://testclone721.com/";

        // Simulate as admin
        vm.prank(tronicAdmin);

        // vm.expectEmit();
        // Call the deployAndAddMembership function
        (uint256 membershipIDX, address testClone721Address) = tronicMainContract.deployMembership(
            brandIDX, name721, symbol721, uri721, 10_000, true, tiers
        );

        // Make sure membershipCount was next index
        assertEq(membershipIDX, membershipCount + 1);

        // Retrieve the added membership's details
        TronicMain.MembershipInfo memory membership =
            tronicMainContract.getMembershipInfo(membershipIDX);

        // Assert that the membership's details are correctly set
        assertEq(membership.membershipAddress, testClone721Address);
        assertEq(membership.membershipName, name721);
    }

    // test getAccount function from tronic membership contract
    function testGetAccount() public {
        // get the token bound account
        address account = brandLoyaltyX.getTBAccount(1);

        console.log("tokenbound account address: ", account);

        // check that the account is correct
        assertEq(account, brandLoyaltyXTokenId1TBA);
    }

    //test createFungibleType and nonfungible function from tronic main contract for membership that does not exist
    function testCreateTypes() public {
        // Set up initial state
        uint64 initialMaxSupply = 1000;
        string memory initialUriX = "http://exampleX.com/token/";

        // create a fungible token type
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Brand does not exist");
        tronicMainContract.createFungibleTokenType(100, initialMaxSupply, initialUriX);

        //now test nonfungible
        string memory initialUriY = "http://exampleY.com/token/";
        uint64 maxMintable = 1000;

        // create a non-fungible token type
        vm.expectRevert("Brand does not exist");
        tronicMainContract.createNonFungibleTokenType(100, initialUriY, maxMintable);
    }

    //test mintMembership function from tronic main contract
    function testMintMembership() public {
        //set up recipient, membershipId, and tierIndex
        address recipient = address(0x0444);
        uint256 membershipId = membershipIDX;

        //try to mint user 1 a second membership
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Recipient already owns a membership token");
        uint256 tokenId = tronicMainContract.mintMembership(user1, membershipId, 1);

        //try to mint invalid tierIndex
        vm.expectRevert("Tier does not exist");
        tokenId = tronicMainContract.mintMembership(recipient, membershipId, 250);

        //try to mint with invalid membershipId
        vm.expectRevert("Membership does not exist");
        tokenId = tronicMainContract.mintMembership(recipient, 250, 6);

        //create tiers for membershipX
        ITronicMembership.MembershipTier[] memory tiers = new ITronicMembership.MembershipTier[](2);
        ITronicMembership.MembershipTier memory tier1 =
            ITronicMembership.MembershipTier("tier1", 1 days, true, "tier1URI");

        ITronicMembership.MembershipTier memory tier2 =
            ITronicMembership.MembershipTier("tier2", 2 days, true, "tier2URI");

        tiers[0] = tier1;
        tiers[1] = tier2;

        //call setMembershipTiers function
        brandXMembership.createMembershipTiers(tiers);

        //mint with tier id 0 (no tier)
        tokenId = tronicMainContract.mintMembership(recipient, membershipId, 0);

        // try to mint a second membership to recipient
        vm.expectRevert("Recipient already owns a membership token");
        tokenId = tronicMainContract.mintMembership(recipient, membershipId, 1);

        vm.stopPrank();
    }

    //test setMembershipTiers function from tronic main contract
    function testSetMembershipTier() public {
        //create tier for membershipX
        string memory tier = "tier1";
        uint128 duration = 100;
        bool isOpen = true;

        //first try to set membership tier with invalid membership id
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Membership does not exist");
        tronicMainContract.createMembershipTier(100, tier, duration, isOpen, "tierURI");

        //call createMembershipTier function
        tronicMainContract.createMembershipTier(membershipIDX, tier, duration, isOpen, "tierURI");

        //get tier index by tier id from tronicMain
        uint8 tierIndex = tronicMainContract.getTierIndexByTierId(membershipIDX, "tier1");

        //first attempt to get tier info from invalid membership id
        vm.expectRevert("Membership does not exist");
        tronicMainContract.getMembershipTierInfo(100, tierIndex);

        //get tier info from brandXMembership
        TronicMembership.MembershipTier memory membershipTier =
            tronicMainContract.getMembershipTierInfo(membershipIDX, tierIndex);

        //assert that tier info is correct
        assertEq(membershipTier.tierId, tier);
        assertEq(membershipTier.duration, duration);
        assertEq(membershipTier.isOpen, isOpen);

        //attempt to set membership tier with invalid membership id
        vm.expectRevert("Membership does not exist");
        tronicMainContract.setMembershipTier(100, tierIndex, tier, duration, isOpen, "tierURI");

        //attempt to set membership tier with invalid tier index
        vm.expectRevert("Tier does not exist");
        tronicMainContract.setMembershipTier(membershipIDX, 100, tier, duration, isOpen, "tierURI");

        // set a valid membership tier
        tronicMainContract.setMembershipTier(
            membershipIDX, tierIndex, "changedTier", 1_000_000, isOpen, "changedTierURI"
        );

        //get tier info from brandXMembership
        membershipTier = tronicMainContract.getMembershipTierInfo(membershipIDX, tierIndex);

        //assert that tier info is correct
        assertEq(membershipTier.tierId, "changedTier");
        assertEq(membershipTier.duration, 1_000_000);
        assertEq(membershipTier.isOpen, isOpen);

        vm.stopPrank();
    }

    //test mintNonFungibleToken function from tronic main contract
    function testMintNonFungibleToken() public {
        //set up recipient, membershipId, and nonFungibleTypeId
        address recipient = user3;
        uint256 invalidInt = 1000;
        uint256 amount = 1;

        //try to mint with invalid membershipId
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Brand does not exist");
        tronicMainContract.mintNonFungibleToken(invalidInt, recipient, nonFungibleTypeIdX1, amount);

        //try to mint with invalid nonFungibleTypeId
        vm.expectRevert("NFT type does not exist");
        tronicMainContract.mintNonFungibleToken(membershipIDX, recipient, invalidInt, amount);

        //mint valid nonFungibleToken
        tronicMainContract.mintNonFungibleToken(
            membershipIDX, recipient, nonFungibleTypeIdX1, amount
        );

        //get the tokenid of tokens owned by recipient
        uint256[] memory tokenIds = brandXToken.getNftIdsForOwner(recipient);

        //verify that the token was minted to the correct recipient
        assertEq(brandXToken.balanceOf(recipient, tokenIds[0]), amount);

        vm.stopPrank();
    }

    function testUpdateERC721Implementation() public {
        //update implementation address
        vm.prank(tronicOwner);
        tronicMainContract.setMembershipImplementation(payable(address(0xdeadbeef)));

        //get new implementation address
        address newImplementation = address(tronicMainContract.tronicMembership());

        //verify that implementation address has changed
        assertEq(newImplementation, address(0xdeadbeef));
    }

    // test setERC1155Implementation
    function testUpdateERC1155Implementation() public {
        //update implementation address
        vm.prank(tronicOwner);
        tronicMainContract.setTokenImplementation(payable(address(0xdeadbeef)));

        //get new implementation address
        address newImplementation = address(tronicMainContract.tronicToken());

        //verify that implementation address has changed
        assertEq(newImplementation, address(0xdeadbeef));
    }

    //test update brand loyalty implementation
    function testUpdateBrandLoyaltyImplementation() public {
        //update implementation address
        vm.prank(tronicOwner);
        tronicMainContract.setLoyaltyTokenImplementation(payable(address(0xdeadbeef)));

        //get new implementation address
        address newImplementation = address(tronicMainContract.tronicBrandLoyalty());

        //verify that implementation address has changed
        assertEq(newImplementation, address(0xdeadbeef));
    }

    //test setAccountImplementation
    function testUpdateAccountImplementation() public {
        //update implementation address
        vm.prank(tronicOwner);
        tronicMainContract.setAccountImplementation(payable(address(0xdeadbeef)));

        //get new implementation address
        address newImplementation = tronicMainContract.tbaAccountImplementation();

        //verify that implementation address has changed
        assertEq(newImplementation, address(0xdeadbeef));
    }

    //test setRegistry
    function testUpdateRegistry() public {
        //update implementation address
        vm.prank(tronicOwner);
        tronicMainContract.setRegistry(address(0xdeadbeef));

        //get new implementation address
        address newRegistry = address(tronicMainContract.registry());

        //verify that implementation address has changed
        assertEq(newRegistry, address(0xdeadbeef));
    }

    //test admin functions
    function testAdmin() public {
        //check admin of tronicMain
        assertTrue(tronicMainContract.isAdmin(tronicAdmin));

        //check admin of membershipX
        assertTrue(brandXMembership.isAdmin(tronicAdmin));

        //check admin of membershipY
        assertTrue(brandYMembership.isAdmin(tronicAdmin));

        // set admin of tronicMain to user1
        vm.prank(tronicOwner);
        tronicMainContract.addAdmin(user1);

        //check admin of tronicMain
        assertTrue(tronicMainContract.isAdmin(user1));

        // remove admin of tronicMain
        vm.prank(tronicOwner);
        tronicMainContract.removeAdmin(user1);

        //check admin of tronicMain
        assertTrue(!tronicMainContract.isAdmin(user1));
    }

    //test remove membership
    function testRemoveMembership() public {
        //remove membership
        vm.prank(tronicAdmin);
        tronicMainContract.removeMembership(membershipIDX);

        //attempt to remove membership by non admin
        vm.expectRevert("Only admin");
        tronicMainContract.removeMembership(100);
    }

    //test getBrandIdFromBrandLoyaltyAddress
    function testGetBrandIdFromBrandLoyaltyAddress() public {
        //get brand id from brand loyalty address
        uint256 brandId = tronicMainContract.getBrandIdFromBrandLoyaltyAddress(brandLoyaltyAddressX);

        //verify that brand id is correct
        assertEq(brandId, brandIDX);

        //get brand id from brand loyalty Y address
        brandId = tronicMainContract.getBrandIdFromBrandLoyaltyAddress(brandLoyaltyAddressY);

        //verify that brand id is correct
        assertEq(brandId, brandIDY);
    }

    //test getBrandIdFromMembershipId
    function testGetBrandIdFromMembershipId() public {
        //get brand id from membership id
        uint256 brandId = tronicMainContract.getBrandIdFromMembershipId(membershipIDX);

        //verify that brand id is correct
        assertEq(brandId, brandIDX);
    }
}
