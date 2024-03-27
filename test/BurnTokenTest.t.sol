// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract BurnTokenTest is TronicTestBase {
    // Test burning a fungible token
    function testBurnFungibleToken() public {
        // Setup: Mint fungible tokens to user1
        vm.startPrank(tronicAdmin);
        uint64 amountToMint = 100;
        tronicMainContract.mintFungibleToken(brandIDX, user1, fungibleTypeIdX1, amountToMint, false);
        vm.stopPrank();

        // Ensure the balance is correct before burning
        uint256 balanceBeforeBurn = brandXToken.balanceOf(user1, fungibleTypeIdX1);
        assertEq(balanceBeforeBurn, amountToMint, "Balance before burn is incorrect");

        // Burn tokens
        uint64 amountToBurn = 50;
        vm.startPrank(tronicAdmin);
        tronicMainContract.burnToken(brandIDX, user1, fungibleTypeIdX1, amountToBurn, false);
        vm.stopPrank();

        // Check the balance after burning
        uint256 balanceAfterBurn = brandXToken.balanceOf(user1, fungibleTypeIdX1);
        assertEq(balanceAfterBurn, amountToMint - amountToBurn, "Balance after burn is incorrect");
    }

    // Test unauthorized call to burnToken
    function testBurnTokenUnauthorized() public {
        vm.startPrank(unauthorizedUser);
        vm.expectRevert("Only admin");
        tronicMainContract.burnToken(brandIDX, user1, fungibleTypeIdX1, 10, false);
        vm.stopPrank();
    }

    // Test burning more tokens than owned
    function testBurnMoreThanOwned() public {
        // Attempt to burn more tokens than owned by user1
        vm.startPrank(tronicAdmin);
        uint64 amountToBurn = 1000; // Assume user1 has less than this amount
        vm.expectRevert();
        tronicMainContract.burnToken(brandIDX, user1, fungibleTypeIdX1, amountToBurn, false);
        vm.stopPrank();
    }

    // Test burning non-existent token type
    function testBurnNonExistentToken() public {
        vm.startPrank(tronicAdmin);
        uint256 nonExistentTokenId = 9999; // Assume this token ID does not exist
        vm.expectRevert();
        tronicMainContract.burnToken(brandIDX, user1, nonExistentTokenId, 10, false);
        vm.stopPrank();
    }
}
