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

    uint256 private _totalMinted;
    uint256 public maxSupply;

    mapping(uint256 => string) private tokenIdToMembershipTierId;
    mapping(address => bool) private _admins;

    // Token name, symbol and base uri
    string private _name;
    string private _symbol;
    string private _baseURI_;

    /// @dev Modifier to ensure only the owner can call certain functions.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /// @dev Modifier to ensure only the admin can call certain functions.
    modifier onlyAdmin() {
        require(_admins[msg.sender], "Only admin");
        _;
    }

    /// @notice Constructor initializes the ERC721 with empty name and symbol.
    /// @dev The name and symbol can be set using the initialize function.
    /// @dev The constructor is left empty because of the proxy pattern used.
    constructor() ERC721("", "") {}

    /// @notice Initializes the contract with given parameters.
    /// @param _accountImplementation Implementation of the account.
    /// @param _registry Address of the registry contract.
    /// @param name_ Name of the token.
    /// @param symbol_ Symbol of the token.
    /// @param uri Base URI of the token.
    /// @param tronicAdmin Address of the initial admin.
    function initialize(
        address payable _accountImplementation,
        address _registry,
        string memory name_,
        string memory symbol_,
        string memory uri,
        uint256 _maxSupply,
        address tronicAdmin
    ) external initializer {
        accountImplementation = _accountImplementation;
        registry = IERC6551Registry(_registry);
        owner = tronicAdmin;
        _admins[tronicAdmin] = true;
        _admins[msg.sender] = true;
        _name = name_;
        _symbol = symbol_;
        _baseURI_ = uri;
        maxSupply = _maxSupply;
    }

    /// @notice Mints a new token.
    /// @param to Address to mint the token to.
    /// @return tbaAccount The payable address of the created tokenbound account.
    function mint(address to) public onlyAdmin returns (address payable tbaAccount) {
        require(_totalMinted < maxSupply, "Max supply reached");
        // Deploy token account
        tbaAccount = payable(
            registry.createAccount(
                accountImplementation,
                block.chainid,
                address(this),
                ++_totalMinted,
                0, // salt
                abi.encodeWithSignature("initialize()") // init data
            )
        );

        // Mint token
        _mint(to, _totalMinted);
    }

    /// @notice Retrieves the tokenbound account of a given token ID.
    /// @param tokenId The ID of the token.
    /// @return The address of the tokenbound account.
    function getTBAccount(uint256 tokenId) external view returns (address) {
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
    function getMembershipTier(uint256 tokenId) external view returns (string memory) {
        return tokenIdToMembershipTierId[tokenId];
    }

    /// @notice Sets the membership tier of a given token ID.
    /// @param tokenId The ID of the token.
    /// @param newTierId The new membership tier ID.
    function setMembershipTier(uint256 tokenId, string memory newTierId) external onlyAdmin {
        tokenIdToMembershipTierId[tokenId] = newTierId;
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
