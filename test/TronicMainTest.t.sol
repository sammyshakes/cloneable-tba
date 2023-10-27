// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract TronicMainTest is TronicTestBase {
    function testInitialSetup() public {
        assertEq(tronicMainContract.owner(), tronicOwner);
        assertEq(tronicMainContract.membershipCounter(), 2);
        console.log("tronicMainContract address: ", address(tronicMainContract));
        console.log("tronicERC721 address: ", address(tronicERC721));
        console.log("tronicERC1155 address: ", address(tronicERC1155));
        console.log("defaultTBAImplementationAddress: ", defaultTBAImplementationAddress);
        console.log("registryAddress: ", registryAddress);
        console.log("clone721AddressX: ", clone721AddressX);
        console.log("clone1155AddressX: ", clone1155AddressX);
        console.log("clone721AddressY: ", clone721AddressY);
        console.log("clone1155AddressY: ", clone1155AddressY);

        // check that the membership details are correctly set
        assertEq(membershipX.membershipAddress, clone721AddressX);
        assertEq(membershipX.tokenAddress, clone1155AddressX);
        assertEq(membershipY.membershipAddress, clone721AddressY);
        assertEq(membershipY.tokenAddress, clone1155AddressY);

        //assert that TronicAdmin Contract is the owner of membership erc721 and erc1155 token contracts
        assertEq(tronicAdmin, membershipXERC721.owner());
        assertEq(tronicAdmin, membershipXERC1155.owner());
        assertEq(tronicAdmin, membershipYERC721.owner());
        assertEq(tronicAdmin, membershipYERC1155.owner());

        // get owner of tokenid 1
        address owner = tronicERC721.ownerOf(1);
        console.log("owner of tokenid 1: ", owner);
    }

    function testCreateFungibleType() public {
        // Set up initial state
        uint64 initialMaxSupply = 1000;
        string memory initialUriX = "http://exampleX.com/token/";
        string memory initialUriY = "http://exampleY.com/token/";

        // Admin creates a fungible token type for membershipX and membershipY
        vm.startPrank(tronicAdmin);
        uint256 fungibleIDX =
            tronicMainContract.createFungibleTokenType(initialMaxSupply, initialUriX, membershipIDX);

        //create a new fungible token type for membershipY
        uint256 fungibleIDY =
            tronicMainContract.createFungibleTokenType(initialMaxSupply, initialUriY, membershipIDY);

        vm.stopPrank();

        // Verify that the new token type has the correct attributes
        TronicToken.FungibleTokenInfo memory tokenInfo =
            membershipXERC1155.getFungibleTokenInfo(fungibleIDX);

        assertEq(tokenInfo.maxSupply, initialMaxSupply, "Incorrect maxSupply");
        assertEq(tokenInfo.uri, initialUriX, "Incorrect URI");
        assertEq(tokenInfo.totalMinted, 0, "Incorrect totalMinted");
        assertEq(tokenInfo.totalBurned, 0, "Incorrect totalBurned");

        // Verify that the new token type has the correct attributes
        TronicToken.FungibleTokenInfo memory tokenInfoY =
            membershipYERC1155.getFungibleTokenInfo(fungibleIDY);

        assertEq(tokenInfoY.maxSupply, initialMaxSupply, "Incorrect maxSupply");
        assertEq(tokenInfoY.uri, initialUriY, "Incorrect URI");
        assertEq(tokenInfoY.totalMinted, 0, "Incorrect totalMinted");
        assertEq(tokenInfoY.totalBurned, 0, "Incorrect totalBurned");

        // mint 100 tokens to user1's tba
        vm.startPrank(tronicAdmin);
        tronicMainContract.mintFungibleToken(membershipIDX, tronicTokenId1TBA, fungibleIDX, 100);

        assertEq(membershipXERC1155.balanceOf(tronicTokenId1TBA, fungibleIDX), 100);

        // attempt to mint from invalid membership
        vm.expectRevert("Membership does not exist");
        tronicMainContract.mintFungibleToken(100, tronicTokenId1TBA, fungibleIDX, 100);

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
            tronicMainContract.createNonFungibleTokenType(initialUriX, maxMintable, membershipIDX);

        //create a new non-fungible token type for membershipY
        uint256 nonFungibleIDY =
            tronicMainContract.createNonFungibleTokenType(initialUriY, maxMintable, membershipIDY);

        vm.stopPrank();

        // Verify that the new token type has the correct attributes
        TronicToken.NFTokenInfo memory tokenInfo = membershipXERC1155.getNFTokenInfo(nonFungibleIDX);

        assertEq(tokenInfo.baseURI, initialUriX, "Incorrect URI");
        assertEq(tokenInfo.maxMintable, maxMintable, "Incorrect maxMintable");
        assertEq(tokenInfo.totalMinted, 0, "Incorrect totalMinted");

        // Verify that the new token type has the correct attributes
        TronicToken.NFTokenInfo memory tokenInfoY =
            membershipYERC1155.getNFTokenInfo(nonFungibleIDY);

        assertEq(tokenInfoY.baseURI, initialUriY, "Incorrect URI");
        assertEq(tokenInfoY.maxMintable, maxMintable, "Incorrect maxMintable");
        assertEq(tokenInfoY.totalMinted, 0, "Incorrect totalMinted");

        // uint256 userBalanceBefore = membershipXERC1155.balanceOf(user1, nonFungibleIDX);

        // mint a non-fungible token to user1
        // vm.prank(tronicAdmin);
        // tronicMainContract.mintNonFungibleERC1155(membershipIDX, user1, nonFungibleIDX, 1);

        // assertEq(membershipXERC1155.balanceOf(user1, nonFungibleIDX), userBalanceBefore + 1);
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
        string[] memory tiers;
        uint128[] memory durations;
        bool[] memory isOpens;

        // Simulate as admin
        vm.prank(tronicAdmin);

        vm.expectEmit();
        // Call the deployAndAddMembership function
        (uint256 membershipIDX, address testClone721Address, address testClone1155AddressY) =
        tronicMainContract.deployMembership(
            name721, symbol721, uri721, maxSupply, true, false, tiers, durations, isOpens
        );

        // Make sure membershipCount was next index
        assertEq(membershipIDX, membershipCount);

        // Retrieve the added membership's details
        TronicMain.MembershipInfo memory membership =
            tronicMainContract.getMembershipInfo(membershipIDX);

        // Assert that the membership's details are correctly set
        assertEq(membership.membershipAddress, testClone721Address);
        assertEq(membership.tokenAddress, testClone1155AddressY);
        assertEq(membership.membershipName, name721);

        //get tier index by tier id from tronicMain
        uint8 tierIndex = tronicMainContract.getTierIndexByTierId(membershipIDX, "tier1");

        //attempt to get tier index by tier id from tronicMain with invalid membership id
        vm.expectRevert("Membership does not exist");
        tierIndex = tronicMainContract.getTierIndexByTierId(100, "tier3");
    }

    // test getAccount function from tronic membership contract
    function testGetAccount() public {
        // get the token bound account
        address account = tronicERC721.getTBAccount(1);

        console.log("tokenbound account address: ", account);

        // check that the account is correct
        assertEq(account, tronicTokenId1TBA);
    }

    //test createFungibleType and nonfungible function from tronic main contract for membership that does not exist
    function testCreateTypes() public {
        // Set up initial state
        uint64 initialMaxSupply = 1000;
        string memory initialUriX = "http://exampleX.com/token/";

        // create a fungible token type
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Membership does not exist");
        tronicMainContract.createFungibleTokenType(initialMaxSupply, initialUriX, 100);

        //now test nonfungible
        string memory initialUriY = "http://exampleY.com/token/";
        uint64 maxMintable = 1000;

        // create a non-fungible token type
        vm.expectRevert("Membership does not exist");
        tronicMainContract.createNonFungibleTokenType(initialUriY, maxMintable, 100);
    }

    //test mintMembership function from tronic main contract
    function testMintMembership() public {
        //set up recipient, membershipId, and tierIndex
        address recipient = user1;
        uint256 membershipId = membershipIDX;
        uint8 tierIndex = 6;

        //try to mint with invalid tierIndex
        vm.startPrank(tronicAdmin);
        vm.expectRevert("Tier does not exist");
        (address payable tba, uint256 tokenId) =
            tronicMainContract.mintMembership(recipient, membershipId, 250);

        //try to mint with invalid membershipId
        vm.expectRevert("Membership does not exist");
        (tba, tokenId) = tronicMainContract.mintMembership(recipient, 250, tierIndex);

        //mint valid membership
        //create tiers for membershipX
        string[] memory tiers = new string[](2);
        tiers[0] = "tier1";
        tiers[1] = "tier2";

        //create durations for membershipX
        uint128[] memory durations = new uint128[](2);
        durations[0] = 100;
        durations[1] = 200;

        //create isOpens for membershipX
        bool[] memory isOpens = new bool[](2);
        isOpens[0] = true;
        isOpens[1] = false;

        //call setMembershipTiers function
        membershipXERC721.createMembershipTiers(tiers, durations, isOpens);

        (tba, tokenId) = tronicMainContract.mintMembership(recipient, membershipId, 0);

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
        tronicMainContract.createMembershipTier(100, tier, duration, isOpen);

        //call createMembershipTier function
        tronicMainContract.createMembershipTier(membershipIDX, tier, duration, isOpen);

        //get tier index by tier id from tronicMain
        uint8 tierIndex = tronicMainContract.getTierIndexByTierId(membershipIDX, "tier1");

        //first attempt to get tier info from invalid membership id
        vm.expectRevert("Membership does not exist");
        tronicMainContract.getMembershipTierInfo(100, tierIndex);

        //get tier info from membershipXERC721
        TronicMembership.MembershipTier memory membershipTier =
            tronicMainContract.getMembershipTierInfo(membershipIDX, tierIndex);

        //assert that tier info is correct
        assertEq(membershipTier.tierId, tier);
        assertEq(membershipTier.duration, duration);
        assertEq(membershipTier.isOpen, isOpen);

        //attempt to set membership tier with invalid membership id
        vm.expectRevert("Membership does not exist");
        tronicMainContract.setMembershipTier(100, tierIndex, tier, duration, isOpen);

        //attempt to set membership tier with invalid tier index
        vm.expectRevert("Tier does not exist");
        tronicMainContract.setMembershipTier(membershipIDX, 100, tier, duration, isOpen);

        // set a valid membership tier
        tronicMainContract.setMembershipTier(
            membershipIDX, tierIndex, "changedTier", 1_000_000, isOpen
        );

        //get tier info from membershipXERC721
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
        vm.expectRevert("Membership does not exist");
        tronicMainContract.mintNonFungibleToken(invalidInt, recipient, nonFungibleTypeIdX1, amount);

        //try to mint with invalid nonFungibleTypeId
        vm.expectRevert("NFT type does not exist");
        tronicMainContract.mintNonFungibleToken(membershipIDX, recipient, invalidInt, amount);

        //mint valid nonFungibleToken
        tronicMainContract.mintNonFungibleToken(
            membershipIDX, recipient, nonFungibleTypeIdX1, amount
        );

        //get the tokenid of tokens owned by recipient
        uint256[] memory tokenIds = membershipXERC1155.getNftIdsForOwner(recipient);

        //verify that the token was minted to the correct recipient
        assertEq(membershipXERC1155.balanceOf(recipient, tokenIds[0]), amount);

        vm.stopPrank();
    }
}
