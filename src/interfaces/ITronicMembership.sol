// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITronicMembership {
    /// @dev Struct representing a membership tier.
    /// @param tierId The ID of the tier.
    /// @param duration The duration of the tier in seconds.
    /// @param isOpen Whether the tier is open or closed.
    struct MembershipTier {
        string tierId;
        uint128 duration;
        bool isOpen;
    }

    /// @dev Struct representing the membership details of a token.
    /// @param tierIndex The index of the membership tier.
    /// @param timestamp The timestamp of the membership.
    struct TokenMembership {
        uint8 tierIndex;
        uint128 timestamp;
    }

    function initialize(
        address payable _accountImplementation,
        address _registry,
        string memory name_,
        string memory symbol_,
        string memory uri,
        uint8 _maxMembershipTiers,
        uint256 _maxSupply,
        bool _isElastic,
        bool _isBound,
        address tronicAdmin
    ) external;

    function mint(address to) external returns (address payable tbaAccount, uint256);

    function createMembershipTier(string memory tierId, uint128 duration, bool isOpen)
        external
        returns (uint8 tierIndex);
    function createMembershipTiers(
        string[] memory tierIds,
        uint128[] memory durations,
        bool[] memory isOpens
    ) external;
    function setMembershipTier(
        uint8 tierIndex,
        string calldata tierId,
        uint128 duration,
        bool isOpen
    ) external;
    function getMembershipTierDetails(uint8 tierIndex)
        external
        view
        returns (MembershipTier memory);
    function getMembershipTierId(uint8 tierIndex) external view returns (string memory);
    function setTokenMembership(uint256 tokenId, uint8 tierIndex) external;
    function getTokenMembership(uint256 tokenId) external view returns (TokenMembership memory);
    function getTBAccount(uint256 tokenId) external view returns (address);
    function getTierIndexByTierId(string memory tierId) external view returns (uint8);
}
