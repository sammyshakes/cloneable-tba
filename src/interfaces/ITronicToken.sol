// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ITronicToken {
    struct FungibleTokenInfo {
        uint64 maxSupply;
        uint64 totalMinted;
        uint64 totalBurned;
        string uri;
    }

    struct NFTokenInfo {
        uint64 startingTokenId;
        uint64 totalMinted;
        uint64 maxMintable;
        string baseURI;
    }

    function initialize(address _tronicAdmin) external;
    function getFungibleTokenInfo(uint256 typeId)
        external
        view
        returns (FungibleTokenInfo memory);
    function getNFTokenInfo(uint256 typeId) external view returns (NFTokenInfo memory);
    function getNftIdsForOwner(address _owner) external view returns (uint256[] memory);
    function createNFTType(string memory baseURI, uint64 maxMintable)
        external
        returns (uint256 nftTypeId);
    function createFungibleType(uint64 maxSupply, string memory uri)
        external
        returns (uint256 fungibleTokenId);
    function mintFungible(address to, uint256 id, uint64 amount) external;
    function mintNFT(uint256 typeId, address to) external;
    function mintNFTs(uint256 typeId, address to, uint256 amount) external;
    function setLevel(uint256 tokenId, uint256 level) external;
    function getLevel(uint256 tokenId) external view returns (uint256);
    function mintBatch(
        address to,
        uint256[] memory typeIds,
        uint256[] memory amounts,
        bytes memory data
    ) external;
}
