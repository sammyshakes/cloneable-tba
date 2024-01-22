// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface ITronicBrandLoyalty {
    function initialize(
        address _accountImplementation,
        address _tbaProxyImplementation,
        address _registry,
        string memory name_,
        string memory symbol_,
        string memory uri,
        bool _isBound,
        address tronicAdmin
    ) external;

    function mint(address to) external returns (address payable tbaAccount, uint256);

    function getTBAccount(uint256 tokenId) external view returns (address);

    // function getTronicMembershipIds() external view returns (uint256[] memory);

    function burn(uint256 tokenId) external;

    // function addMembershipId(uint256 membershipId) external;
}
