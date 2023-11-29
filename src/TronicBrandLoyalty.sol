// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IERC6551Registry.sol";
import "./interfaces/ITronicBrandLoyalty.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title TronicBrandLoyalty
/// @notice This contract represents the membership token for the Tronic ecosystem.
contract TronicBrandLoyalty is ITronicBrandLoyalty, ERC721, Initializable {
    string private _name;
    string private _symbol;
    string private baseURI_;

    bool public isBound;

    address public owner;
    address public accountImplementation;

    uint256 private _totalBurned;
    uint256 private _totalMinted;

    IERC6551Registry public registry;

    // TODO: implement record of membership ids for each brand
    // uint256[] public membershipIds;

    mapping(address => bool) private _admins;

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

    /// @dev Modifier to ensure a token exists.
    /// @param tokenId The ID of the token to check.
    modifier tokenExists(uint256 tokenId) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        _;
    }

    /// @notice Constructor initializes the ERC721 with empty name and symbol.
    /// @dev The name and symbol can be set using the initialize function.
    /// @dev The constructor is left empty because of the proxy pattern used.
    constructor() ERC721("", "") {
        _disableInitializers();
    }

    /// @notice Initializes the contract with given parameters.
    /// @param _accountImplementation Implementation of the account.
    /// @param _registry Address of the registry contract.
    /// @param name_ Name of the token.
    /// @param symbol_ Symbol of the token.
    /// @param uri Base URI of the token.
    /// @param _isBound Whether the token is soulbound or not.
    /// @param tronicAdmin Address of the initial admin.
    /// @dev This function is called by the tronicMain contract.
    function initialize(
        address payable _accountImplementation,
        address _registry,
        string memory name_,
        string memory symbol_,
        string memory uri,
        bool _isBound,
        address tronicAdmin
    ) external initializer {
        accountImplementation = _accountImplementation;
        registry = IERC6551Registry(_registry);
        owner = tronicAdmin;
        _admins[tronicAdmin] = true;
        _admins[msg.sender] = true;
        _name = name_;
        _symbol = symbol_;
        baseURI_ = uri;
        isBound = _isBound;
    }

    /// @notice Mints a new token.
    /// @param to Address to mint the token to.
    /// @return tbaAccount The payable address of the created tokenbound account.
    /// @return tokenId The ID of the minted token.
    /// @dev The tokenbound account is created using the registry contract.
    function mint(address to)
        public
        onlyAdmin
        returns (address payable tbaAccount, uint256 tokenId)
    {
        tokenId = ++_totalMinted;

        // Deploy token account
        tbaAccount = payable(
            registry.createAccount(
                accountImplementation,
                block.chainid,
                address(this),
                _totalMinted,
                0, // salt
                abi.encodeWithSignature("initialize()") // init data
            )
        );

        // Mint token
        _mint(to, _totalMinted);

        return (tbaAccount, tokenId);
    }

    /// @notice Retrieves the tokenbound account of a given token ID.
    /// @param tokenId The ID of the token.
    /// @return The address of the tokenbound account.
    function getTBAccount(uint256 tokenId) external view returns (address) {
        return registry.account(accountImplementation, block.chainid, address(this), tokenId, 0);
    }

    /// @notice Burns a token with the given ID.
    /// @param tokenId ID of the token to burn.
    function burn(uint256 tokenId) external onlyAdmin {
        ++_totalBurned;
        _burn(tokenId);
    }

    /// @notice Sets the base URI for the token.
    /// @param uri The new base URI.
    function setBaseURI(string memory uri) external onlyOwner {
        baseURI_ = uri;
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

    /// @notice Adds an admin.
    /// @param _admin The address of the new admin.
    /// @dev Only callable by owner.
    function addAdmin(address _admin) external onlyOwner {
        _admins[_admin] = true;
    }

    /// @notice Removes an admin.
    /// @param _admin The address of the admin to remove.
    /// @dev Only callable by owner.
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
    /// @dev Only callable by owner.
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
    /// @dev Only callable by owner.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero");
        owner = newOwner;
    }

    /// @notice Transfers an unbound token from one address to another.
    /// @param from The address to transfer the token from.
    /// @param to The address to transfer the token to.
    /// @param tokenId The ID of the token to transfer.
    /// @dev This function overrides the transferFrom function of ERC721.
    /// @dev it reverts if the token is bound or if msg.sender is admin.
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(!isBound || _admins[msg.sender], "Token is bound");
        super.transferFrom(from, to, tokenId);
    }

    /// @notice Safely transfers an unbound token from one address to another.
    /// @param from The address to transfer the token from.
    /// @param to The address to transfer the token to.
    /// @param tokenId The ID of the token to transfer.
    /// @dev This function overrides the safeTransferFrom function of ERC721.
    /// @dev it reverts if the token is bound or if msg.sender is admin.
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
        public
        override
    {
        require(!isBound || _admins[msg.sender], "Token is bound");
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    /// @notice Returns the total supply of the token.
    /// @return The total supply of the token.
    function totalSupply() external view returns (uint256) {
        return _totalMinted - _totalBurned;
    }

    /// @notice Returns baseURI_.
    /// @return baseURI_.
    /// @dev This function overrides the baseURI function of ERC721.
    function _baseURI() internal view override returns (string memory) {
        return baseURI_;
    }
}
