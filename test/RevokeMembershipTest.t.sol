// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract ExpireMembershipTest is TronicTestBase {
    function testExpireValidMembershipToken() public {
        // Assume token ID 1 for user1 is valid before revocation
        vm.startPrank(tronicAdmin);
        tronicMainContract.expireMembership(membershipIDX, 1);
        vm.stopPrank();

        // Try to get the membership token's details to verify revocation
        TronicMembership.MembershipToken memory tokenDetails =
            brandXMembership.getMembershipToken(1);

        // Verify the token has been expired, timestamp should be 0
        assertEq(tokenDetails.timestamp, 0, "Token should be expired");
    }

    function testExpireMembershipTokenUnauthorized() public {
        // Attempt to expire as an unauthorized user
        vm.startPrank(unauthorizedUser);
        vm.expectRevert("Only admin");
        tronicMainContract.expireMembership(membershipIDX, 1);
        vm.stopPrank();
    }

    function testExpireNonExistentMembershipToken() public {
        vm.startPrank(tronicAdmin);
        // non-existent membership ID is 9999
        vm.expectRevert("Membership does not exist");
        tronicMainContract.expireMembership(9999, 1);

        vm.stopPrank();
    }

    function testExpireAndReissueMembership() public {
        // First, expire an existing membership
        vm.startPrank(tronicAdmin);
        tronicMainContract.expireMembership(membershipIDX, 1);

        // Now, try to renew membership for the same user
        tronicMainContract.renewMembership(
            membershipIDX, 1, TronicTier1Index, uint128(block.timestamp)
        );
        vm.stopPrank();

        // Verify the new token has valid membership details
        TronicMembership.MembershipToken memory newTokenDetails =
            brandXMembership.getMembershipToken(1);
        assertTrue(newTokenDetails.timestamp > 0, "New token should have valid timestamp");
    }
}
