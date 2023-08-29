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
        string baseURI;
        uint256 startingTokenId;
        uint256 nextIdToMint;
        uint256 maxMintable;
    }

    address public owner;
    address public tronicAdmin;
    uint256 private _nextNFTMTypeMinStartId = 10_000;
    uint256 private _nftTypeCounter = 1000; //start at 1000 to avoid with fungible token ids
    uint256 private _nextFungibleId;
    string public name;
    string public symbol;
    mapping(uint256 => FungibleTokenInfo) private _fungibleTokens;
    mapping(uint256 => NFTTokenInfo) private _nftTypes;
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
        require(_admins[msg.sender], "Only admin");
        _;
    }

    /// @dev Modifier to ensure only the Tronic admin can call certain functions.
    modifier onlyTronicAdmin() {
        require(msg.sender == tronicAdmin, "Only Tronic Admin");
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
        // TODO: add tronic admin contract address to admin
        _setURI(_baseURI);
        tronicAdmin = _tronicAdmin;
        owner = _tronicAdmin;
        name = _name;
        symbol = _symbol;
    }

    function getFungibleTokenInfo(uint256 id) external view returns (FungibleTokenInfo memory) {
        return _fungibleTokens[id];
    }

    function getNFTTokenInfo(uint256 id) external view returns (NFTTokenInfo memory) {
        return _nftTypes[id];
    }

    /// @notice Creates a new non-fungible token (NFT) type.
    /// @param baseURI Base URI for the token metadata.
    /// @param maxMintable Max mintable for the NFT type.
    /// @param startingTokenId The starting token ID for the NFT type.
    /// @dev Only callable by admin.
    function createNFTType(string memory baseURI, uint256 maxMintable, uint256 startingTokenId)
        external
        onlyTronicAdmin
        returns (uint256 nftTypeId)
    {
        require(_nftTypes[startingTokenId].maxMintable == 0, "Token type already exists");
        require(maxMintable > 0, "Max mintable must be greater than 0");
        require(
            startingTokenId >= _nextNFTMTypeMinStartId,
            "Starting token ID must be greater than 10,000"
        );

        nftTypeId = _nftTypeCounter++;

        _nftTypes[nftTypeId] = NFTTokenInfo({
            baseURI: baseURI,
            startingTokenId: startingTokenId,
            nextIdToMint: startingTokenId,
            maxMintable: maxMintable
        });

        //update nextNFTMTypeMinStartId
        _nextNFTMTypeMinStartId += maxMintable;
    }

    /// @notice Creates a new fungible token type.
    /// @param _maxSupply Max supply for the fungible token type.
    /// @param _uri URI for the token type's metadata.
    /// @dev Only callable by admin.
    function createFungibleType(uint64 _maxSupply, string memory _uri)
        external
        onlyTronicAdmin
        returns (uint256 fungibleTokenId)
    {
        require(_maxSupply > 0, "Max supply must be greater than 0");
        // Increment the fungible token ID counter and set fungibleTokenId.
        fungibleTokenId = ++_nextFungibleId;
        // Set Fungible Tokens struct for the new token ID.
        _fungibleTokens[fungibleTokenId] =
            FungibleTokenInfo({uri: _uri, maxSupply: _maxSupply, totalMinted: 0, totalBurned: 0});
    }

    /// @notice Updates the URI of a fungible token type.
    /// @param id The ID of the token type to update.
    /// @param uri_ The new URI for the token type.
    /// @dev Requires that the token type exists.
    function setFungibleURI(uint256 id, string memory uri_) external onlyTronicAdmin {
        require((bytes(_fungibleTokenURIs[id]).length > 0), "Token type does not exists");
        _fungibleTokenURIs[id] = uri_;
    }

    /// @notice Mints fungible tokens to a specific address.
    /// @param to Address to mint the tokens to.
    /// @param id ID of the fungible token type.
    /// @param amount The amount of tokens to mint.
    /// @dev Requires that the token type exists and minting amount does not exceed max supply.
    function mintFungible(address to, uint256 id, uint64 amount) public onlyTronicAdmin {
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
    function mintNFT(uint256 typeId, address to) external onlyTronicAdmin {
        require(bytes(_nftTypes[typeId].baseURI).length > 0, "NFT type does not exist");
        require(
            _nftTypes[typeId].nextIdToMint
                < _nftTypes[typeId].startingTokenId + _nftTypes[typeId].maxMintable,
            "Exceeds max mintable for this NFT type"
        );

        _mint(to, _nftTypes[typeId].nextIdToMint, 1, "");

        // Update the next ID to be minted for this NFT type
        _nftTypes[typeId].nextIdToMint++;
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
    ) external onlyTronicAdmin {
        require(to != address(0), "ERC1155Cloneable: mint to the zero address");
        require(typeIds.length == amounts.length, "Mismatch between typeIds and amounts length");

        uint256[] memory idsToMint = new uint256[](typeIds.length);

        for (uint256 i = 0; i < typeIds.length; i++) {
            // Check if it's a fungible token type
            if (bytes(_fungibleTokens[typeIds[i]].uri).length > 0) {
                require(
                    _fungibleTokens[typeIds[i]].totalMinted + amounts[i]
                        <= _fungibleTokens[typeIds[i]].maxSupply,
                    "Exceeds max supply for some IDs"
                );

                // Increase the totalMinted count for fungible tokens
                _fungibleTokens[typeIds[i]].totalMinted += uint64(amounts[i]);

                idsToMint[i] = typeIds[i];
            } else if (bytes(_nftTypes[typeIds[i]].baseURI).length > 0) {
                // Check if it's a non-fungible token type
                require(
                    _nftTypes[typeIds[i]].nextIdToMint + amounts[i]
                        <= _nftTypes[typeIds[i]].startingTokenId + _nftTypes[typeIds[i]].maxMintable,
                    "Exceeds max mintable for this NFT type"
                );

                idsToMint[i] = _nftTypes[typeIds[i]].nextIdToMint;

                // Increase the nextIdToMint for non-fungible tokens
                _nftTypes[typeIds[i]].nextIdToMint += amounts[i];
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
    function burn(address account, uint256 id, uint256 amount) public onlyTronicAdmin {
        _burn(account, id, amount);
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
        for (uint256 typeId = 0; typeId < _nftTypeCounter; typeId++) {
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
