// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// @title ERC1155Cloneable
/// @notice A contract for managing ERC1155 fungible and non-fungible tokens (NFTs).
/// @dev It includes functionalities to create, mint, and burn tokens.
contract ERC1155Cloneable is ERC1155, Initializable {
    using Strings for uint256;

    struct FungibleTokenInfo {
        uint64 maxSupply;
        uint64 totalMinted;
        uint64 totalBurned;
        string uri;
    }

    struct NFTTokenInfo {
        uint64 startingTokenId;
        uint64 totalMinted;
        uint64 maxMintable;
        string baseURI;
    }

    uint32 private _tokenTypeCounter;
    uint64 private _nextNFTTypeMinStartId = 100_000;
    address public owner;
    string public name;
    string public symbol;
    mapping(uint256 => FungibleTokenInfo) private _fungibleTokens;
    mapping(uint256 => NFTTokenInfo) private _nftTypes;
    mapping(uint256 => uint256) public tokenLevels;
    mapping(uint256 => address) public nftOwners;
    mapping(address => bool) private _admins;

    // Token ID => URI mapping for fungible tokens
    mapping(uint256 => string) private _fungibleTokenURIs;

    /// @notice Constructor initializes ERC1155 with an empty URI.
    constructor() ERC1155("") {}

    /// @dev Modifier to ensure only the owner can call certain functions.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @dev Modifier to ensure only an admin can call certain functions.
    modifier onlyAdmin() {
        require(_admins[msg.sender], "Only Admin");
        _;
    }

    /// @notice Initializes the contract with given parameters.
    /// @param _baseURI Base URI for the token metadata.
    /// @param _tronicAdmin Address of the Tronic admin.
    /// @param _name Name of the token collection.
    /// @param _symbol Symbol of the token collection.
    function initialize(
        string memory _baseURI,
        address _tronicAdmin,
        string memory _name,
        string memory _symbol
    ) external initializer {
        owner = _tronicAdmin;
        _admins[_tronicAdmin] = true;
        _admins[msg.sender] = true;
        name = _name;
        symbol = _symbol;

        _setURI(_baseURI);
    }

    /// @notice Gets the information of a fungible token type.
    /// @param id The ID of the token type.
    /// @return The information of the token type.
    function getFungibleTokenInfo(uint256 id) external view returns (FungibleTokenInfo memory) {
        return _fungibleTokens[id];
    }

    /// @notice Gets the information of a non-fungible token (NFT) type.
    /// @param id The ID of the token type.
    /// @return The information of the token type.
    function getNFTTokenInfo(uint256 id) external view returns (NFTTokenInfo memory) {
        return _nftTypes[id];
    }

    /// @notice Creates a new non-fungible token (NFT) type.
    /// @param baseURI Base URI for the token metadata.
    /// @param maxMintable Max mintable for the NFT type.
    /// @return nftTypeId The ID of the new NFT type.
    /// @dev Only callable by admin.
    function createNFTType(string memory baseURI, uint64 maxMintable)
        external
        onlyAdmin
        returns (uint256 nftTypeId)
    {
        uint256 startingTokenId = _nextNFTTypeMinStartId;
        require(_nftTypes[startingTokenId].maxMintable == 0, "Token type already exists");
        require(maxMintable > 0, "Max mintable must be greater than 0");

        nftTypeId = _tokenTypeCounter++;

        _nftTypes[nftTypeId] = NFTTokenInfo({
            baseURI: baseURI,
            startingTokenId: _nextNFTTypeMinStartId += maxMintable,
            totalMinted: 0,
            maxMintable: maxMintable
        });
    }

    /// @notice Creates a new fungible token type.
    /// @param _maxSupply Max supply for the fungible token type.
    /// @param _uri URI for the token type's metadata.
    /// @return fungibleTokenId The ID of the new fungible token type.
    /// @dev Only callable by admin.
    function createFungibleType(uint64 _maxSupply, string memory _uri)
        external
        onlyAdmin
        returns (uint256 fungibleTokenId)
    {
        require(_maxSupply > 0, "Max supply must be greater than 0");
        // Increment the fungible token ID counter and set fungibleTokenId.
        fungibleTokenId = _tokenTypeCounter++;
        // Set Fungible Tokens struct for the new token ID.
        _fungibleTokens[fungibleTokenId] =
            FungibleTokenInfo({uri: _uri, maxSupply: _maxSupply, totalMinted: 0, totalBurned: 0});
    }

    /// @notice Updates the URI of a fungible token type.
    /// @param id The ID of the token type to update.
    /// @param uri_ The new URI for the token type.
    /// @dev Requires that the token type exists.
    function setFungibleURI(uint256 id, string memory uri_) external onlyAdmin {
        require((bytes(_fungibleTokenURIs[id]).length > 0), "Token type does not exists");
        _fungibleTokenURIs[id] = uri_;
    }

    /// @notice Mints fungible tokens to a specific address.
    /// @param to Address to mint the tokens to.
    /// @param id ID of the fungible token type.
    /// @param amount The amount of tokens to mint.
    /// @dev Requires that the token type exists and minting amount does not exceed max supply.
    function mintFungible(address to, uint256 id, uint64 amount) external onlyAdmin {
        FungibleTokenInfo memory token = _fungibleTokens[id];
        require(bytes(token.uri).length > 0, "Token type does not exist");

        // Increase the totalMinted count
        token.totalMinted += amount;
        require(token.totalMinted <= token.maxSupply, "Exceeds max supply");

        //update the struct
        _fungibleTokens[id] = token;

        _mint(to, id, amount, "");
    }

    /// @notice Mints a non-fungible token (NFT) to a specific address.
    /// @param to Address to mint the NFT to.
    /// @param typeId Type ID of the NFT.
    /// @dev Requires that the NFT type already exists.
    function mintNFT(uint256 typeId, address to) external onlyAdmin {
        //get memory instance of NFT type
        NFTTokenInfo memory nftType = _nftTypes[typeId];

        require(bytes(nftType.baseURI).length > 0, "NFT type does not exist");
        // Get the next token ID to mint, and increment the totalMinted count
        uint256 tokenId = nftType.startingTokenId + nftType.totalMinted++;
        require(
            tokenId < nftType.startingTokenId + nftType.maxMintable,
            "Exceeds max mintable for this NFT type"
        );

        nftOwners[tokenId] = to; // Update the owner of the NFT

        // update the struct with new totalMinted
        _nftTypes[typeId] = nftType;

        _mint(to, tokenId, 1, "");
    }

    /// @notice Mints multiple non-fungible tokens (NFTs) to a specific address.
    /// @param typeId Type ID of the NFT.
    /// @param to Address to mint the NFTs to.
    /// @param amount The amount of NFTs to mint.
    /// @dev only callable by admin
    function mintNFTs(uint256 typeId, address to, uint256 amount) external onlyAdmin {
        _mintNFTs(typeId, to, amount);
    }

    /// @notice Mints multiple non-fungible tokens (NFTs) to a specific address.
    /// @param typeId Type ID of the NFT.
    /// @param to Address to mint the NFTs to.
    /// @param amount The amount of NFTs to mint.
    /// @dev Requires that the NFT type already exists.
    /// @dev Requires that the amount does not exceed the max mintable for the NFT type.
    function _mintNFTs(uint256 typeId, address to, uint256 amount) internal {
        //get memory instance of NFT type
        NFTTokenInfo memory nftType = _nftTypes[typeId];

        require(bytes(nftType.baseURI).length > 0, "NFT type does not exist");
        require(
            nftType.totalMinted + amount <= nftType.maxMintable,
            "Exceeds max mintable for this NFT type"
        );

        uint256[] memory tokenIds = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);
        uint256 _tokenId = nftType.startingTokenId + nftType.totalMinted;

        for (uint256 i = 0; i < amount; i++) {
            // Get the next token ID to mint, and increment the totalMinted count

            tokenIds[i] = _tokenId++;
            amounts[i] = 1; // Each NFT token id has an amount of 1

            nftOwners[_tokenId] = to; // Update the owner of the NFT
        }

        // update the struct with new totalMinted
        _nftTypes[typeId].totalMinted += uint64(amount);

        _mintBatch(to, tokenIds, amounts, "");
    }

    /// @notice Sets the level of a specific token ID.
    /// @param tokenId The ID of the token.
    /// @param level The level to set.
    /// @dev Only callable by admin.
    function setLevel(uint256 tokenId, uint256 level) external onlyAdmin {
        tokenLevels[tokenId] = level;
    }

    /// @notice Gets the level of a specific token ID.
    /// @param tokenId The ID of the token.
    /// @return The level of the token.
    function getLevel(uint256 tokenId) external view returns (uint256) {
        return tokenLevels[tokenId];
    }

    /// @notice Mints multiple tokens to a specific address.
    /// @param to Address to mint the tokens to.
    /// @param typeIds Type IDs of the tokens to mint.
    /// @param amounts Amounts of each token to mint.
    /// @param data Additional data to include in the minting call.
    /// @dev Requires that the token type IDs and amounts arrays have matching lengths.
    function mintBatch(
        address to,
        uint256[] memory typeIds,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyAdmin {
        require(to != address(0), "ERC1155Cloneable: mint to the zero address");
        require(typeIds.length == amounts.length, "Mismatch between typeIds and amounts length");

        uint256[] memory idsToMint = new uint256[](typeIds.length);

        for (uint256 i = 0; i < typeIds.length; i++) {
            // Check if it's a fungible token type
            if (_fungibleTokens[typeIds[i]].maxSupply > 0) {
                require(
                    _fungibleTokens[typeIds[i]].totalMinted + amounts[i]
                        <= _fungibleTokens[typeIds[i]].maxSupply,
                    "Exceeds max supply for some IDs"
                );

                // Increase the totalMinted count for fungible tokens
                _fungibleTokens[typeIds[i]].totalMinted += uint64(amounts[i]);

                idsToMint[i] = typeIds[i];
            } else if (_nftTypes[typeIds[i]].maxMintable > 0) {
                //get memory instance of NFT type
                NFTTokenInfo memory nftType = _nftTypes[typeIds[i]];

                // Check if it's a non-fungible token type
                require(
                    nftType.totalMinted < nftType.maxMintable,
                    "Exceeds max mintable for this NFT type"
                );

                idsToMint[i] = nftType.startingTokenId + nftType.totalMinted++;

                // set amount to 1 for NFTs
                amounts[i] = 1;

                // Update the struct with new totalMinted
                _nftTypes[typeIds[i]] = nftType;

                // Update the owner of the NFT
                nftOwners[idsToMint[i]] = to;
            } else {
                revert("Token type does not exist for some IDs");
            }
        }

        _mintBatch(to, idsToMint, amounts, data);
    }

    /// @notice Burns tokens from a specific address.
    /// @param account Address to burn tokens from.
    /// @param id ID of the token type to burn.
    /// @param amount The amount of tokens to burn.
    function burn(address account, uint256 id, uint256 amount) public onlyAdmin {
        _burn(account, id, amount);
    }

    /// @notice Gets the next token ID for a specific token type.
    /// @param typeId The ID of the token type.
    /// @return The next token ID for the token type.
    function getNextTokenIdForType(uint256 typeId) external view returns (uint256) {
        return _nftTypes[typeId].startingTokenId + _nftTypes[typeId].totalMinted;
    }

    /// @notice Returns the URI for a specific token ID.
    /// @param tokenId The ID of the token.
    /// @return The URI of the token.
    /// @dev Overrides the base implementation to support fungible tokens.
    function uri(uint256 tokenId) public view override returns (string memory) {
        // Check if it's a fungible token type
        if (bytes(_fungibleTokenURIs[tokenId]).length > 0) {
            return _fungibleTokenURIs[tokenId];
        }

        // Check if it's a non-fungible token type
        for (uint256 typeId = 0; typeId < _tokenTypeCounter; typeId++) {
            if (
                tokenId >= _nftTypes[typeId].startingTokenId
                    && tokenId < _nftTypes[typeId].startingTokenId + _nftTypes[typeId].maxMintable
            ) {
                // Construct URI
                return string(abi.encodePacked(_nftTypes[typeId].baseURI, "/", tokenId.toString()));
            }
        }

        // If not found in both, revert to the parent implementation
        return super.uri(tokenId);
    }

    /// @notice Adds an admin to the contract.
    /// @param admin The address of the new admin.
    function addAdmin(address admin) external onlyOwner {
        _admins[admin] = true;
    }

    /// @notice Removes an admin from the contract.
    /// @param admin The address of the admin to remove.
    function removeAdmin(address admin) external onlyOwner {
        _admins[admin] = false;
    }

    /// @notice Checks if an address is an admin of the contract.
    /// @param admin The address to check.
    /// @return True if the address is an admin, false otherwise.
    function isAdmin(address admin) external view returns (bool) {
        return _admins[admin];
    }

    /// @notice Checks if the contract supports a specific interface.
    /// @param interfaceId The interface ID to check for.
    /// @return True if the interface is supported, false otherwise.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155).interfaceId || super.supportsInterface(interfaceId);
    }
}
