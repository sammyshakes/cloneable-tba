// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract MembershipTest is TronicTestBase {
    function testMemberships() public {
        bool isBound = false;
        // deploy membership with isBound set to false
        vm.prank(tronicAdmin);
        (, address membershipZ,) = tronicMainContract.deployMembership(
            "membershipZ", "MEMZ", "http://example.com/token/", 10_000, false, isBound
        );

        //instance of membershipZERC721
        TronicMembership membershipZERC721 = TronicMembership(membershipZ);

        // mint token to user1
        vm.prank(tronicAdmin);
        membershipZERC721.mint(user1);

        // get token membership tier
        membershipZERC721.getTokenMembership(1);

        // create membership tier for membershipZ
        vm.prank(tronicAdmin);
        membershipZERC721.createMembershipTier("tier1", 100, true);

        //get membership tier
        membershipZERC721.getMembershipTierDetails(1);

        // set membership tier for token
        vm.prank(tronicAdmin);
        membershipZERC721.setTokenMembership(1, 1);

        // get token membership tier
        membershipZERC721.getTokenMembership(1);

        // check if token membership is valid
        assertEq(membershipZERC721.isValid(1), true);

        // expire token membership
        vm.warp(block.timestamp + 101);

        // ensure token membership is expired
        assertEq(membershipZERC721.isValid(1), false);
    }
}
