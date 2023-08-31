// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./interfaces/IERC6551Registry.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title ERC721CloneableTBA
/// @notice A contract for managing ERC721 tokens with additional functionalities such as admin control.
contract ERC721CloneableTBA is ERC721Enumerable, Initializable {
    IERC6551Registry public registry;
    address public accountImplementation;
    address public owner;

    mapping(uint256 => uint256) private membershipTier;
    mapping(address => bool) private _admins;
    string private _baseURI_;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    /// @notice Constructor initializes the ERC721 with empty name and symbol.
    constructor() ERC721("", "") {}

    /// @dev Modifier to ensure only the owner can call certain functions.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /// @notice Initializes the contract with given parameters.
    /// @param _accountImplementation Implementation of the account.
    /// @param _registry Address of the registry contract.
    /// @param name_ Name of the token.
    /// @param symbol_ Symbol of the token.
    /// @param uri Base URI of the token.
    /// @param admin Address of the initial admin.
    function initialize(
        address payable _accountImplementation,
        address _registry,
        string memory name_,
        string memory symbol_,
        string memory uri,
        address admin
    ) external initializer {
        accountImplementation = _accountImplementation;
        registry = IERC6551Registry(_registry);
        _baseURI_ = uri;
        _admins[admin] = true;
        owner = admin;
        _name = name_;
        _symbol = symbol_;
    }

    /// @notice Mints a new token.
    /// @param to Address to mint the token to.
    /// @param tokenId ID of the token to mint.
    /// @return tbaAccount The payable address of the created tokenbound account.
    function mint(address to, uint256 tokenId)
        public
        onlyAdmin
        returns (address payable tbaAccount)
    {
        // Deploy token account
        tbaAccount = payable(
            registry.createAccount(
                accountImplementation,
                block.chainid,
                address(this),
                tokenId,
                0, // salt
                abi.encodeWithSignature("initialize()") // init data
            )
        );

        // Mint token
        _mint(to, tokenId);
    }

    /// @notice Retrieves the tokenbound account of a given token ID.
    /// @param tokenId The ID of the token.
    /// @return The address of the tokenbound account.
    function getTbaAccount(uint256 tokenId) external view returns (address) {
        return registry.account(accountImplementation, block.chainid, address(this), tokenId, 0);
    }

    /// @notice Burns a token with the given ID.
    /// @param tokenId ID of the token to burn.
    function burn(uint256 tokenId) public onlyAdmin {
        _burn(tokenId);
    }

    /// @notice Sets the base URI for the token.
    /// @param uri The new base URI.
    function setBaseURI(string memory uri) external onlyOwner {
        _baseURI_ = uri;
    }

    /// @dev Modifier to ensure only the admin can call certain functions.
    modifier onlyAdmin() {
        require(_admins[msg.sender], "Only admin");
        _;
    }

    /// @notice Returns the name of the token.
    /// @return The name of the token.
    function name() public view override returns (string memory) {
        return _name;
    }

    /// @notice Returns the symbol of the token.
    /// @return The symbol of the token.
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /// @notice Retrieves the membership tier of a given token ID.
    /// @param tokenId The ID of the token.
    /// @return The membership tier of the token.
    function getTier(uint256 tokenId) external view returns (uint256) {
        return membershipTier[tokenId];
    }

    /// @notice Sets the membership tier of a given token ID.
    /// @param tokenId The ID of the token.
    function setTier(uint256 tokenId, uint256 newTier) external onlyAdmin {
        membershipTier[tokenId] = newTier;
    }

    // /// @notice Returns the URI for a given token ID.
    // /// @param _id The token ID.
    // /// @return The complete URI of the token.
    // function tokenURI(uint256 _id) public view override returns (string memory) {
    //     require(exists(_id), "Token does not exist");

    //     return string(abi.encodePacked(_baseURI_, Strings.toString(_id)));
    // }

    /// @notice Adds an admin.
    /// @param _admin The address of the new admin.
    function addAdmin(address _admin) external onlyOwner {
        _admins[_admin] = true;
    }

    /// @notice Removes an admin.
    /// @param _admin The address of the admin to remove.
    function removeAdmin(address _admin) external onlyOwner {
        _admins[_admin] = false;
    }

    /// @notice Checks if an address is an admin.
    /// @param _admin The address to check.
    /// @return True if the address is an admin, false otherwise.
    function isAdmin(address _admin) external view returns (bool) {
        return _admins[_admin];
    }

    /// @notice Updates the implementation of the account.
    /// @param _accountImplementation The new account implementation address.
    function updateImplementation(address payable _accountImplementation) external onlyOwner {
        accountImplementation = _accountImplementation;
    }

    /// @notice Overrides the supportsInterface function to include support for IERC721.
    /// @param interfaceId The interface ID to check for.
    /// @return True if the interface is supported, false otherwise.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ERC721).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice Transfers ownership of the contract to a new owner.
    /// @param newOwner The address of the new owner.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero");
        owner = newOwner;
    }
}
