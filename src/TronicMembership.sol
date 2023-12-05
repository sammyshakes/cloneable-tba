// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IERC6551Registry.sol";
import "./interfaces/ITronicMembership.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title TronicMembership
/// @notice This contract represents the membership token for the Tronic ecosystem.
contract TronicMembership is ITronicMembership, ERC721, Initializable {
    uint256 public MEMBERSHIP_ID;

    string private _name;
    string private _symbol;
    string private _baseURI_;

    bool public isElastic;
    uint256 public maxMintable;

    address public owner;
    uint8 private _numTiers;
    uint8 private _maxTiers;
    uint256 private _totalBurned;
    uint256 private _totalMinted;

    mapping(string => uint8) private _tierIdToTierIndex;
    mapping(uint8 => MembershipTier) private _membershipTiers;
    mapping(uint256 => MembershipToken) private _membershipTokens;
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
    /// @dev The constructor is used to disable the initializers.
    constructor() ERC721("", "") {
        _disableInitializers();
    }

    /// @notice Initializes the contract with given parameters.
    /// @param membershipId The ID of the membership.
    /// @param name_ Name of the token.
    /// @param symbol_ Symbol of the token.
    /// @param uri Base URI of the token.
    /// @param _maxMintable Maximum number of tokens that can be minted.
    /// @param _isElastic Whether max mintable is adjustable or not.
    /// @param _maxMembershipTiers Maximum number of membership tiers.
    /// @param tronicAdmin Address of the initial admin.
    /// @dev This function is called by the tronicMain contract.
    function initialize(
        uint256 membershipId,
        string memory name_,
        string memory symbol_,
        string memory uri,
        uint256 _maxMintable,
        bool _isElastic,
        uint8 _maxMembershipTiers,
        address tronicAdmin
    ) external initializer {
        owner = tronicAdmin;
        _admins[tronicAdmin] = true;
        _admins[msg.sender] = true;
        _name = name_;
        _symbol = symbol_;
        _baseURI_ = uri;
        _maxTiers = _maxMembershipTiers;
        maxMintable = _maxMintable;
        isElastic = _isElastic;
        MEMBERSHIP_ID = membershipId;
    }

    /// @notice Mints a new token.
    /// @param to Address to mint the token to.
    /// @param tierIndex The index of the membership tier to associate with the token.
    /// @return tokenId The ID of the token.
    /// @dev This function can only be called by an admin.
    /// @dev The tier must exist.
    function mint(address to, uint8 tierIndex) external onlyAdmin returns (uint256 tokenId) {
        require(balanceOf(to) == 0, "Recipient already owns a membership token");
        require(tierIndex <= _numTiers, "Tier does not exist");

        tokenId = ++_totalMinted;
        require(tokenId <= maxMintable, "Max supply reached");

        _membershipTokens[tokenId] = MembershipToken(tierIndex, uint128(block.timestamp));
        _mint(to, tokenId);
    }

    /// @notice Creates a new membership tier.
    /// @param tierId The ID of the new tier.
    /// @param duration The duration of the new tier in seconds.
    /// @param isOpen Whether the tier is open or closed.
    /// @param tierURI The URI of the tier.
    /// @dev Only callable by admin.
    function createMembershipTier(
        string memory tierId,
        uint128 duration,
        bool isOpen,
        string calldata tierURI
    ) external onlyAdmin returns (uint8 tierIndex) {
        tierIndex = ++_numTiers;
        require(tierIndex <= _maxTiers, "Max Tier limit reached");
        _membershipTiers[tierIndex] =
            MembershipTier({tierId: tierId, duration: duration, isOpen: isOpen, tierURI: tierURI});

        _tierIdToTierIndex[tierId] = tierIndex;
    }

    /// @notice Creates multiple new membership tiers.
    /// @param tiers An array of `MembershipTier` structs.
    /// @dev Only callable by admin. Arrays must all have the same length.
    function createMembershipTiers(MembershipTier[] calldata tiers) external onlyAdmin {
        require(_numTiers + tiers.length <= _maxTiers, "Max Tier limit reached");

        for (uint256 i = 0; i < tiers.length; i++) {
            _membershipTiers[++_numTiers] = MembershipTier({
                tierId: tiers[i].tierId,
                duration: tiers[i].duration,
                isOpen: tiers[i].isOpen,
                tierURI: tiers[i].tierURI
            });

            _tierIdToTierIndex[tiers[i].tierId] = _numTiers;
        }
    }

    /// @notice Retrieves tier index of a given tier ID.
    /// @param tierId The ID of the tier.
    /// @return The index of the tier.
    /// @dev Returns 0 if the tier does not exist.
    function getTierIndexByTierId(string memory tierId) external view returns (uint8) {
        return _tierIdToTierIndex[tierId];
    }

    /// @notice Sets the details of a membership tier.
    /// @param tierIndex The index of the tier to update.
    /// @param duration The new duration in seconds.
    /// @param isOpen The new open status.
    /// @dev Only callable by admin.
    /// @dev the tier must exist.
    function setMembershipTier(
        uint8 tierIndex,
        string calldata tierId,
        uint128 duration,
        bool isOpen,
        string calldata tierURI
    ) external onlyAdmin tierExists(tierIndex) {
        _membershipTiers[tierIndex].tierId = tierId;
        _membershipTiers[tierIndex].duration = duration;
        _membershipTiers[tierIndex].isOpen = isOpen;
        _membershipTiers[tierIndex].tierURI = tierURI;
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
    function setMembershipToken(uint256 tokenId, uint8 tierIndex)
        external
        onlyAdmin
        tierExists(tierIndex)
    {
        _membershipTokens[tokenId] = MembershipToken(tierIndex, uint128(block.timestamp));
    }

    /// @notice Retrieves the membership details of a specific token.
    /// @param tokenId The ID of the token whose membership details are to be retrieved.
    /// @return The membership details of the token, represented by a `TokenMembership` struct.
    function getMembershipToken(uint256 tokenId) external view returns (MembershipToken memory) {
        return _membershipTokens[tokenId];
    }

    //function to determine if a token has a valid membership
    /// @notice Checks if a token has a valid membership.
    /// @param tokenId The ID of the token.
    /// @return True if the token has a valid membership, false otherwise.
    function isValid(uint256 tokenId) external view returns (bool) {
        MembershipToken memory membership = _membershipTokens[tokenId];
        MembershipTier memory tier = _membershipTiers[membership.tierIndex];
        return membership.timestamp + tier.duration > block.timestamp;
    }

    // write tokenURI function that returns the membership tier URI
    function tokenURI(uint256 tokenID) public view override returns (string memory) {
        require(tokenID <= totalSupply(), "This token does not exist");
        //get tier index from token id
        uint8 tierIndex = _membershipTokens[tokenID].tierIndex;
        //get tier uri from tier index
        string memory tierURI = _membershipTiers[tierIndex].tierURI;
        //return baseURI + tierURI
        return bytes(tierURI).length > 0 ? string(abi.encodePacked(_baseURI(), tierURI)) : "";
    }

    /// @notice Sets the max supply of the token.
    /// @param _maxMintable The new max supply.
    /// @dev Only callable by admin.
    /// @dev Only callable for elastic tokens.
    /// @dev The max supply must be greater than the total minted.
    function setMaxMintable(uint256 _maxMintable) external onlyAdmin {
        require(isElastic, "Max mintable can only be set for elastic tokens");
        require(_maxMintable > _totalMinted, "Max mintable must be greater than total minted");
        maxMintable = _maxMintable;
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

    /// @notice Overrides the supportsInterface function to include support for IERC721.
    /// @param interfaceId The interface ID to check for.
    /// @return True if the interface is supported, false otherwise.
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC721).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice Transfers ownership of the contract to a new owner.
    /// @param newOwner The address of the new owner.
    /// @dev Only callable by owner.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner address cannot be zero");
        owner = newOwner;
    }

    /// @notice Returns the total supply of the token.
    /// @return The total supply of the token.
    function totalSupply() public view returns (uint256) {
        return _totalMinted - _totalBurned;
    }

    /// @notice Returns the max supply of the token.
    /// @return The max supply of the token.
    function maxSupply() external view returns (uint256) {
        return maxMintable - _totalBurned;
    }

    /// @notice Returns _baseURI_.
    /// @return _baseURI_.
    /// @dev This function overrides the baseURI function of ERC721.
    function _baseURI() internal view override returns (string memory) {
        return _baseURI_;
    }
}
