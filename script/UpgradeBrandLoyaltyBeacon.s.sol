// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Imports
import "forge-std/Script.sol";
import "../src/TronicBrandLoyalty.sol";
import "../src/MockV2s/TronicBrandLoyaltyV2.sol";
import "../src/TronicBeacon.sol";

contract UpgradeBrandLoyaltyBeacon is Script {
    address public brandLoyaltyBeaconAddress = vm.envAddress("TRONIC_BRAND_LOYALTY_BEACON_ADDRESS");

    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("TRONIC_DEPLOYER_PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the new implementation contract
        TronicBrandLoyaltyV2 newBrandLoyaltyImpl = new TronicBrandLoyaltyV2();

        // Create an instance of the beacon contract
        TronicBeacon brandLoyaltyBeacon = TronicBeacon(brandLoyaltyBeaconAddress);

        // Upgrade the beacon to use the new implementation
        brandLoyaltyBeacon.updateImplementation(address(newBrandLoyaltyImpl));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
