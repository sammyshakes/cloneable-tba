// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TronicTestBase.t.sol";
import "../src/MockV2s/TronicBrandLoyaltyV2.sol";

contract UpgradeBrandLoyaltyTest is TronicTestBase {
    function testBrandLoyaltyUpgrade() public {
        // Deploy the new version of the TronicBrandLoyalty contract
        TronicBrandLoyaltyV2 newBrandLoyalty = new TronicBrandLoyaltyV2();

        // Start by impersonating the owner to upgrade the beacon
        vm.startPrank(tronicOwner);

        // Update the beacon to point to the new implementation
        TronicBeacon(brandLoyaltyBeacon).updateImplementation(address(newBrandLoyalty));

        vm.stopPrank();

        // Use the proxy to interact with the new implementation for each brand
        TronicBrandLoyaltyV2 upgradedBrandLoyaltyX = TronicBrandLoyaltyV2(address(brandLoyaltyX));
        TronicBrandLoyaltyV2 upgradedBrandLoyaltyY = TronicBrandLoyaltyV2(address(brandLoyaltyY));

        // Verify that the new version is reported correctly for each brand
        assertEq(upgradedBrandLoyaltyX.VERSION(), "v0.2.0");
        assertEq(upgradedBrandLoyaltyY.VERSION(), "v0.2.0");

        // Verify other functionalities or state variables if necessary for each brand
        assertEq(upgradedBrandLoyaltyX.owner(), tronicAdmin); // Assuming ownership should remain
        assertEq(upgradedBrandLoyaltyY.owner(), tronicAdmin); // Assuming ownership should remain

        // Optionally, verify that new functionality works for each brand
        bool newFunctionResultX = upgradedBrandLoyaltyX.newFunction();
        assertTrue(newFunctionResultX);

        bool newFunctionResultY = upgradedBrandLoyaltyY.newFunction();
        assertTrue(newFunctionResultY);

        // Verify that the previously deployed brands and memberships are still functional
        assertEq(brandLoyaltyX.ownerOf(1), user1);
        assertEq(brandLoyaltyX.ownerOf(2), user2);
        assertEq(brandLoyaltyY.ownerOf(1), user3);
        assertEq(brandLoyaltyY.ownerOf(2), user4);
    }
}
