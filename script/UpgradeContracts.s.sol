// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Imports
import "forge-std/Script.sol";
import "../src/MockV2s/TronicBrandLoyaltyV2.sol";
import "../src/MockV2s/TronicMembershipV2.sol";
import "../src/MockV2s/TronicTokenV2.sol";
import "../src/MockV2s/TronicRewardsV2.sol";
import "../src/TronicBeacon.sol";

contract UpgradeContracts is Script {
    address public brandLoyaltyBeaconAddress = vm.envAddress("TRONIC_BRAND_LOYALTY_BEACON_ADDRESS");
    address public membershipBeaconAddress = vm.envAddress("TRONIC_MEMBERSHIP_BEACON_ADDRESS");
    address public achievementBeaconAddress = vm.envAddress("TRONIC_TOKEN_BEACON_ADDRESS");
    address public rewardsBeaconAddress = vm.envAddress("TRONIC_REWARDS_BEACON_ADDRESS");

    // Set any or all of these flags to true to upgrade the corresponding contract
    bool public upgradeBrandLoyalty = false;
    bool public upgradeMembership = false;
    bool public upgradeAchievement = false;
    bool public upgradeRewards = false;

    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("TRONIC_DEPLOYER_PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementations if needed
        TronicBrandLoyaltyV2 newBrandLoyaltyImpl;
        TronicMembershipV2 newMembershipImpl;
        TronicTokenV2 newAchievementImpl;
        TronicRewardsV2 newRewardsImpl;

        // Update beacons if corresponding flags are set
        if (upgradeBrandLoyalty) {
            newBrandLoyaltyImpl = new TronicBrandLoyaltyV2();
            TronicBeacon brandLoyaltyBeacon = TronicBeacon(brandLoyaltyBeaconAddress);
            brandLoyaltyBeacon.updateImplementation(address(newBrandLoyaltyImpl));
        }
        if (upgradeMembership) {
            newMembershipImpl = new TronicMembershipV2();
            TronicBeacon membershipBeacon = TronicBeacon(membershipBeaconAddress);
            membershipBeacon.updateImplementation(address(newMembershipImpl));
        }
        if (upgradeAchievement) {
            newAchievementImpl = new TronicTokenV2();
            TronicBeacon achievementBeacon = TronicBeacon(achievementBeaconAddress);
            achievementBeacon.updateImplementation(address(newAchievementImpl));
        }
        if (upgradeRewards) {
            newRewardsImpl = new TronicRewardsV2();
            TronicBeacon rewardsBeacon = TronicBeacon(rewardsBeaconAddress);
            rewardsBeacon.updateImplementation(address(newRewardsImpl));
        }

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
