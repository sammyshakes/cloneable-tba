// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract UpdateMembershipTest is TronicTestBase {
    function testUpdateMembershipToken() public {
        // First, set up the membership token details
        uint256 tokenId = 1;
        uint8 tierIndex = 1;
        uint128 timestamp = uint128(block.timestamp); // Assuming current timestamp for testing

        // Call the updateMembershipToken function
        vm.startPrank(tronicAdmin);
        tronicMainContract.updateMembershipToken(membershipIDX, tokenId, tierIndex, timestamp);
        vm.stopPrank();

        // Retrieve the updated membership token details
        TronicMembership.MembershipToken memory updatedTokenDetails =
            brandXMembership.getMembershipToken(tokenId);

        // Verify that the membership token details have been updated correctly
        assertEq(updatedTokenDetails.tierIndex, tierIndex, "Tier index should be updated");
        assertEq(updatedTokenDetails.timestamp, timestamp, "Timestamp should be updated");
    }

    function testUpdateMembershipTokenUnauthorized() public {
        // Attempt to update as an unauthorized user
        uint256 tokenId = 1;
        uint8 tierIndex = 1;
        uint128 timestamp = uint128(block.timestamp); // Assuming current timestamp for testing

        vm.startPrank(unauthorizedUser);
        vm.expectRevert("Only admin");
        tronicMainContract.updateMembershipToken(membershipIDX, tokenId, tierIndex, timestamp);
        vm.stopPrank();
    }

    function testUpdateNonExistentMembershipToken() public {
        // Attempt to update a non-existent membership token
        uint256 tokenId = 9999; // non-existent token ID
        uint8 tierIndex = 1;
        uint128 timestamp = uint128(block.timestamp); // Assuming current timestamp for testing

        vm.startPrank(tronicAdmin);
        vm.expectRevert("Token does not exist");
        tronicMainContract.updateMembershipToken(membershipIDX, tokenId, tierIndex, timestamp);
        vm.stopPrank();
    }

    function testExpireMembershipToken() public {
        // First, set up the membership token details
        uint256 tokenId = 1;
        uint8 tierIndex = 1;
        uint128 timestamp = uint128(block.timestamp); // Assuming current timestamp for testing

        // Call the updateMembershipToken function to set up the initial membership token
        vm.startPrank(tronicAdmin);
        tronicMainContract.updateMembershipToken(membershipIDX, tokenId, tierIndex, timestamp);
        vm.stopPrank();

        // Now, expire the membership token
        vm.startPrank(tronicAdmin);
        tronicMainContract.updateMembershipToken(membershipIDX, tokenId, tierIndex, 0);
        vm.stopPrank();

        // Retrieve the updated membership token details
        TronicMembership.MembershipToken memory updatedTokenDetails =
            brandXMembership.getMembershipToken(tokenId);

        // Verify that the membership token has been expired
        assertEq(updatedTokenDetails.timestamp, 0, "Token should be expired");
    }

    function testRenewMembershipToken() public {
        // First, set up the membership token details
        uint256 tokenId = 1;
        uint8 tierIndex = 1;
        uint128 initialTimestamp = uint128(block.timestamp); // Assuming current timestamp for testing

        // Call the updateMembershipToken function to set up the initial membership token
        vm.startPrank(tronicAdmin);
        tronicMainContract.updateMembershipToken(
            membershipIDX, tokenId, tierIndex, initialTimestamp
        );
        vm.stopPrank();

        // Now, renew the membership token
        uint128 duration = 3600; // Assuming membership duration of 1 hour
        uint128 renewedTimestamp = initialTimestamp + duration;

        vm.startPrank(tronicAdmin);
        tronicMainContract.updateMembershipToken(
            membershipIDX, tokenId, tierIndex, renewedTimestamp
        );
        vm.stopPrank();

        // Retrieve the updated membership token details
        TronicMembership.MembershipToken memory updatedTokenDetails =
            brandXMembership.getMembershipToken(tokenId);

        // Verify that the membership token has been renewed with the correct timestamp
        assertEq(updatedTokenDetails.timestamp, renewedTimestamp, "Token should be renewed");
    }

    function testUpgradeMembershipToken() public {
        // First, set up the membership token details with an initial tier
        uint256 tokenId = 1;
        uint8 initialTierIndex = 1;
        uint128 timestamp = uint128(block.timestamp); // Assuming current timestamp for testing

        // Call the updateMembershipToken function to set up the initial membership token
        vm.startPrank(tronicAdmin);
        tronicMainContract.updateMembershipToken(
            membershipIDX, tokenId, initialTierIndex, timestamp
        );
        vm.stopPrank();

        // Now, upgrade the membership token to a new tier
        uint8 newTierIndex = 2;

        vm.startPrank(tronicAdmin);
        tronicMainContract.updateMembershipToken(membershipIDX, tokenId, newTierIndex, timestamp);
        vm.stopPrank();

        // Retrieve the updated membership token details
        TronicMembership.MembershipToken memory updatedTokenDetails =
            brandXMembership.getMembershipToken(tokenId);

        // Verify that the membership token has been upgraded to the new tier
        assertEq(updatedTokenDetails.tierIndex, newTierIndex, "Token tier should be upgraded");
        assertEq(
            updatedTokenDetails.timestamp, timestamp, "Token timestamp should remain unchanged"
        );
    }
}
