// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC6551Account.sol";
import "./interfaces/IERC6551Registry.sol";
import "./interfaces/ITronicMembership.sol";
import "./interfaces/ITronicBrandLoyalty.sol";
import "./interfaces/ITronicToken.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title TronicMain
/// @notice This contract is the main contract for the Tronic ecosystem.
/// @dev This contract is upgradeable using the UUPS proxy pattern.
/// @dev This contract is the entry point for all Tronic transactions.
contract TronicMain is Initializable, UUPSUpgradeable {
    /// @notice The struct for membership information.
    /// @param brandName The name of the brand.
    /// @param brandLoyaltyAddress The address of the brand loyalty ERC721 contract.
    /// @param tokenAddress The address of the token ERC1155 contract.
    /// @param memberships The list of memberships for the brand.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    struct BrandInfo {
        string brandName;
        address brandLoyaltyAddress;
        address tokenAddress;
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
    /// @param tokenAddress The address of the token ERC1155 contract.
    event BrandAdded(
        uint256 indexed brandId,
        string brandName,
        address indexed brandLoyaltyAddress,
        address indexed tokenAddress
    );

    /// @notice The event emitted when a membership is removed.
    /// @param membershipId The ID of the membership.
    event MembershipRemoved(uint256 indexed membershipId);

    /// @notice The event emitted when a fungible token type is created.
    /// @param brandId The ID of the brand.
    /// @param tokenId The ID of the newly created token type.
    event FungibleTokenTypeCreated(uint256 indexed brandId, uint256 indexed tokenId);

    /// @notice The event emitted when a non-fungible token type is created.
    /// @param brandId The ID of the brand.
    /// @param tokenId The ID of the newly created token type.
    /// @param maxMintable The maximum number of tokens that can be minted.
    /// @param uri The URI of the token type.
    event NonFungibleTokenTypeCreated(
        uint256 indexed brandId, uint256 indexed tokenId, uint256 maxMintable, string uri
    );

    address public owner;
    address public tronicAdmin;
    address payable public tbaAccountImplementation;
    uint8 public maxTiersPerMembership;

    uint64 public nftTypeStartId;

    uint256 public brandCounter;
    mapping(uint256 => BrandInfo) private brands;

    uint256 public membershipCounter;
    mapping(uint256 => MembershipInfo) private memberships;
    mapping(address => bool) private _admins;

    // Deployments
    IERC6551Registry public registry;
    ITronicBrandLoyalty public tronicBrandLoyalty;
    ITronicMembership public tronicMembership;
    ITronicToken public tronicToken;

    //disable initializer for upgradeability in the constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the TronicMain contract.
    /// @param _admin The address of the Tronic admin.
    /// @param _brandLoyalty The address of the Tronic Brand Loyalty contract (ERC721 implementation).
    /// @param _tronicMembership The address of the Tronic Membership contract (ERC1155 implementation).
    /// @param _tronicToken The address of the Tronic Token contract (ERC1155 implementation).
    /// @param _registry The address of the registry contract.
    /// @param _tbaImplementation The address of the tokenbound account implementation.
    /// @param _maxTiersPerMembership The maximum number of tiers per membership.
    /// @param _nftTypeStartId The starting ID for non-fungible token types.
    function initialize(
        address _admin,
        address _brandLoyalty,
        address _tronicMembership,
        address _tronicToken,
        address _registry,
        address _tbaImplementation,
        uint8 _maxTiersPerMembership,
        uint64 _nftTypeStartId
    ) public initializer {
        owner = msg.sender;
        tronicAdmin = _admin;
        tronicBrandLoyalty = ITronicBrandLoyalty(_brandLoyalty);
        tronicToken = ITronicToken(_tronicToken);
        tronicMembership = ITronicMembership(_tronicMembership);
        registry = IERC6551Registry(_registry);
        tbaAccountImplementation = payable(_tbaImplementation);
        maxTiersPerMembership = _maxTiersPerMembership;
        nftTypeStartId = _nftTypeStartId;
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

    /// @notice Deploys a new Brand's Loyalty and Achievement Token contracts.
    /// @param brandName The name for the Brand Loyalty token.
    /// @param brandSymbol The symbol for the Brand Loyalty token.
    /// @param brandBaseURI The base URI for the Brand Loyalty token.
    /// @param isBound Whether or not the brand loyalty token is bound.
    /// @return brandId The ID of the newly created brand.
    /// @return brandLoyaltyAddress The address of the deployed brand loyalty Brand Loyalty contract.
    /// @return tokenAddress The address of the deployed token ERC1155 contract.
    /// @dev The brand ID is the index of the brand in the brands mapping.
    function deployBrand(
        string calldata brandName,
        string calldata brandSymbol,
        string calldata brandBaseURI,
        bool isBound
    )
        external
        onlyAdmin
        returns (uint256 brandId, address brandLoyaltyAddress, address tokenAddress)
    {
        brandId = ++brandCounter;
        // Deploy the Brand loyalty contract
        brandLoyaltyAddress = _deployBrandLoyalty(brandName, brandSymbol, brandBaseURI, isBound);

        //deploy Achievement Token contract
        tokenAddress = _deployToken();

        // Assign brand id and associate the loyalty contracts with the brand
        brands[brandId] = BrandInfo({
            brandLoyaltyAddress: brandLoyaltyAddress,
            brandName: brandName,
            tokenAddress: tokenAddress,
            membershipIds: new uint256[](0)
        });

        emit BrandAdded(brandId, brandName, brandLoyaltyAddress, tokenAddress);
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
    /// @return tokenAddress The address of the newly cloned ERC1155 contract.
    function _deployToken() private returns (address tokenAddress) {
        tokenAddress = Clones.clone(address(tronicToken));
        ITronicToken(tokenAddress).initialize(tronicAdmin, nftTypeStartId);
    }

    /// @notice Removes a membership from the contract.
    /// @param _membershipId The ID of the membership to remove.
    function removeMembership(uint256 _membershipId) external onlyAdmin {
        delete memberships[_membershipId];
    }

    /// @notice Creates a new ERC1155 fungible token type for a membership.
    /// @param brandId The ID of the brand to create the token type for.
    /// @param maxSupply The maximum supply of the token type.
    /// @param uri The URI for the token type.
    /// @return typeId The ID of the newly created token type.
    function createFungibleTokenType(uint256 brandId, uint256 maxSupply, string memory uri)
        external
        onlyAdmin
        returns (uint256 typeId)
    {
        // get token address from brand info
        address brandTokenAddress = brands[brandId].tokenAddress;
        require(brandTokenAddress != address(0), "Brand does not exist");

        typeId = ITronicToken(brandTokenAddress).createFungibleType(uint64(maxSupply), uri);

        emit FungibleTokenTypeCreated(brandId, typeId);
    }

    /// @notice Creates a new ERC1155 non-fungible token type for a membership.
    /// @param brandId The ID of the brand to create the token type for.
    /// @param baseUri The URI for the token type.
    /// @param maxMintable The maximum number of tokens that can be minted.
    /// @return nftTypeID The ID of the newly created token type.
    function createNonFungibleTokenType(uint256 brandId, string memory baseUri, uint64 maxMintable)
        external
        onlyAdmin
        returns (uint256 nftTypeID)
    {
        // get token address from brand info
        address brandTokenAddress = brands[brandId].tokenAddress;
        require(brandTokenAddress != address(0), "Brand does not exist");

        nftTypeID = ITronicToken(brandTokenAddress).createNFTType(baseUri, maxMintable);

        emit NonFungibleTokenTypeCreated(brandId, nftTypeID, maxMintable, baseUri);
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

    /// @notice Assigns a membership tier details of a specific token.
    /// @param _tokenId The ID of the token whose membership details are to be set.
    /// @param _tierIndex The index of the membership tier to associate with the token.
    /// @dev This function can only be called by an admin.
    /// @dev The tier must exist.
    /// @dev The token must exist.
    function _assignMembershipTier(address _membershipAddress, uint8 _tierIndex, uint256 _tokenId)
        private
    {
        ITronicMembership(_membershipAddress).setMembershipToken(_tokenId, _tierIndex);

        emit TierAssigned(_membershipAddress, _tokenId, _tierIndex);
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
    function mintFungibleToken(
        uint256 _brandId,
        address _recipient,
        uint256 _tokenId,
        uint64 _amount
    ) external onlyAdmin {
        BrandInfo memory brand = brands[_brandId];
        require(brand.tokenAddress != address(0), "Brand does not exist");
        ITronicToken(brand.tokenAddress).mintFungible(_recipient, _tokenId, _amount);
    }

    /// @notice Mints a new nonfungible ERC1155 token.
    /// @param _brandId The ID of the brand to mint the token for.
    /// @param _recipient The address to mint the token to.
    /// @param _typeId The typeID of the NFT to mint.
    /// @param _amount The amount of NFTs to mint.
    function mintNonFungibleToken(
        uint256 _brandId,
        address _recipient,
        uint256 _typeId,
        uint256 _amount
    ) external onlyAdmin {
        BrandInfo memory brand = brands[_brandId];
        require(brand.tokenAddress != address(0), "Brand does not exist");
        ITronicToken(brand.tokenAddress).mintNFTs(_typeId, _recipient, _amount);
    }

    /// @notice Processes multiple minting operations for both ERC1155 and ERC721 tokens on behalf of memberships.
    /// @param _membershipIds   Array of membership IDs corresponding to each minting operation.
    /// @param _recipients   2D array of recipient addresses for each minting operation.
    /// @param _tokenTypeIDs     4D array of token TypeIDs to mint for each membership.
    ///                      For ERC1155, it could be multiple IDs, and for ERC721, it should contain a single ID.
    /// @param _amounts      4D array of token amounts to mint for each membership.
    ///                      For ERC1155, it represents the quantities of each token ID, and for ERC721, it should be either [1] (to mint) or [0] (to skip).
    /// @param _contractTypes   3D array specifying the type of each token contract (either ERC1155 or ERC721) to determine the minting logic.
    /// @dev Requires that all input arrays have matching lengths.
    ///      For ERC721 minting, the inner arrays of _tokenTypes and _amounts should have a length of 1.
    /// @dev array indexes: _tokenTypeIDs[membershipId][recipient][contractType][tokenTypeIDs]
    /// @dev array indexes: _amounts[membershipId][recipient][contractType][amounts]
    // function batchProcess(
    //     uint256[] memory _membershipIds,
    //     address[][] memory _recipients,
    //     uint256[][][][] memory _tokenTypeIDs,
    //     uint256[][][][] memory _amounts,
    //     TokenType[][][] memory _contractTypes
    // ) external onlyAdmin {
    //     require(
    //         _membershipIds.length == _tokenTypeIDs.length && _tokenTypeIDs.length == _amounts.length
    //             && _amounts.length == _recipients.length && _recipients.length == _contractTypes.length,
    //         "Outer arrays must have the same length"
    //     );

    //     // i = membershipId, j = recipient, k = contracttype
    //     // Loop through each membership
    //     for (uint256 i = 0; i < _membershipIds.length; i++) {
    //         MembershipInfo memory membership = memberships[_membershipIds[i]];

    //         for (uint256 j = 0; j < _recipients[i].length; j++) {
    //             address recipient = _recipients[i][j];

    //             for (uint256 k = 0; k < _contractTypes[i][j].length; k++) {
    //                 if (_contractTypes[i][j][k] == TokenType.ERC1155) {
    //                     ITronicToken(membership.tokenAddress).mintBatch(
    //                         recipient, _tokenTypeIDs[i][j][k], _amounts[i][j][k], ""
    //                     );
    //                 } else {
    //                     ITronicMembership(membership.membershipAddress).mint(recipient, 0);
    //                 }
    //             }
    //         }
    //     }
    // }

    /// @notice transfers Membership token from a brand loyalty TBA to a specified address
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

        //ensure caller is either admin or authorized to transfer tokens
        require(
            brandLoyaltyTBA.isAuthorized(msg.sender) || _admins[msg.sender]
                || msg.sender == tronicAdmin,
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
        brandLoyaltyTBA.executeCall(membershipAddress, 0, membershipTransferCall);
    }

    /// @notice transfers Brand Loyalty tokens from a Brand Loyalty TBA to a specified address
    /// @param _brandId The ID of the brand
    /// @param _brandLoyaltyTbaAddress The address of the Brand Loyalty TBA
    /// @param _transferTokenId The ID of the token to transfer
    /// @param _to The address to transfer the tokens to
    /// @param _amount The amount of tokens to transfer
    /// @dev This contract address must be granted permissions to transfer tokens from the Brand Loyalty TBA
    /// @dev This function is only callable by the tronic admin or an authorized account
    function transferTokensFromBrandLoyaltyTBA(
        uint256 _brandId,
        address _brandLoyaltyTbaAddress,
        uint256 _transferTokenId,
        address _to,
        uint256 _amount
    ) external {
        // get brand loyalty address from brand id
        address brandTokenAddress = brands[_brandId].tokenAddress;
        require(brandTokenAddress != address(0), "Brand does not exist");

        // get BrandLoaylty TBA
        IERC6551Account brandLoyaltyTBA = IERC6551Account(payable(_brandLoyaltyTbaAddress));

        //ensure caller is tronic admin or authorized to transfer tokens
        require(
            brandLoyaltyTBA.isAuthorized(msg.sender) || _admins[msg.sender]
                || msg.sender == tronicAdmin,
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

        // // construct execute call for membership tbaAddress to execute tokenTransferCall
        // bytes memory executeCall = abi.encodeWithSignature(
        //     "executeCall(address,uint256,bytes)", _brandLoyaltyTbaAddress, 0, tokenTransferCall
        // );

        brandLoyaltyTBA.executeCall(brandTokenAddress, 0, tokenTransferCall);
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
    function setTokenImplementation(address newImplementation) external onlyOwner {
        tronicToken = ITronicToken(newImplementation);
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
