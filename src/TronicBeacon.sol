// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TronicBeacon {
    address private _owner;

    address private _brandLoyaltyImplementation;
    address private _membershipImplementation;
    address private _achievementImplementation;
    address private _rewardsImplementation;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function.");
        _;
    }

    // Setters for each implementation address
    function setBrandLoyaltyImplementation(address _impl) external onlyOwner {
        _brandLoyaltyImplementation = _impl;
    }

    function setMembershipImplementation(address _impl) external onlyOwner {
        _membershipImplementation = _impl;
    }

    function setAchievementImplementation(address _impl) external onlyOwner {
        _achievementImplementation = _impl;
    }

    function setRewardsImplementation(address _impl) external onlyOwner {
        _rewardsImplementation = _impl;
    }

    // Getters for each implementation address
    function getBrandLoyaltyImplementation() external view returns (address) {
        return _brandLoyaltyImplementation;
    }

    function getMembershipImplementation() external view returns (address) {
        return _membershipImplementation;
    }

    function getAchievementImplementation() external view returns (address) {
        return _achievementImplementation;
    }

    function getRewardsImplementation() external view returns (address) {
        return _rewardsImplementation;
    }

    // Function to transfer ownership of the beacon to a new owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address.");
        _owner = newOwner;
    }
}
