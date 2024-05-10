// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ITronicBeacon {
    // Getters for each implementation
    function getBrandLoyaltyImplementation() external view returns (address);
    function getMembershipImplementation() external view returns (address);
    function getAchievementImplementation() external view returns (address);
    function getRewardsImplementation() external view returns (address);

    // Setters for each implementation
    function setBrandLoyaltyImplementation(address newImplementation) external;
    function setMembershipImplementation(address newImplementation) external;
    function setAchievementImplementation(address newImplementation) external;
    function setRewardsImplementation(address newImplementation) external;
}
