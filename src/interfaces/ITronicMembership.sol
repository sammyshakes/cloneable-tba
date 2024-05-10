// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface ITronicMembership {
    /// @dev Struct representing a membership tier.
    /// @param tierId The ID of the tier.
    /// @param duration The duration of the tier in seconds.
    /// @param isOpen Whether the tier is open or closed.
    /// @param tierURI The URI of the tier.
    struct MembershipTier {
        string tierId;
        uint128 duration;
        bool isOpen;
        string tierURI;
    }

    /// @dev Struct representing the membership details of a token.
    /// @param tierIndex The index of the membership tier.
    /// @param timestamp The timestamp of the membership.
    struct MembershipToken {
        uint8 tierIndex;
        uint128 timestamp;
    }

    function initialize(
        uint256 membershipId,
        string memory name_,
        string memory symbol_,
        string memory uri,
        uint256 _maxSupply,
        bool _isElastic,
        uint8 _maxMembershipTiers,
        address tronicAdmin
    ) external;

    function mint(address to, uint8 tierIndex, uint128 startTimestamp)
        external
        returns (uint256 tokenId);
    function createMembershipTier(
        string memory tierId,
        uint128 duration,
        bool isOpen,
        string calldata tierURI
    ) external returns (uint8 tierIndex);
    function createMembershipTiers(MembershipTier[] calldata tiers) external;
    function setMembershipTier(
        uint8 tierIndex,
        string calldata tierId,
        uint128 duration,
        bool isOpen,
        string calldata tierURI
    ) external;
    function getMembershipTierDetails(uint8 tierIndex)
        external
        view
        returns (MembershipTier memory);
    function getMembershipTierId(uint8 tierIndex) external view returns (string memory);
    function setMembershipToken(uint256 tokenId, uint8 tierIndex, uint128 timestamp) external;
    function getMembershipToken(uint256 tokenId) external view returns (MembershipToken memory);
    function getTierIndexByTierId(string memory tierId) external view returns (uint8);
    function membershipId() external view returns (uint256);
    function isValid(uint256 tokenId) external view returns (bool);
}
