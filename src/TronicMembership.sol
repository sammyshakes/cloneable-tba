// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./interfaces/IERC6551Registry.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title TronicMembership
/// @notice This contract represents the membership token for the Tronic ecosystem.
contract TronicMembership is ERC721, Initializable {
    /// @dev Struct representing a membership tier.
    /// @param tierId The ID of the tier.
    /// @param duration The duration of the tier in seconds.
    /// @param isOpen Whether the tier is open or closed.
    struct MembershipTier {
        string tierId;
        uint128 duration;
        bool isOpen;
    }

    /// @dev Struct representing the membership details of a token.
    /// @param tierIndex The index of the membership tier.
    /// @param timestamp The timestamp of the membership.
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
    bool public isBound;
    uint256 public maxSupply;
    uint256 private _totalBurned;
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

    /// @dev Modifier to ensure a tier exists.
    /// @param tierIndex The index of the tier to check.
    modifier tierExists(uint8 tierIndex) {
        require(tierIndex <= _numTiers, "Tier does not exist");
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
    constructor() ERC721("", "") {}

    /// @notice Initializes the contract with given parameters.
    /// @param _accountImplementation Implementation of the account.
    /// @param _registry Address of the registry contract.
    /// @param name_ Name of the token.
    /// @param symbol_ Symbol of the token.
    /// @param uri Base URI of the token.
    /// @param _maxMembershipTiers Maximum number of membership tiers.
    /// @param _maxSupply Maximum supply of the token.
    /// @param _isElastic Whether the max token supply is elastic or not.
    /// @param _isBound Whether the token is soulbound or not.
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
        _baseURI_ = uri;
        _maxTiers = _maxMembershipTiers;
        maxSupply = _maxSupply;
        isElastic = _isElastic;
        isBound = _isBound;
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
    /// @dev the tier must exist.
    function setMembershipTierOpenStatus(uint8 tierIndex, bool isOpen)
        external
        onlyAdmin
        tierExists(tierIndex)
    {
        _membershipTiers[tierIndex].isOpen = isOpen;
    }

    /// @notice Sets the ID of a membership tier.
    /// @param tierIndex The index of the tier to update.
    /// @param tierId The new tier ID.
    /// @dev Only callable by admin.
    /// @dev the tier must exist.
    function setMembershipTierId(uint8 tierIndex, string memory tierId)
        external
        onlyAdmin
        tierExists(tierIndex)
    {
        _membershipTiers[tierIndex].tierId = tierId;
    }

    /// @notice Sets the duration of a membership tier.
    /// @param tierIndex The index of the tier to update.
    /// @param duration The new duration in seconds.
    /// @dev Only callable by admin.
    /// @dev the tier must exist.
    function setMembershipTierDuration(uint8 tierIndex, uint128 duration)
        external
        onlyAdmin
        tierExists(tierIndex)
    {
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
    /// @dev The tier must exist.
    function setTokenMembership(uint256 tokenId, uint8 tierIndex)
        external
        onlyAdmin
        tierExists(tierIndex)
    {
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

    /// @notice Retrieves tier index of a given tier ID.
    /// @param tierId The ID of the tier.
    /// @return The index of the tier.
    /// @dev Returns 0 if the tier does not exist.
    function getTierIndexByTierId(string memory tierId) external view returns (uint8) {
        for (uint8 i = 1; i <= _numTiers; i++) {
            string memory candidateTierId = _membershipTiers[i].tierId;
            if (keccak256(abi.encodePacked(candidateTierId)) == keccak256(abi.encodePacked(tierId)))
            {
                return i;
            }
        }

        return 0;
    }

    //function to determine if a token has an expired membership
    /// @notice Checks if a token has an expired membership.
    /// @param tokenId The ID of the token.
    /// @return True if the token has an expired membership, false otherwise.
    function isExpired(uint256 tokenId) external view returns (bool) {
        TokenMembership memory membership = _tokenMemberships[tokenId];
        MembershipTier memory tier = _membershipTiers[membership.tierIndex];
        return membership.timestamp + tier.duration < block.timestamp && membership.timestamp != 0
            && tier.duration != 0;
    }

    /// @notice Burns a token with the given ID.
    /// @param tokenId ID of the token to burn.
    function burn(uint256 tokenId) external onlyAdmin {
        ++_totalBurned;
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

    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721) {
        require(!isBound, "Token is bound");
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
        public
        override(ERC721)
    {
        require(!isBound, "Token is bound");
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function totalSupply() external view returns (uint256) {
        return _totalMinted - _totalBurned;
    }
}
