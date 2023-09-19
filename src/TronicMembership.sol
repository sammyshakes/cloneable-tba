// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./interfaces/IERC6551Registry.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title TronicMembership
/// @notice This contract represents the membership token for the Tronic ecosystem.
contract TronicMembership is ERC721Enumerable, Initializable {
    struct MembershipTier {
        string tierId;
        uint128 duration;
        bool isOpen;
    }

    struct TokenMembership {
        uint8 tierIndex;
        uint128 timestamp;
    }

    string private _name;
    string private _symbol;
    string private _baseURI_;

    address public owner;
    address public accountImplementation;
    uint8 private _numTiers;
    uint8 private _maxTiers;
    bool public isElastic;
    uint256 public maxSupply;
    uint256 private _totalMinted;

    IERC6551Registry public registry;

    mapping(uint8 => MembershipTier) private _membershipTiers;
    mapping(uint256 => TokenMembership) private _tokenMemberships;
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
    /// @dev This function is called by the tronicMain contract.
    function initialize(
        address payable _accountImplementation,
        address _registry,
        string memory name_,
        string memory symbol_,
        string memory uri,
        uint8 _maxMembershipTiers,
        uint256 _maxSupply,
        bool _isElastic,
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
        _maxTiers = _maxMembershipTiers;
        maxSupply = _maxSupply;
        isElastic = _isElastic;
    }

    /// @notice Mints a new token.
    /// @param to Address to mint the token to.
    /// @return tbaAccount The payable address of the created tokenbound account.
    /// @dev The tokenbound account is created using the registry contract.
    function mint(address to) public onlyAdmin returns (address payable tbaAccount) {
        require(++_totalMinted <= maxSupply, "Max supply reached");
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
    }

    /// @notice Creates a new membership tier.
    /// @param tierId The ID of the new tier.
    /// @param duration The duration of the new tier in seconds.
    /// @param isOpen Whether the tier is open or closed.
    /// @dev Only callable by admin.
    function createMembershipTier(string memory tierId, uint128 duration, bool isOpen)
        external
        onlyAdmin
    {
        require(++_numTiers <= _maxTiers, "Max Tier limit reached");
        _membershipTiers[_numTiers] =
            MembershipTier({tierId: tierId, duration: duration, isOpen: isOpen});
    }

    /// @notice Creates multiple new membership tiers.
    /// @param tierIds The IDs of the new tiers.
    /// @param durations The durations of the new tiers in seconds.
    /// @param isOpens Whether the tiers are open or closed.
    /// @dev Only callable by admin. Arrays must all have the same length.
    function createMembershipTiers(
        string[] memory tierIds,
        uint128[] memory durations,
        bool[] memory isOpens
    ) external onlyAdmin {
        require(
            isOpens.length == tierIds.length && tierIds.length == durations.length,
            "Input array mismatch"
        );
        require(_numTiers + tierIds.length <= _maxTiers, "Max Tier limit reached");

        for (uint256 i = 0; i < tierIds.length; i++) {
            _membershipTiers[++_numTiers] =
                MembershipTier({tierId: tierIds[i], duration: durations[i], isOpen: isOpens[i]});
        }
    }

    /// @notice Sets the open status of a membership tier.
    /// @param tierIndex The index of the tier to update.
    /// @param isOpen The new open status.
    /// @dev Only callable by admin.
    function setMembershipTierOpenStatus(uint8 tierIndex, bool isOpen) external onlyAdmin {
        require(tierIndex <= _numTiers, "Tier does not exist");
        _membershipTiers[tierIndex].isOpen = isOpen;
    }

    /// @notice Sets the ID of a membership tier.
    /// @param tierIndex The index of the tier to update.
    /// @param tierId The new tier ID.
    /// @dev Only callable by admin.
    function setMembershipTierId(uint8 tierIndex, string memory tierId) external onlyAdmin {
        require(tierIndex <= _numTiers, "Tier does not exist");
        _membershipTiers[tierIndex].tierId = tierId;
    }

    /// @notice Sets the duration of a membership tier.
    /// @param tierIndex The index of the tier to update.
    /// @param duration The new duration in seconds.
    /// @dev Only callable by admin.
    function setMembershipTierDuration(uint8 tierIndex, uint128 duration) external onlyAdmin {
        require(tierIndex <= _numTiers, "Tier does not exist");
        _membershipTiers[tierIndex].duration = duration;
    }

    /// @notice Retrieves the details of a membership tier.
    /// @param tierIndex The index of the tier to retrieve.
    /// @return The details of the tier.
    function getMembershipTierDetails(uint8 tierIndex)
        external
        view
        returns (MembershipTier memory)
    {
        return _membershipTiers[tierIndex];
    }

    /// @notice Retrieves the ID of a membership tier.
    /// @param tierIndex The index of the tier to retrieve.
    /// @return The ID of the tier.
    function getMembershipTierId(uint8 tierIndex) external view returns (string memory) {
        return _membershipTiers[tierIndex].tierId;
    }

    /// @notice Sets the membership details of a specific token.
    /// @param tokenId The ID of the token whose membership details are to be set.
    /// @param tierIndex The index of the membership tier to associate with the token.
    /// @dev This function can only be called by an admin.
    function setTokenMembership(uint256 tokenId, uint8 tierIndex) external onlyAdmin {
        require(tierIndex <= _numTiers, "Tier does not exist");
        _tokenMemberships[tokenId] = TokenMembership(tierIndex, uint128(block.timestamp));
    }

    /// @notice Retrieves the membership details of a specific token.
    /// @param tokenId The ID of the token whose membership details are to be retrieved.
    /// @return The membership details of the token, represented by a `TokenMembership` struct.
    function getTokenMembership(uint256 tokenId) external view returns (TokenMembership memory) {
        return _tokenMemberships[tokenId];
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

    /// @notice Sets the max supply of the token.
    /// @param _maxSupply The new max supply.
    /// @dev Only callable by admin.
    /// @dev Only callable for elastic tokens.
    /// @dev The max supply must be greater than the total minted.
    function setMaxSupply(uint256 _maxSupply) external onlyAdmin {
        require(isElastic, "Max supply can only be set for elastic tokens");
        require(_maxSupply > _totalMinted, "Max supply must be greater than total minted");
        maxSupply = _maxSupply;
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
