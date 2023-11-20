// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITronicBrandLoyalty {
    function initialize(
        address payable _accountImplementation,
        address _registry,
        string memory name_,
        string memory symbol_,
        string memory uri,
        bool _isBound,
        address tronicAdmin
    ) external;

    function mint(address to) external returns (address payable tbaAccount, uint256);

    function getTBAccount(uint256 tokenId) external view returns (address);
}
