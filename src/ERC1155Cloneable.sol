// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title ERC1155Cloneable
/// @notice A contract for managing ERC1155 fungible and non-fungible tokens (NFTs).
/// @dev It includes functionalities to create, mint, and burn tokens.
contract ERC1155Cloneable is ERC1155, Initializable {
    uint256 public constant STARING_NFT_ID = 1000;
    address public owner;
    string public name;
    string public symbol;
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

    /// @notice Initializes the contract with given parameters.
    /// @param _baseURI Base URI for the token metadata.
    /// @param _admin Address of the initial admin.
    /// @param _name Name of the token collection.
    /// @param _symbol Symbol of the token collection.
    function initialize(
        string memory _baseURI,
        address _admin,
        string memory _name,
        string memory _symbol
    ) external initializer {
        _setURI(_baseURI);
        _admins[_admin] = true;
        owner = _admin;
        name = _name;
        symbol = _symbol;
    }

    /// @notice Creates a new fungible token type.
    /// @param _id The ID for the new fungible token type.
    /// @param _uri URI for the token type's metadata.
    /// @dev Requires that the token type does not already exist.
    function createFungibleType(uint256 _id, string memory _uri) external onlyAdmin {
        require((bytes(_fungibleTokenURIs[_id]).length == 0), "Token type already exists");

        // Set URI
        _fungibleTokenURIs[_id] = _uri;
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
    /// @dev Requires that the token type exists.
    function mintFungible(address to, uint256 id, uint256 amount) public onlyAdmin {
        require((bytes(_fungibleTokenURIs[id]).length > 0), "Token type does not exists");
        _mint(to, id, amount, "");
    }

    /// @notice Mints a non-fungible token (NFT) to a specific address.
    /// @param to Address to mint the NFT to.
    /// @param id ID of the NFT.
    /// @dev Requires that the NFT does not already exist.
    function mintNFT(address to, uint256 id) public onlyAdmin {
        require((bytes(_fungibleTokenURIs[id]).length == 0), "Token type already exists");
        _mint(to, id, 1, "");
    }

    /// @notice Mints multiple tokens to a specific address.
    /// @param to Address to mint the tokens to.
    /// @param ids IDs of the tokens to mint.
    /// @param amounts Amounts of each token to mint.
    /// @param data Additional data to include in the minting call.
    /// @dev Requires that the token IDs and amounts arrays have matching lengths.
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyAdmin {
        require(to != address(0), "ERC1155Cloneable: mint to the zero address");

        // Calling the internal _mintBatch function from ERC1155 contract
        _mintBatch(to, ids, amounts, data);
    }

    /// @notice Burns tokens from a specific address.
    /// @param account Address to burn tokens from.
    /// @param id ID of the token type to burn.
    /// @param amount The amount of tokens to burn.
    function burn(address account, uint256 id, uint256 amount) public onlyAdmin {
        _burn(account, id, amount);
    }

    /// @notice Returns the URI for a specific token ID.
    /// @param id The ID of the token.
    /// @return The URI of the token.
    /// @dev Overrides the base implementation to support fungible tokens.
    function uri(uint256 id) public view override returns (string memory) {
        if (bytes(_fungibleTokenURIs[id]).length > 0) {
            return _fungibleTokenURIs[id];
        } else {
            return super.uri(id);
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
