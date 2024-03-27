// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC6551Account} from "./interfaces/IERC6551Account.sol";
import {IERC6551Registry} from "./interfaces/IERC6551Registry.sol";
import {ITronicMembership} from "./interfaces/ITronicMembership.sol";
import {ITronicBrandLoyalty} from "./interfaces/ITronicBrandLoyalty.sol";
import {ITronicToken} from "./interfaces/ITronicToken.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title TronicMain
/// @notice This contract is the main contract for the Tronic ecosystem.
/// @dev This contract is upgradeable using the UUPS proxy pattern.
/// @dev This contract is the entry point for all Tronic transactions.
contract TronicMain is Initializable, UUPSUpgradeable {
    /// @notice The struct for membership information.
    /// @param brandName The name of the brand.
    /// @param brandLoyaltyAddress The address of the brand loyalty ERC721 contract.
    /// @param achievementAddress The address of the achievement token ERC1155 contract.
    /// @param rewardsAddress The address of the rewards ERC1155 contract.
    /// @param memberships The list of memberships for the brand.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    struct BrandInfo {
        string brandName;
        address brandLoyaltyAddress;
        address achievementAddress;
        address rewardsAddress;
        uint256[] membershipIds;
    }

    /// @notice The struct for membership information.
    /// @param brandId The ID of the brand.
    /// @param membershipName The name of the membership.
    /// @param membershipAddress The address of the membership ERC721 contract.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    struct MembershipInfo {
        uint256 brandId;
        string membershipName;
        address membershipAddress;
    }

    /// @notice The enum for token type.
    /// @param ERC1155 The ERC1155 token type.
    /// @param ERC721 The ERC721 token type.
    enum TokenType {
        ERC1155,
        ERC721
    }

    /// @notice The event emitted when a membership is minted.
    /// @param membershipId The ID of the membership.
    /// @param tokenId The ID of the minted token.
    /// @param recipientAddress The address of the recipient of the minted token.
    event MembershipMinted(
        uint256 indexed membershipId, uint256 indexed tokenId, address indexed recipientAddress
    );

    /// @notice The event emitted when a brand loyalty token is minted.
    /// @param brandId The ID of the brand.
    /// @param tokenId The ID of the minted token.
    /// @param recipientAddress The address of the recipient of the minted token.
    /// @param tbaAccount The address of the tokenbound account.
    event LoyaltyTokenMinted(
        uint256 indexed brandId,
        uint256 indexed tokenId,
        address indexed recipientAddress,
        address tbaAccount
    );

    /// @notice The event emitted when a reward token is minted.
    /// @param brandId The ID of the brand.
    /// @param tokenId The ID of the minted token.
    /// @param recipientAddress The address of the recipient of the minted token.
    event RewardTokenMinted(
        uint256 indexed brandId, uint256 indexed tokenId, address indexed recipientAddress
    );

    /// @notice The event emitted when a membership tier is assigned to a token.
    /// @param membershipAddress The address of the membership ERC721 contract that token belongs to.
    /// @param tokenId The ID of the token that tier will be assigned to.
    /// @param tierIndex The index of the membership tier that will be assigned to token.
    event TierAssigned(
        address indexed membershipAddress, uint256 indexed tokenId, uint256 indexed tierIndex
    );

    /// @notice The event emitted when a membership is added.
    /// @param brandId The ID of the brand.
    /// @param membershipId The ID of the membership.
    /// @param membershipAddress The address of the membership ERC721 contract.
    event MembershipAdded(
        uint256 indexed brandId, uint256 indexed membershipId, address indexed membershipAddress
    );

    /// @notice The event emitted when a brand is added.
    /// @param brandId The ID of the brand.
    /// @param brandName The name of the brand.
    /// @param brandLoyaltyAddress The address of the brand ERC721 contract.
    /// @param achievementAddress The address of the token ERC1155 contract.
    event BrandAdded(
        uint256 indexed brandId,
        string brandName,
        address indexed brandLoyaltyAddress,
        address indexed achievementAddress,
        address rewardsAddress
    );

    /// @notice The event emitted when a membership is removed.
    /// @param membershipId The ID of the membership.
    event MembershipRemoved(uint256 indexed membershipId);

    /// @notice The event emitted when a fungible token type is created.
    /// @param brandId The ID of the brand.
    /// @param tokenId The ID of the newly created token type.
    /// @param isReward Whether or not the token type is a reward, false = achievement.
    event FungibleTokenTypeCreated(uint256 indexed brandId, uint256 indexed tokenId, bool isReward);

    /// @notice The event emitted when a non-fungible  token type is created.
    /// @param brandId The ID of the brand.
    /// @param tokenId The ID of the newly created token type.
    /// @param maxMintable The maximum number of tokens that can be minted.
    /// @param uri The URI of the token type.
    /// @param isReward Whether or not the token type is a reward, false = achievement.
    event NonFungibleTokenTypeCreated(
        uint256 indexed brandId,
        uint256 indexed tokenId,
        uint256 maxMintable,
        string uri,
        bool isReward
    );

    address public owner;
    address public tronicAdmin;
    address public tbaAccountImplementation;
    address public tbaProxyImplementation;
    uint8 public maxTiersPerMembership;

    /// @notice The starting ID for non-fungible token types of the Achievements and Rewards.
    /// @dev These are the starting IDs for non-fungible token types on newly deployed reward/token contracts.
    /// @dev It is provided as a parameter to the TronicMain contract when deploying the token contract.
    /// @dev This value should be set to a high enough value to allow for the creation of a large number of fungible token types.
    /// @dev EX: If achievementNFTTypeStartId is 1000, the first non-fungible token type will have an ID of 1000.
    /// @dev This will give the brand the ability to create 999 fungible token types.
    /// @dev Future NFT types will start at previous type's starting id + maxMintable.
    uint64 public achievementNFTTypeStartId;
    uint64 public rewardsNFTTypeStartId;

    uint256 public brandCounter;
    mapping(uint256 => BrandInfo) private brands;

    uint256 public membershipCounter;
    mapping(uint256 => MembershipInfo) private memberships;
    mapping(address => bool) private _admins;

    // Deployments
    IERC6551Registry public registry;
    ITronicBrandLoyalty public tronicBrandLoyalty;
    ITronicMembership public tronicMembership;
    ITronicToken public tronicAchievement;
    ITronicToken public tronicRewards;

    //disable initializer for upgradeability in the constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the TronicMain contract.
    /// @param _admin The address of the Tronic admin.
    /// @param _brandLoyalty The address of the Tronic Brand Loyalty contract (ERC721 implementation).
    /// @param _tronicMembership The address of the Tronic Membership contract (ERC1155 implementation).
    /// @param _tronicAchievement The address of the Tronic Achievement contract (ERC1155 implementation).
    /// @param _tronicRewards The address of the Tronic Rewards contract (ERC1155 implementation).
    /// @param _registry The address of the registry contract.
    /// @param _tbaImplementation The address of the tokenbound account implementation.
    /// @param _tbaProxyImplementation The address of the tokenbound account proxy implementation.
    /// @param _maxTiersPerMembership The maximum number of tiers per membership.
    /// @param _achievementNftTypeStartId The starting ID for non-fungible token types.
    /// @param _rewardsNftTypeStartId The starting ID for non-fungible token types.
    function initialize(
        address _admin,
        address _brandLoyalty,
        address _tronicMembership,
        address _tronicAchievement,
        address _tronicRewards,
        address _registry,
        address _tbaImplementation,
        address _tbaProxyImplementation,
        uint8 _maxTiersPerMembership,
        uint64 _achievementNftTypeStartId,
        uint64 _rewardsNftTypeStartId
    ) public initializer {
        owner = msg.sender;
        tronicAdmin = _admin;
        tronicBrandLoyalty = ITronicBrandLoyalty(_brandLoyalty);
        tronicAchievement = ITronicToken(_tronicAchievement);
        tronicRewards = ITronicToken(_tronicRewards);
        tronicMembership = ITronicMembership(_tronicMembership);
        registry = IERC6551Registry(_registry);
        tbaAccountImplementation = _tbaImplementation;
        tbaProxyImplementation = _tbaProxyImplementation;
        maxTiersPerMembership = _maxTiersPerMembership;
        achievementNFTTypeStartId = _achievementNftTypeStartId;
        rewardsNFTTypeStartId = _rewardsNftTypeStartId;
    }

    /// @notice Checks if the caller is the owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @notice Checks if the caller is an admin.
    modifier onlyAdmin() {
        require(_admins[msg.sender] || msg.sender == tronicAdmin, "Only admin");
        _;
    }

    /// @notice Gets MembershipInfo for a given membership ID.
    /// @param membershipId The ID of the membership to get info for.
    /// @return The MembershipInfo struct for the given membership ID.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    function getMembershipInfo(uint256 membershipId) public view returns (MembershipInfo memory) {
        return memberships[membershipId];
    }

    /// @notice Gets BrandInfo for a given membership ID.
    /// @param brandId The ID of the membership to get info for.
    /// @return The BrandInfo struct for the given membership ID.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    function getBrandInfo(uint256 brandId) public view returns (BrandInfo memory) {
        return brands[brandId];
    }

    /// @notice Deploys a new membership's contracts.
    /// @param brandId The ID of the brand to create the membership for.
    /// @param membershipName The membership name for the Membership token.
    /// @param membershipSymbol The membership symbol for the Brand Loyalty token.
    /// @param membershipBaseURI The base URI for the membership Brand Loyalty token.
    /// @param maxMintable The maximum number of brand loyalty tokens that can be minted.
    /// @param isElastic Whether or not the brand loyalty token is elastic.
    /// @param tiers The tiers to create for the membership.
    /// @return membershipId The ID of the newly created membership.
    /// @return membershipAddress The address of the deployed membership ERC1155 contract.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    function deployMembership(
        uint256 brandId,
        string calldata membershipName,
        string calldata membershipSymbol,
        string calldata membershipBaseURI,
        uint256 maxMintable,
        bool isElastic,
        ITronicMembership.MembershipTier[] calldata tiers
    ) external onlyAdmin returns (uint256 membershipId, address membershipAddress) {
        require(brands[brandId].brandLoyaltyAddress != address(0), "Brand does not exist");

        membershipId = ++membershipCounter;

        // Deploy the membership's contracts
        membershipAddress = _deployMembership(
            membershipId,
            membershipName,
            membershipSymbol,
            membershipBaseURI,
            maxMintable,
            isElastic
        );

        // Assign membership id and associate the deployed contracts with the membership
        memberships[membershipId] = MembershipInfo({
            brandId: brandId,
            membershipAddress: membershipAddress,
            membershipName: membershipName
        });

        brands[brandId].membershipIds.push(membershipId);

        // Deploy tiers
        if (tiers.length > 0) {
            ITronicMembership(membershipAddress).createMembershipTiers(tiers);
        }

        emit MembershipAdded(brandId, membershipId, membershipAddress);
    }

    /// @notice Deploys a new Brand's Loyalty, Achievement and Rewards Token contracts.
    /// @param brandName The name for the Brand Loyalty token.
    /// @param brandSymbol The symbol for the Brand Loyalty token.
    /// @param brandBaseURI The base URI for the Brand Loyalty token.
    /// @param isBound Whether or not the brand loyalty token is bound.
    /// @return brandId The ID of the newly created brand.
    /// @return brandLoyaltyAddress The address of the deployed brand loyalty Brand Loyalty contract.
    /// @return achievementAddress The address of the deployed achievement ERC1155 contract.
    /// @return rewardsAddress The address of the deployed rewards ERC1155 contract.
    /// @dev The brand ID is the index of the brand in the brands mapping.
    function deployBrand(
        string calldata brandName,
        string calldata brandSymbol,
        string calldata brandBaseURI,
        bool isBound
    )
        external
        onlyAdmin
        returns (
            uint256 brandId,
            address brandLoyaltyAddress,
            address achievementAddress,
            address rewardsAddress
        )
    {
        brandId = ++brandCounter;
        // Deploy the Brand loyalty contract
        brandLoyaltyAddress = _deployBrandLoyalty(brandName, brandSymbol, brandBaseURI, isBound);

        //deploy Achievement Token contract
        achievementAddress = _deployAchievement();

        // deploy Rewards Token contract
        rewardsAddress = _deployRewards();

        // Assign brand id and associate the loyalty contracts with the brand
        brands[brandId] = BrandInfo({
            brandLoyaltyAddress: brandLoyaltyAddress,
            brandName: brandName,
            achievementAddress: achievementAddress,
            rewardsAddress: rewardsAddress,
            membershipIds: new uint256[](0)
        });

        emit BrandAdded(brandId, brandName, brandLoyaltyAddress, achievementAddress, rewardsAddress);
    }

    /// @notice Clones the Tronic Brand Loyalty (ERC721) implementation and initializes it.
    /// @return brandLoyaltyAddress The address of the newly cloned Brand Loyalty contract.
    function _deployBrandLoyalty(
        string calldata brandName,
        string calldata brandSymbol,
        string calldata brandBaseURI,
        bool isBound
    ) private onlyAdmin returns (address brandLoyaltyAddress) {
        brandLoyaltyAddress = Clones.clone(address(tronicBrandLoyalty));
        ITronicBrandLoyalty(brandLoyaltyAddress).initialize(
            tbaAccountImplementation,
            tbaProxyImplementation,
            address(registry),
            brandName,
            brandSymbol,
            brandBaseURI,
            isBound,
            tronicAdmin
        );
    }

    /// @notice Clones the Tronic Membership (ERC721) implementation and initializes it.
    /// @return membershipAddress The address of the newly cloned Membership contract.
    function _deployMembership(
        uint256 membershipId,
        string calldata name,
        string calldata symbol,
        string calldata baseURI,
        uint256 maxMintable,
        bool isElastic
    ) private returns (address membershipAddress) {
        membershipAddress = Clones.clone(address(tronicMembership));
        ITronicMembership(membershipAddress).initialize(
            membershipId,
            name,
            symbol,
            baseURI,
            maxMintable,
            isElastic,
            maxTiersPerMembership,
            tronicAdmin
        );
    }

    /// @notice Clones the ERC1155 implementation and initializes it.
    /// @return achievementAddress The address of the newly cloned ERC1155 contract.
    function _deployAchievement() private returns (address achievementAddress) {
        achievementAddress = Clones.clone(address(tronicAchievement));
        ITronicToken(achievementAddress).initialize(tronicAdmin, achievementNFTTypeStartId);
    }

    /// @notice Clones the ERC1155 implementation and initializes it.
    /// @return rewardsAddress The address of the newly cloned ERC1155 contract.
    function _deployRewards() private returns (address rewardsAddress) {
        rewardsAddress = Clones.clone(address(tronicRewards));
        ITronicToken(rewardsAddress).initialize(tronicAdmin, rewardsNFTTypeStartId);
    }

    /// @notice Removes a membership from the contract.
    /// @param _membershipId The ID of the membership to remove.
    function removeMembership(uint256 _membershipId) external onlyAdmin {
        delete memberships[_membershipId];
    }

    /// @notice Creates a new ERC1155 fungible token type for a brand.
    /// @param brandId The ID of the brand to create the token type for.
    /// @param maxSupply The maximum supply of the token type.
    /// @param uri The URI for the token type.
    /// @param isReward Whether or not the token type is a reward, false = achievement.
    /// @return typeId The ID of the newly created token type.
    /// @dev This function can only be called by an admin.
    /// @dev The brand must exist.
    function createFungibleTokenType(
        uint256 brandId,
        uint64 maxSupply,
        string memory uri,
        bool isReward
    ) external onlyAdmin returns (uint256 typeId) {
        address brandTokenAddress =
            isReward ? brands[brandId].rewardsAddress : brands[brandId].achievementAddress;
        require(brandTokenAddress != address(0), "Brand does not exist");

        typeId = ITronicToken(brandTokenAddress).createFungibleType(maxSupply, uri);

        emit FungibleTokenTypeCreated(brandId, typeId, isReward);
    }

    /// @notice Creates a new ERC1155 non-fungible token type for a brand.
    /// @param brandId The ID of the brand to create the token type for.
    /// @param baseUri The URI for the token type.
    /// @param maxMintable The maximum number of tokens that can be minted.
    /// @param isReward Whether or not the token type is a reward, false = achievement.
    /// @return nftTypeID The ID of the newly created token type.
    function createNonFungibleTokenType(
        uint256 brandId,
        string memory baseUri,
        uint64 maxMintable,
        bool isReward
    ) external onlyAdmin returns (uint256 nftTypeID) {
        address brandTokenAddress =
            isReward ? brands[brandId].rewardsAddress : brands[brandId].achievementAddress;
        require(brandTokenAddress != address(0), "Brand does not exist");

        nftTypeID = ITronicToken(brandTokenAddress).createNFTType(baseUri, maxMintable);

        emit NonFungibleTokenTypeCreated(brandId, nftTypeID, maxMintable, baseUri, isReward);
    }

    /// @notice Mints a new Brand Loyalty token.
    /// @param _recipient The address to mint the token to.
    /// @param _brandId The ID of the membership to mint the token for.
    /// @return tbaAccount The payable address of the created tokenbound account.
    /// @return brandTokenId The ID of the newly minted token.
    function mintBrandLoyaltyToken(address _recipient, uint256 _brandId)
        external
        onlyAdmin
        returns (address payable tbaAccount, uint256 brandTokenId)
    {
        BrandInfo memory brand = brands[_brandId];
        require(brand.brandLoyaltyAddress != address(0), "Brand does not exist");

        //mint brand loyalty token to recipient
        (tbaAccount, brandTokenId) = ITronicBrandLoyalty(brand.brandLoyaltyAddress).mint(_recipient);

        emit LoyaltyTokenMinted(_brandId, brandTokenId, _recipient, tbaAccount);
    }

    /// @notice Mints a new Membership token for a specified brand.
    /// @param _recipient The address to mint the token to.
    /// @param _membershipId The ID of the membership to mint the token for.
    /// @param _tierIndex The index of the membership tier to associate with the token.
    /// @return tokenId The ID of the newly minted token.
    function mintMembership(address _recipient, uint256 _membershipId, uint8 _tierIndex)
        external
        onlyAdmin
        returns (uint256 tokenId)
    {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");

        //mint membership token to recipient
        tokenId = ITronicMembership(membership.membershipAddress).mint(_recipient, _tierIndex);
        emit MembershipMinted(_membershipId, tokenId, _recipient);
    }

    /// @notice Creates a new membership tier.
    /// @param _membershipId The ID of the membership to create the tier for.
    /// @param _tierId The ID of the tier.
    /// @param _duration The duration of the tier.
    /// @param _isOpen Whether or not the tier is open.
    /// @param _tierURI The URI of the tier.
    /// @return tierIndex The index of the newly created tier.
    /// @dev This function can only be called by an admin.
    /// @dev The membership must exist.
    function createMembershipTier(
        uint256 _membershipId,
        string memory _tierId,
        uint128 _duration,
        bool _isOpen,
        string memory _tierURI
    ) external onlyAdmin returns (uint8 tierIndex) {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");

        return ITronicMembership(membership.membershipAddress).createMembershipTier(
            _tierId, _duration, _isOpen, _tierURI
        );
    }

    /// @notice Sets the details of a membership tier.
    /// @param _membershipId The ID of the membership to set the tier for.
    /// @param _tierIndex The index of the tier to set.
    /// @param _tierId The ID of the tier.
    /// @param _duration The duration of the tier.
    /// @param _isOpen Whether or not the tier is open.
    /// @param _tierURI The URI of the tier.
    /// @dev This function can only be called by an admin.
    /// @dev The membership must exist.
    /// @dev The tier must exist.
    function setMembershipTier(
        uint256 _membershipId,
        uint8 _tierIndex,
        string memory _tierId,
        uint128 _duration,
        bool _isOpen,
        string memory _tierURI
    ) external onlyAdmin {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");

        ITronicMembership(membership.membershipAddress).setMembershipTier(
            _tierIndex, _tierId, _duration, _isOpen, _tierURI
        );
    }

    /// @notice Gets the details of a membership tier.
    /// @param _membershipId The ID of the membership to get the tier for.
    /// @param _tierIndex The index of the tier to get.
    /// @return The details of the membership tier.
    /// @dev The membership must exist.
    /// @dev The tier must exist.
    function getMembershipTierInfo(uint256 _membershipId, uint8 _tierIndex)
        external
        view
        returns (ITronicMembership.MembershipTier memory)
    {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");

        return ITronicMembership(membership.membershipAddress).getMembershipTierDetails(_tierIndex);
    }

    /// @notice Retrieves tier index of a given tier ID.
    /// @param tierId The ID of the tier.
    /// @return The index of the tier.
    /// @dev Returns 0 if the tier does not exist.
    function getTierIndexByTierId(uint256 _membershipId, string memory tierId)
        external
        view
        returns (uint8)
    {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");

        return ITronicMembership(membership.membershipAddress).getTierIndexByTierId(tierId);
    }

    /// @notice Mints a fungible ERC1155 token.
    /// @param _brandId The ID of the brand to mint the token for.
    /// @param _recipient The address to mint the token to.
    /// @param _tokenId The tokenID (same as typeID for fungibles) of the token to mint.
    /// @param _amount The amount of the token to mint.
    /// @param _isReward Whether or not the token is a reward, false = achievement.
    function mintFungibleToken(
        uint256 _brandId,
        address _recipient,
        uint256 _tokenId,
        uint64 _amount,
        bool _isReward
    ) external onlyAdmin {
        address brandTokenAddress =
            _isReward ? brands[_brandId].rewardsAddress : brands[_brandId].achievementAddress;
        require(brandTokenAddress != address(0), "Brand does not exist");

        ITronicToken(brandTokenAddress).mintFungible(_recipient, _tokenId, _amount);
    }

    /// @notice Mints a new nonfungible ERC1155 token.
    /// @param _brandId The ID of the brand to mint the token for.
    /// @param _recipient The address to mint the token to.
    /// @param _typeId The typeID of the NFT to mint.
    /// @param _amount The amount of NFTs to mint.
    /// @param _isReward Whether or not the token is a reward, false = achievement.
    function mintNonFungibleToken(
        uint256 _brandId,
        address _recipient,
        uint256 _typeId,
        uint256 _amount,
        bool _isReward
    ) external onlyAdmin {
        address brandTokenAddress =
            _isReward ? brands[_brandId].rewardsAddress : brands[_brandId].achievementAddress;
        require(brandTokenAddress != address(0), "Brand does not exist");

        ITronicToken(brandTokenAddress).mintNFTs(_typeId, _recipient, _amount);
    }

    /// @notice Burns an achievement or reward token.
    /// @param _brandId The ID of the brand to burn the token for.
    /// @param _account The address of the account to burn the token from.
    /// @param _tokenId The tokenID (same as typeID for fungibles) of the token to burn.
    /// @param _amount The amount of the token to burn.
    /// @param _isReward Whether or not the token is a reward, false = achievement.
    function burnToken(
        uint256 _brandId,
        address _account,
        uint256 _tokenId,
        uint64 _amount,
        bool _isReward
    ) external onlyAdmin {
        address brandTokenAddress =
            _isReward ? brands[_brandId].rewardsAddress : brands[_brandId].achievementAddress;
        require(brandTokenAddress != address(0), "Token does not exist");

        ITronicToken(brandTokenAddress).burn(_account, _tokenId, _amount);
    }

    /// @notice Transfers Membership token from a brand loyalty TBA to a specified address
    /// @param _brandLoyaltyTbaAddress The address of the Brand Loyalty TBA
    /// @param _membershipId The membership ID of the membership token to be transferred
    /// @param _membershipTokenId The tokenID of the membership token to be transferred
    /// @param _to The address to transfer the membership to
    /// @dev This contract address must be granted permissions to transfer tokens from the Brand Loyalty token TBA
    /// @dev The membership token must be owned by the Brand Loyalty token TBA
    function transferMembershipFromBrandLoyaltyTBA(
        address _brandLoyaltyTbaAddress,
        uint256 _membershipId,
        uint256 _membershipTokenId,
        address _to
    ) external {
        // get membership address from membership id
        address membershipAddress = memberships[_membershipId].membershipAddress;
        require(membershipAddress != address(0), "Membership does not exist");

        // get BrandLoaylty TBA
        IERC6551Account brandLoyaltyTBA = IERC6551Account(payable(_brandLoyaltyTbaAddress));

        bytes4 isValidSigner = brandLoyaltyTBA.isValidSigner(msg.sender, "");

        //ensure caller is either admin or authorized to transfer tokens
        require(
            isValidSigner == bytes4(keccak256("isValidSigner(address,bytes)"))
                || _admins[msg.sender] || msg.sender == tronicAdmin,
            "Unauthorized caller"
        );

        // construct SafeTransferCall for membership ERC721
        bytes memory membershipTransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256)",
            _brandLoyaltyTbaAddress,
            _to,
            _membershipTokenId
        );

        // execute transfer via Brand Loyalty TBA
        brandLoyaltyTBA.execute(membershipAddress, 0, membershipTransferCall, 0);
    }

    /// @notice transfers tokens from a Brand Loyalty TBA to a specified address
    /// @param _brandId The ID of the brand
    /// @param _brandLoyaltyTbaAddress The address of the Brand Loyalty TBA
    /// @param _transferTokenId The ID of the token to transfer
    /// @param _to The address to transfer the tokens to
    /// @param _amount The amount of tokens to transfer
    /// @param _isReward Whether or not the token is a reward, false = achievement.
    /// @dev This contract address must be granted permissions to transfer tokens from the Brand Loyalty TBA
    /// @dev This function is only callable by the tronic admin or an authorized account
    function transferTokensFromBrandLoyaltyTBA(
        uint256 _brandId,
        address _brandLoyaltyTbaAddress,
        uint256 _transferTokenId,
        address _to,
        uint256 _amount,
        bool _isReward
    ) external {
        // get brand info from brand id
        BrandInfo memory brand = brands[_brandId];
        require(brand.brandLoyaltyAddress != address(0), "Brand does not exist");

        // get BrandLoaylty TBA
        IERC6551Account brandLoyaltyTBA = IERC6551Account(payable(_brandLoyaltyTbaAddress));

        bytes4 isValidSigner = brandLoyaltyTBA.isValidSigner(msg.sender, "");

        //ensure caller is tronic admin or authorized to transfer tokens
        require(
            isValidSigner == bytes4(keccak256("isValidSigner(address,bytes)"))
                || _admins[msg.sender] || msg.sender == tronicAdmin,
            "Unauthorized caller"
        );

        // construct SafeTransferCall for membership ERC1155
        bytes memory tokenTransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)",
            _brandLoyaltyTbaAddress,
            _to,
            _transferTokenId,
            _amount,
            ""
        );

        // // construct execute call for membership tbaAddress to execute nested tokenTransferCall
        // bytes memory executeCall = abi.encodeWithSignature(
        //     "execute(address,uint256,bytes,uint8)", _brandLoyaltyTbaAddress, 0, tokenTransferCall, 0
        // );

        // if isReward is true, use rewards address, else use achievement address
        if (_isReward) {
            require(brand.rewardsAddress != address(0), "Rewards address not set");
            brandLoyaltyTBA.execute(brand.rewardsAddress, 0, tokenTransferCall, 0);
        } else {
            require(brand.achievementAddress != address(0), "Achievement address not set");
            brandLoyaltyTBA.execute(brand.achievementAddress, 0, tokenTransferCall, 0);
        }
    }

    /// @notice Gets the address of the tokenbound account for a given brand loyalty token.
    /// @param _brandId The ID of the brand.
    /// @param _brandLoyaltyTokenId The ID of the brand loyalty token.
    /// @return brandLoyaltyTbaAddress The address of the tokenbound account.
    function getBrandLoyaltyTBA(uint256 _brandId, uint256 _brandLoyaltyTokenId)
        external
        view
        returns (address payable brandLoyaltyTbaAddress)
    {
        // get brand loyalty address from brand id
        address brandLoyaltyAddress = brands[_brandId].brandLoyaltyAddress;
        require(brandLoyaltyAddress != address(0), "Brand does not exist");

        // get brand loyalty TBA address from brand loyalty address
        brandLoyaltyTbaAddress =
            payable(ITronicBrandLoyalty(brandLoyaltyAddress).getTBAccount(_brandLoyaltyTokenId));
    }

    /// @notice Gets the brand ID for a given brand loyalty address.
    /// @param _brandLoyaltyAddress The address of the brand loyalty contract.
    /// @return brandId The ID of the brand.
    function getBrandIdFromBrandLoyaltyAddress(address _brandLoyaltyAddress)
        external
        view
        returns (uint256 brandId)
    {
        for (uint256 i = 1; i <= brandCounter; i++) {
            if (brands[i].brandLoyaltyAddress == _brandLoyaltyAddress) {
                return i;
            }
        }
    }

    /// @notice Gets the brand ID for a given membership ID.
    /// @param _membershipId The ID of the membership.
    /// @return brandId The ID of the brand.
    function getBrandIdFromMembershipId(uint256 _membershipId)
        external
        view
        returns (uint256 brandId)
    {
        return memberships[_membershipId].brandId;
    }

    /// @notice Sets the Tronic Loyalty contract address, callable only by the owner.
    /// @param newImplementation The address of the new Tronic Loyalty implementation.
    function setLoyaltyTokenImplementation(address newImplementation) external onlyOwner {
        tronicBrandLoyalty = ITronicBrandLoyalty(newImplementation);
    }

    /// @notice Sets the Membership implementation address, callable only by the owner.
    /// @param newImplementation The address of the new Tronic Membership implementation.
    function setMembershipImplementation(address newImplementation) external onlyOwner {
        tronicMembership = ITronicMembership(newImplementation);
    }

    /// @notice Sets the Achievement Token implementation address, callable only by the owner.
    /// @param newImplementation The address of the new Tronic Token implementation.
    function setAchievementImplementation(address newImplementation) external onlyOwner {
        tronicAchievement = ITronicToken(newImplementation);
    }

    /// @notice Sets the Rewards Token implementation address, callable only by the owner.
    /// @param newImplementation The address of the new Tronic Token implementation.
    function setRewardsImplementation(address newImplementation) external onlyOwner {
        tronicRewards = ITronicToken(newImplementation);
    }

    /// @notice Sets the account implementation address, callable only by the owner.
    /// @param newImplementation The address of the new account implementation.
    function setAccountImplementation(address payable newImplementation) external onlyOwner {
        tbaAccountImplementation = newImplementation;
    }

    /// @notice Sets the registry address, callable only by the owner.
    /// @param newRegistry The address of the new registry.
    function setRegistry(address newRegistry) external onlyOwner {
        registry = IERC6551Registry(newRegistry);
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
        return _admins[admin] || admin == tronicAdmin;
    }

    /// @notice Upgrades the contract to a new implementation.
    /// @param newImplementation The address of the new implementation.
    /// @dev This function is required for UUPSUpgradeable.
    /// @dev This function is only callable by the owner.
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
