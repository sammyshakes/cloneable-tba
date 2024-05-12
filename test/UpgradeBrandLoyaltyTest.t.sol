// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TronicTestBase.t.sol";
import "../src/TronicBrandLoyaltyV2.sol"; // Your new contract version

contract UpgradeBrandLoyaltyeTest is TronicTestBase {
    function testBrandLoyaltyUpgrade() public {
        // Deploy the new version of the TronicBrandLoyalty contract
        TronicBrandLoyaltyV2 newBrandLoyalty = new TronicBrandLoyaltyV2();

        // Start by impersonating the owner to upgrade the beacon
        vm.startPrank(tronicOwner);

        // Update the beacon to point to the new implementation
        TronicBeacon(brandLoyaltyBeacon).updateImplementation(address(newBrandLoyalty));

        vm.stopPrank();

        // Use the proxy to interact with the new implementation
        TronicBrandLoyaltyV2 upgradedBrandLoyalty = TronicBrandLoyaltyV2(address(brandLoyaltyX));

        // Verify that the new version is reported correctly
        assertEq(upgradedBrandLoyalty.VERSION(), "v0.2.0");

        // Verify other functionalities or state variables if necessary
        assertEq(upgradedBrandLoyalty.owner(), tronicAdmin); // Assuming ownership should remain

        // Optionally, verify that new functionality works
        bool newFunctionResult = upgradedBrandLoyalty.newFunction();
        assertTrue(newFunctionResult);
    }
}
