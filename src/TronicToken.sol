// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {ITronicToken} from "./interfaces/ITronicToken.sol";
import {ERC1155, IERC1155, IERC165} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// @title TronicToken
/// @notice This contract represents the fungible and non-fungible tokens (NFTs) for the Tronic ecosystem.
/// @dev This contract is based on the ERC1155 standard.
/// @dev This contract is cloneable.
contract TronicToken is ITronicToken, ERC1155, Initializable {
    using Strings for uint256;

    event FungibleTokenTypeCreated(uint256 indexed typeId, uint64 maxSupply, string uri);
    event NFTokenTypeCreated(uint256 indexed typeId, uint64 maxMintable, string baseURI);

    uint32 private _tokenTypeCounter;
    uint64 public nftTypeStartId;
    uint64 private _nextNFTTypeStartId;
    address public owner;
    string public name;
    string public symbol;
    mapping(uint256 => FungibleTokenInfo) private _fungibleTokens;
    mapping(uint256 => NFTokenInfo) private _nftTypes;
    mapping(uint256 => uint256) public tokenLevels;
    mapping(uint256 => address) public nftOwners;
    mapping(address => uint256[]) public nftIdsForOwner;
    mapping(address => bool) private _admins;

    /// @notice Constructor initializes ERC1155 with an empty URI.
    /// @dev The constructor is used to disbale the initializers.
    constructor() ERC1155("") {
        _disableInitializers();
    }

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

    /// @notice Initializes the contract with tronic Admin address.
    /// @param _tronicAdmin Address of the Tronic admin.
    /// @param _nftTypeStartId The starting ID for non-fungible tokens (NFTs).
    /// @dev This function is called by the TronicMain contract.
    function initialize(address _tronicAdmin, uint64 _nftTypeStartId) external initializer {
        owner = _tronicAdmin;
        _admins[_tronicAdmin] = true;
        //sets TronicAdmin.sol as admin
        _admins[msg.sender] = true;
        nftTypeStartId = _nftTypeStartId;
        _nextNFTTypeStartId = _nftTypeStartId;
    }

    /// @notice Gets the information of a fungible token type.
    /// @param typeId The ID of the token type.
    /// @return The information of the token type.
    function getFungibleTokenInfo(uint256 typeId)
        external
        view
        returns (FungibleTokenInfo memory)
    {
        return _fungibleTokens[typeId];
    }

    /// @notice Gets the information of a non-fungible token (NFT) type.
    /// @param typeId The ID of the token type.
    /// @return The information of the token type.
    function getNFTokenInfo(uint256 typeId) external view returns (NFTokenInfo memory) {
        return _nftTypes[typeId];
    }

    /// @notice Gets the non-fungible token (NFT) IDs for a specific address.
    /// @param _owner The address to get the NFT IDs for.
    /// @return The NFT IDs for the address.
    function getNftIdsForOwner(address _owner) external view returns (uint256[] memory) {
        return nftIdsForOwner[_owner];
    }

    /// @notice Creates a new non-fungible token (NFT) type.
    /// @param baseURI Base URI for the token metadata.
    /// @param maxMintable Max mintable for the NFT type.
    /// @return nftTypeId The ID of the new NFT type.
    /// @dev Only callable by admin.
    /// @dev Requires that the max mintable is greater than 0.
    function createNFTType(string memory baseURI, uint64 maxMintable)
        external
        onlyAdmin
        returns (uint256 nftTypeId)
    {
        nftTypeId = _tokenTypeCounter++;
        require(maxMintable > 0, "Max mintable must be greater than 0");

        _nftTypes[nftTypeId] = NFTokenInfo({
            baseURI: baseURI,
            startingTokenId: _getNextNFTTypeStartId(maxMintable),
            totalMinted: 0,
            maxMintable: maxMintable
        });

        emit NFTokenTypeCreated(nftTypeId, maxMintable, baseURI);
    }

    /// @notice Creates a new fungible token type.
    /// @param _maxSupply Max supply for the fungible token type.
    /// @param _uri URI for the token type's metadata.
    /// @return fungibleTokenId The ID of the new fungible token type.
    /// @dev Only callable by admin.
    /// @dev Requires that the max supply is greater than 0.
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

        emit FungibleTokenTypeCreated(fungibleTokenId, _maxSupply, _uri);
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

        // Update the struct
        _fungibleTokens[id] = token;

        _mint(to, id, amount, "");
    }

    /// @notice Mints a non-fungible token (NFT) to a specific address.
    /// @param typeId Type ID of the NFT.
    /// @param to Address to mint the NFT to.
    /// @dev Requires that the NFT type already exists.
    /// @dev Requires that the amount does not exceed the max mintable for the NFT type.
    function mintNFT(uint256 typeId, address to) external onlyAdmin {
        //get memory instance of NFT type
        NFTokenInfo memory nftType = _nftTypes[typeId];

        require(nftType.maxMintable > 0, "NFT type does not exist");
        // Get the next token ID to mint, and increment the totalMinted count
        uint256 tokenId = nftType.startingTokenId + ++nftType.totalMinted;
        require(
            tokenId <= nftType.startingTokenId + nftType.maxMintable,
            "Exceeds max mintable for this NFT type"
        );

        // Update the owner of the NFT
        nftOwners[tokenId] = to;
        nftIdsForOwner[to].push(tokenId);

        // update the struct with new totalMinted
        _nftTypes[typeId] = nftType;

        _mint(to, tokenId, 1, "");
    }

    /// @notice Mints multiple non-fungible tokens (NFTs) to a specific address.
    /// @param typeId Type ID of the NFT.
    /// @param to Address to mint the NFTs to.
    /// @param amount The amount of NFTs to mint.
    /// @dev Requires that the NFT type already exists.
    /// @dev Requires that the amount does not exceed the max mintable for the NFT type.
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
        NFTokenInfo memory nftType = _nftTypes[typeId];

        require(nftType.maxMintable > 0, "NFT type does not exist");
        require(
            nftType.totalMinted + amount <= nftType.maxMintable,
            "Exceeds max mintable for this NFT type"
        );

        // Build the token ID and amount arrays for batchMint call
        uint256[] memory tokenIds = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);
        uint256 _tokenId = nftType.startingTokenId + nftType.totalMinted + 1;

        for (uint256 i = 0; i < amount; i++) {
            tokenIds[i] = _tokenId;
            amounts[i] = 1; // Each NFT token id has an amount of 1

            nftIdsForOwner[to].push(_tokenId); //update nftIdsForOwner
            nftOwners[_tokenId++] = to; // Update the owner of the NFT
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
                _mintNFTs(typeIds[i], to, amounts[i]);

                // set amount to 0 for NFTs so that it doesn't get minted again
                amounts[i] = 0;
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
    /// @dev For NFT types the amount is always 1.
    /// @dev Requires that the caller is an admin.
    function burn(address account, uint256 id, uint256 amount) public onlyAdmin {
        _burn(account, id, amount);

        //if nonfungible, update mappings
        if (isFungible(id)) {
            _fungibleTokens[id].totalBurned += uint64(amount);
        } else {
            _updateOwnership(account, address(0), id);
        }
    }

    /// @notice Gets the next non-fungible token (NFT) type start ID.
    /// @param maxMintable Max mintable for the NFT type.
    /// @return startId The next NFT type start ID.
    function _getNextNFTTypeStartId(uint64 maxMintable) private returns (uint64 startId) {
        startId = _nextNFTTypeStartId;
        _nextNFTTypeStartId += maxMintable;
    }

    /// @notice Checks if a token ID is fungible.
    /// @param tokenId The ID of the token.
    /// @return True if the token ID is fungible, false otherwise.
    function isFungible(uint256 tokenId) public view returns (bool) {
        return bytes(_fungibleTokens[tokenId].uri).length > 0;
    }

    /// @dev Updates the ownership of a token.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param tokenId The ID of the token.
    function _updateOwnership(address from, address to, uint256 tokenId) internal {
        uint256[] storage fromTokens = nftIdsForOwner[from];
        for (uint256 i = 0; i < fromTokens.length; i++) {
            if (fromTokens[i] == tokenId) {
                fromTokens[i] = fromTokens[fromTokens.length - 1];
                fromTokens.pop();
                break;
            }
        }

        if (to != address(0)) {
            nftIdsForOwner[to].push(tokenId);
        }

        nftOwners[tokenId] = to;
    }

    /// @notice Returns the URI for a specific token ID.
    /// @param tokenId The ID of the token.
    /// @return tokenUri The URI of the token.
    /// @dev Overrides the base implementation to support fungible tokens.
    function uri(uint256 tokenId) public view override returns (string memory tokenUri) {
        // Check if it's a fungible token type
        if (isFungible(tokenId)) {
            tokenUri = _fungibleTokens[tokenId].uri;
            return tokenUri;
        }

        // Check if it's a non-fungible token type
        if (tokenId < nftTypeStartId) {
            tokenUri = "";
            return tokenUri;
        }

        for (uint256 typeId = 0; typeId < _tokenTypeCounter; typeId++) {
            if (
                tokenId >= _nftTypes[typeId].startingTokenId
                    && tokenId < _nftTypes[typeId].startingTokenId + _nftTypes[typeId].maxMintable
            ) {
                // Construct URI
                tokenUri =
                    string(abi.encodePacked(_nftTypes[typeId].baseURI, "/", tokenId.toString()));
                return tokenUri;
            }
        }
    }

    /// @notice Overrides the base implementation to support non-fungible tokens.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param id The ID of the token.
    /// @param amount The amount of tokens to transfer.
    /// @param data Additional data to include in the transfer call.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        super.safeTransferFrom(from, to, id, amount, data);

        //if nonfungible, update mappings
        if (!isFungible(id)) {
            _updateOwnership(from, to, id);
        }
    }

    /// @notice Overrides the base implementation to support non-fungible tokens.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param ids The IDs of the tokens.
    /// @param amounts The amounts of each token to transfer.
    /// @param data Additional data to include in the transfer call.
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            if (!isFungible(ids[i])) {
                _updateOwnership(from, to, ids[i]);
            }
        }
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
