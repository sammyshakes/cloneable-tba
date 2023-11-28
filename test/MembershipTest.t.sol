// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract MembershipTest is TronicTestBase {
    function testMemberships() public {
        ITronicMembership.MembershipTier[] memory membershipTiers =
            new ITronicMembership.MembershipTier[](2);

        // deploy membership with isBound set to false for BrandX
        vm.startPrank(tronicAdmin);
        (, address membershipZ) = tronicMainContract.deployMembership(
            brandIDX,
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            membershipTiers
        );

        //instance of membershipZERC721
        TronicMembership membershipZERC721 = TronicMembership(membershipZ);

        // mint token to user1, tier index 1
        membershipZERC721.mint(user1, 1);

        // get token membership tier
        membershipZERC721.getMembershipToken(1);

        // create membership tier for membershipZ
        uint8 tierId = membershipZERC721.createMembershipTier("tier1", 100, true, "tierURI");

        //set membership tier by tierIndex (takes in tierIndex, and a generated MembershipTier struct with updated info)
        membershipZERC721.setMembershipTier(1, "tier1", 1000, false, "tier1URI");

        //verify that membership tier
        assertEq(membershipZERC721.getMembershipTierDetails(tierId).isOpen, true);
        assertEq(membershipZERC721.getMembershipTierDetails(tierId).duration, 100);

        // get token membership tier
        membershipZERC721.getMembershipToken(1);

        // expire token membership
        vm.warp(block.timestamp + 1);

        // check if token membership is valid
        assertEq(membershipZERC721.isValid(1), true);

        // expire token membership
        vm.warp(block.timestamp + 1001);

        // ensure token membership is expired
        assertEq(membershipZERC721.isValid(1), false);

        // set membership tier by tierIndex (takes in tierIndex, and a generated MembershipTier struct with updated info)
        membershipZERC721.setMembershipTier(1, "tier1", 1000, false, "tier1URI");

        //verify the changed membership tier
        assertEq(membershipZERC721.getMembershipTierDetails(1).isOpen, false);
        assertEq(membershipZERC721.getMembershipTierDetails(1).duration, 1000);

        //test setting baseURI
        membershipZERC721.setBaseURI("http://example.com/token/");

        //test supports interface
        assertEq(membershipZERC721.supportsInterface(0x80ac58cd), true);

        vm.stopPrank();

        //use safeTransferFrom to transfer token to user2
        vm.prank(user1);
        membershipZERC721.safeTransferFrom(user1, user2, 1);

        //verify that user2 owns token
        assertEq(membershipZERC721.ownerOf(1), user2);
    }

    //write function to test totalSupply
    function testTotalSupply() public {
        // deploy membership with isBound set to false
        vm.prank(tronicAdmin);
        (, address membershipZ) = tronicMainContract.deployMembership(
            brandIDX,
            "membershipZ",
            "MEMZ",
            "http://example.com/token/",
            10_000,
            false,
            membershipTiers
        );

        //instance of membershipZERC721
        TronicMembership membershipZERC721 = TronicMembership(membershipZ);

        // mint token to user1
        vm.prank(tronicAdmin);
        membershipZERC721.mint(user1, 0);

        // verify total supply
        assertEq(membershipZERC721.totalSupply(), 1);

        // mint token to user2
        vm.prank(tronicAdmin);
        membershipZERC721.mint(user2, 0);

        // verify total supply
        assertEq(membershipZERC721.totalSupply(), 2);

        //now burn token
        vm.prank(tronicAdmin);
        membershipZERC721.burn(1);

        // verify total supply
        assertEq(membershipZERC721.totalSupply(), 1);

        //now burn token
        vm.prank(tronicAdmin);
        membershipZERC721.burn(2);

        // verify total supply
        assertEq(membershipZERC721.totalSupply(), 0);
    }

    // TODO: Rewrite to test Bound BRandLoyalty tokens

    // //write function to test bound memberships then try to transfer
    // function testBoundMemberships() public {
    //     // deploy membership with isBound set to false
    //     vm.prank(tronicAdmin);
    //     (uint256 memberZID, address membershipZ) = tronicMainContract.deployMembership(
    //         brandIDX,
    //         "membershipZ",
    //         "MEMZ",
    //         "http://example.com/token/",
    //         10_000,
    //         false,
    //         membershipTiers
    //     );

    // //instance of membershipZERC721
    // TronicMembership membershipZERC721 = TronicMembership(membershipZ);

    // // mint token to user1's TBA
    // vm.prank(tronicAdmin);
    // membershipZERC721.mint(tronicTokenId1TBA, 0);

    // // try to transfer token to user2's tba (should revert because token is soulbound)
    // vm.startPrank(user1);

    // -------------memberships are no longer bound, but brand loyalty tokens are---------//
    //
    // //setPermissions for tronicMainContract to transfer membership
    // bool[] memory approved = new bool[](1);
    // approved[0] = true;
    // address[] memory approvedAddresses = new address[](1);
    // approvedAddresses[0] = address(tronicMainContract);

    // IERC6551Account tokenId1TronicTBA = IERC6551Account(payable(address(tronicTokenId1TBA)));
    // tokenId1TronicTBA.setPermissions(approvedAddresses, approved);

    // // transfer user1's membershipZ nft to user2's tba
    // vm.expectRevert("Token is bound");
    // tronicMainContract.transferMembershipFromTronicTBA(1, memberZID, 1, tronicTokenId2TBA);
    // vm.stopPrank();

    // //also try fropm membership contract
    // vm.startPrank(tronicAdmin);
    // vm.expectRevert("Token is bound");
    // membershipZERC721.transferFrom(tronicTokenId1TBA, tronicTokenId2TBA, 1);
    // vm.stopPrank();
    // }

    //test admin functionality of tronicMembership
    function testAdmin() public {
        //check admin of tronicMembership
        assertTrue(tronicMembership.isAdmin(tronicAdmin));

        //check admin of membershipX
        assertTrue(brandXMembership.isAdmin(tronicAdmin));

        //check admin of membershipY
        assertTrue(brandYMembership.isAdmin(tronicAdmin));

        // set admin of tronicMembership to user1
        vm.prank(tronicAdmin);
        tronicMembership.addAdmin(user1);

        //check admin of tronicMembership
        assertTrue(tronicMembership.isAdmin(user1));

        // remove admin of tronicMembership
        vm.prank(tronicAdmin);
        tronicMembership.removeAdmin(user1);

        //check admin of tronicMembership
        assertTrue(!tronicMembership.isAdmin(user1));
    }

    //test updateImplementation on tronicMembership
    function testUpdateImplementation() public {
        //update implementation address
        vm.prank(tronicAdmin);
        tronicBrandLoyaltyImplementation.updateImplementation(payable(address(0xdeadbeef)));

        //get new implementation address
        address newImplementation = tronicBrandLoyaltyImplementation.accountImplementation();

        //verify that implementation address has changed
        assertEq(newImplementation, address(0xdeadbeef));
    }

    //test if maxsupply is elastic
    function testMaxSupply() public {
        //get maxSupply
        uint256 maxSupply = tronicMembership.maxSupply();
        //get totalSupply
        uint256 totalSupply = tronicMembership.totalSupply();

        //mint token to user1
        vm.prank(tronicAdmin);
        tronicMembership.mint(user1, 0);

        //verify that only totalSupply has increased
        assertEq(tronicMembership.maxSupply(), maxSupply);
        assertEq(tronicMembership.totalSupply(), totalSupply + 1);
    }

    //test minting more than maxSupply
    function testMintingMoreThanMaxSupply() public {
        //get totalSupply
        uint256 totalSupply = tronicMembership.totalSupply();

        //try to set max supply to totalSupply
        vm.startPrank(tronicAdmin);
        vm.expectRevert();
        tronicMembership.setMaxMintable(totalSupply);

        // set maxsupply to totalSupply + 1
        vm.startPrank(tronicAdmin);
        tronicMembership.setMaxMintable(totalSupply + 1);

        // mint token to user1
        tronicMembership.mint(user1, 1);

        // try mint token to user2
        vm.expectRevert("Max supply reached");
        tronicMembership.mint(user2, 1);

        vm.stopPrank();
    }

    //test changing maxSupply when not elastic
    function testMaxSupplyWhenInelastic() public {
        //get maxSupply from membershipY
        uint256 maxSupply = brandYMembership.maxSupply();

        //try to increase maxSupply
        vm.startPrank(tronicAdmin);
        vm.expectRevert();
        brandYMembership.setMaxMintable(maxSupply + 1);
    }
}
