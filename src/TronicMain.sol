// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TronicToken.sol";
import "./TronicMembership.sol";
import "./interfaces/IERC6551Account.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract TronicMain {
    struct MembershipInfo {
        address membershipAddress;
        address tokenAddress;
        string membershipName;
    }

    enum TokenType {
        ERC1155,
        ERC721
    }

    event MembershipMinted(
        address indexed membershipAddress,
        address indexed recipientAddress,
        uint256 indexed tokenId
    );

    event TierAssigned(
        address indexed membershipAddress,
        uint256 indexed tokenId,
        uint256 indexed tierIndex
    );

    event MembershipAdded(
        uint256 indexed membershipId,
        address indexed membershipAddress,
        address indexed tokenAddress
    );

    event FungibleTokenTypeCreated(
        uint256 indexed tokenId
    );

    event MembershipRemoved(uint256 indexed membershipId);

    address public owner;
    address public tronicAdmin;
    address payable public tbaAccountImplementation;

    uint8 public maxTiersPerMembership = 10;

    uint256 public membershipCounter;
    mapping(uint256 => MembershipInfo) private memberships;
    mapping(address => bool) private _admins;

    // Deployments
    IERC6551Registry public registry;
    TronicMembership public tronicMembership;
    TronicToken public tronicERC1155;

    /// @notice Constructs the TronicMain contract.
    /// @param _admin The address of the Tronic admin.
    /// @param _tronicMembership The address of the Tronic Membership contract (ERC721 implementation).
    /// @param _tronicToken The address of the Tronic Token contract (ERC1155 implementation).
    /// @param _registry The address of the registry contract.
    /// @param _tbaImplementation The address of the tokenbound account implementation.
    constructor(
        address _admin,
        address _tronicMembership,
        address _tronicToken,
        address _registry,
        address _tbaImplementation
    ) {
        owner = msg.sender;
        tronicAdmin = _admin;
        tronicERC1155 = TronicToken(_tronicToken);
        tronicMembership = TronicMembership(_tronicMembership);
        registry = IERC6551Registry(_registry);
        tbaAccountImplementation = payable(_tbaImplementation);
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
    function getMembershipInfo(uint256 membershipId)
        external
        view
        returns (MembershipInfo memory)
    {
        return memberships[membershipId];
    }

    /// @notice Deploys a new membership's contracts.
    /// @param membershipName The membership name for the ERC721 token.
    /// @param membershipSymbol The membership symbol for the ERC721 token.
    /// @param membershipBaseURI The base URI for the membership ERC721 token.
    /// @param maxMintable The maximum number of memberships that can be minted.
    /// @return memberId The ID of the newly created membership.
    /// @return membershipAddress The address of the deployed membership ERC721 contract.
    /// @return tokenAddress The address of the deployed token ERC1155 contract.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    function deployMembership(
        string memory membershipName,
        string memory membershipSymbol,
        string memory membershipBaseURI,
        uint256 maxMintable,
        bool isElastic,
        bool isBound,
        string[] memory tierIds,
        uint128[] memory durations,
        bool[] memory isOpens
    )
        external
        onlyAdmin
        returns (uint256 memberId, address membershipAddress, address tokenAddress)
    {
        require(
            tierIds.length == durations.length && tierIds.length == isOpens.length,
            "Input arrays must have the same length"
        );

        memberId = membershipCounter++;

        // Deploy the membership's contracts
        membershipAddress = _deployMembership(
            membershipName, membershipSymbol, membershipBaseURI, maxMintable, isElastic, isBound
        );
        tokenAddress = _deployToken();

        // Assign membership id and associate the deployed contracts with the membership
        memberships[memberId] = MembershipInfo({
            membershipAddress: membershipAddress,
            tokenAddress: tokenAddress,
            membershipName: membershipName
        });

        // Deploy tiers
        if (tierIds.length > 0) {
            tronicMembership = TronicMembership(membershipAddress);
            tronicMembership.createMembershipTiers(tierIds, durations, isOpens);
        }

        emit MembershipAdded(memberId, membershipAddress, tokenAddress);
    }

    /// @notice Clones the Tronic Membership (ERC721) implementation and initializes it.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param uri The URI for the cloned contract.
    /// @return membershipAddress The address of the newly cloned Membership contract.
    function _deployMembership(
        string memory name,
        string memory symbol,
        string memory uri,
        uint256 maxSupply,
        bool isElastic,
        bool isBound
    ) private returns (address membershipAddress) {
        membershipAddress = Clones.clone(address(tronicMembership));
        TronicMembership(membershipAddress).initialize(
            tbaAccountImplementation,
            address(registry),
            name,
            symbol,
            uri,
            maxTiersPerMembership,
            maxSupply,
            isElastic,
            isBound,
            tronicAdmin
        );
    }

    /// @notice Clones the ERC1155 implementation and initializes it.
    /// @return tokenAddress The address of the newly cloned ERC1155 contract.
    function _deployToken() private returns (address tokenAddress) {
        tokenAddress = Clones.clone(address(tronicERC1155));
        TronicToken(tokenAddress).initialize(tronicAdmin);
    }

    /// @notice Removes a membership from the contract.
    /// @param _membershipId The ID of the membership to remove.
    function removeMembership(uint256 _membershipId) external onlyAdmin {
        delete memberships[_membershipId];
    }

    /// @notice Creates a new ERC1155 fungible token type for a membership.
    /// @param maxSupply The maximum supply of the token type.
    /// @param uri The URI for the token type.
    /// @param membershipId The ID of the membership to create the token type for.
    /// @return typeId The ID of the newly created token type.
    function createFungibleTokenType(uint256 maxSupply, string memory uri, uint256 membershipId)
        external
        onlyAdmin
        returns (uint256 typeId)
    {
        MembershipInfo memory membership = memberships[membershipId];
        require(membership.tokenAddress != address(0), "Membership does not exist");
        typeId = TronicToken(membership.tokenAddress).createFungibleType(uint64(maxSupply), uri);

        emit FungibleTokenTypeCreated(typeId);
    }

    /// @notice Creates a new ERC1155 non-fungible token type for a membership.
    /// @param baseUri The URI for the token type.
    /// @param maxMintable The maximum number of tokens that can be minted.
    /// @param membershipId The ID of the membership to create the token type for.
    /// @return nftTypeID The ID of the newly created token type.
    function createNonFungibleTokenType(
        string memory baseUri,
        uint64 maxMintable,
        uint256 membershipId
    ) external onlyAdmin returns (uint256 nftTypeID) {
        MembershipInfo memory membership = memberships[membershipId];
        require(membership.tokenAddress != address(0), "Membership does not exist");
        nftTypeID = TronicToken(membership.tokenAddress).createNFTType(baseUri, maxMintable);
    }

    /// @notice Mints a new ERC721 token for a specified membership.
    /// @param _recipient The address to mint the token to.
    /// @param _membershipId The ID of the membership to mint the token for.
    /// @return The address of the newly created token account.
    function mintMembership(address _recipient, uint256 _membershipId, uint8 _tierIndex)
        external
        onlyAdmin
        returns (address payable, uint256)
    {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");
        (address payable recipientAddress, uint256 tokenId) = 
            TronicMembership(membership.membershipAddress).mint(_recipient);

        emit MembershipMinted(membership.membershipAddress, recipientAddress, tokenId);

        if (_tierIndex != 0) {
            _assignMembershipTier(_membershipId, _tierIndex, tokenId);
        }

        return (recipientAddress, tokenId);
    }

    /// @notice Assigns a membership tier details of a specific token.
    /// @param _tokenId The ID of the token whose membership details are to be set.
    /// @param _tierIndex The index of the membership tier to associate with the token.
    /// @dev This function can only be called by an admin.
    /// @dev The tier must exist.
    /// @dev The token must exist.
    function _assignMembershipTier(uint256 _membershipId, uint8 _tierIndex, uint256 _tokenId)
        internal
    {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");

        TronicMembership(membership.membershipAddress).setTokenMembership(_tokenId, _tierIndex);

        emit TierAssigned(membership.membershipAddress, _tokenId, _tierIndex);
    }

    /// @notice Retrieves tier index of a given tier ID.
    /// @param tierId The ID of the tier.
    /// @return The index of the tier.
    /// @dev Returns 0 if the tier does not exist.
    function getTierIndexByTierId(uint256 _membershipId, string memory tierId) external view returns (uint8) {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");

        return TronicMembership(membership.membershipAddress).getTierIndexByTierId(tierId);
    }

    /// @notice Mints a fungible ERC1155 token.
    /// @param _membershipId The ID of the membership to mint the token for.
    /// @param _recipient The address to mint the token to.
    /// @param _tokenId The tokenID (same as typeID for fungibles) of the token to mint.
    /// @param _amount The amount of the token to mint.
    function mintFungibleToken(
        uint256 _membershipId,
        address _recipient,
        uint256 _tokenId,
        uint64 _amount
    ) external onlyAdmin {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.tokenAddress != address(0), "Membership does not exist");
        TronicToken(membership.tokenAddress).mintFungible(_recipient, _tokenId, _amount);
    }

    /// @notice Mints a new nonfungible ERC1155 token.
    /// @param _membershipId The ID of the membership to mint the token for.
    /// @param _recipient The address to mint the token to.
    /// @param _typeId The typeID of the token to mint.
    /// @param _amount The amount of the token to mint.
    function mintNonFungibleToken(
        uint256 _membershipId,
        address _recipient,
        uint256 _typeId,
        uint256 _amount
    ) external onlyAdmin {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.tokenAddress != address(0), "Membership does not exist");
        TronicToken(membership.tokenAddress).mintNFTs(_typeId, _recipient, _amount);
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
    function batchProcess(
        uint256[] memory _membershipIds,
        address[][] memory _recipients,
        uint256[][][][] memory _tokenTypeIDs,
        uint256[][][][] memory _amounts,
        TokenType[][][] memory _contractTypes
    ) external onlyAdmin {
        require(
            _membershipIds.length == _tokenTypeIDs.length && _tokenTypeIDs.length == _amounts.length
                && _amounts.length == _recipients.length && _recipients.length == _contractTypes.length,
            "Outer arrays must have the same length"
        );

        // i = membershipId, j = recipient, k = contracttype
        // Loop through each membership
        for (uint256 i = 0; i < _membershipIds.length; i++) {
            MembershipInfo memory membership = memberships[_membershipIds[i]];

            for (uint256 j = 0; j < _recipients[i].length; j++) {
                address recipient = _recipients[i][j];

                for (uint256 k = 0; k < _contractTypes[i][j].length; k++) {
                    if (_contractTypes[i][j][k] == TokenType.ERC1155) {
                        TronicToken(membership.tokenAddress).mintBatch(
                            recipient, _tokenTypeIDs[i][j][k], _amounts[i][j][k], ""
                        );
                    } else if (_contractTypes[i][j][k] == TokenType.ERC721) {
                        TronicMembership(membership.membershipAddress).mint(recipient);
                    }
                }
            }
        }
    }

    /// @notice transfers tokens from a membership TBA to a specified address
    /// @param _tronicTokenId The ID of the tronic token that owns the Tronic TBA
    /// @param _membershipId The ID of the membership that issued the membership TBA
    /// @param _membershipTokenId The ID of the membership TBA
    /// @param _to The address to transfer the tokens to
    /// @param _transferTokenId The ID of the token to transfer
    /// @param _amount The amount of tokens to transfer
    /// @dev This contract address must be granted permissions to transfer tokens from the membership TBA
    /// @dev The membership TBA must be owned by the Tronic tokenId TBA
    /// @dev This function is only callable by the tronic admin or an authorized account
    function transferTokensFromMembershipTBA(
        uint256 _tronicTokenId,
        uint256 _membershipId,
        uint256 _membershipTokenId,
        address _to,
        uint256 _transferTokenId,
        uint256 _amount
    ) external {
        // get Tronic TBA address for tronic token id
        address payable tronicTbaAddress = payable(tronicMembership.getTBAccount(_tronicTokenId));
        IERC6551Account tronicTBA = IERC6551Account(tronicTbaAddress);

        //ensure caller is tronic admin or authorized to transfer tokens
        require(
            tronicTBA.isAuthorized(msg.sender) || _admins[msg.sender] || msg.sender == tronicAdmin,
            "Unauthorized caller"
        );

        // get membership info
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.tokenAddress != address(0), "Membership does not exist");

        // get Membership TBA address
        address membershipTbaAddress =
            TronicMembership(membership.membershipAddress).getTBAccount(_membershipTokenId);

        // construct SafeTransferCall for membership ERC1155
        bytes memory tokenTransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)",
            membershipTbaAddress,
            _to,
            _transferTokenId,
            _amount,
            ""
        );

        // construct execute call for membership tbaAddress to execute tokenTransferCall
        bytes memory executeCall = abi.encodeWithSignature(
            "executeCall(address,uint256,bytes)", membership.tokenAddress, 0, tokenTransferCall
        );

        tronicTBA.executeCall(membershipTbaAddress, 0, executeCall);
    }

    /// @notice transfers tokens from a tronic TBA to a specified address
    /// @param _tronicTokenId The ID of the tronic token that owns the Tronic TBA
    /// @param _transferTokenId The ID of the token to transfer
    /// @param _amount The amount of tokens to transfer
    /// @param _to The address to transfer the tokens to
    /// @dev This contract address must be granted permissions to transfer tokens from the Tronic token TBA
    /// @dev The tronic TBA must be owned by the Tronic tokenId TBA
    /// @dev This function is only callable by the tronic admin or an authorized account
    function transferTokensFromTronicTBA(
        uint256 _tronicTokenId,
        uint256 _transferTokenId,
        uint256 _amount,
        address _to
    ) external {
        // get Tronic TBA address for tronic token id
        address payable tronicTbaAddress = payable(tronicMembership.getTBAccount(_tronicTokenId));
        IERC6551Account tronicTBA = IERC6551Account(tronicTbaAddress);

        //ensure caller is tronic admin or authorized to transfer tokens
        require(
            tronicTBA.isAuthorized(msg.sender) || _admins[msg.sender] || msg.sender == tronicAdmin,
            "Unauthorized caller"
        );

        // construct SafeTransferCall for tronic ERC1155
        bytes memory tokenTransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)",
            tronicTbaAddress,
            _to,
            _transferTokenId,
            _amount,
            ""
        );

        tronicTBA.executeCall(address(tronicERC1155), 0, tokenTransferCall);
    }

    /// @notice transfers membership from a tronic TBA to a specified address
    /// @param _tronicTokenId The ID of the tronic token that owns the Tronic TBA
    /// @param _membershipId The ID of the membership that issued the membership TBA
    /// @param _membershipTokenId The ID of the membership TBA
    /// @param _to The address to transfer the membership to
    /// @dev This contract address must be granted permissions to transfer tokens from the Tronic token TBA
    /// @dev The membership token TBA must be owned by the Tronic token TBA
    function transferMembershipFromTronicTBA(
        uint256 _tronicTokenId,
        uint256 _membershipId,
        uint256 _membershipTokenId,
        address _to
    ) external {
        // get Tronic TBA address for tronic token id
        address payable tronicTbaAddress = payable(tronicMembership.getTBAccount(_tronicTokenId));
        IERC6551Account tronicTBA = IERC6551Account(tronicTbaAddress);
        //ensure caller is either admin or authorized to transfer tokens
        require(
            tronicTBA.isAuthorized(msg.sender) || _admins[msg.sender] || msg.sender == tronicAdmin,
            "Unauthorized caller"
        );

        // get membership contract address
        address membershipAddress = memberships[_membershipId].membershipAddress;
        require(membershipAddress != address(0), "Membership does not exist");

        // construct and execute SafeTransferCall for membership ERC721
        bytes memory membershipTransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256)", tronicTbaAddress, _to, _membershipTokenId
        );

        tronicTBA.executeCall(membershipAddress, 0, membershipTransferCall);
    }

    /// @notice Sets the ERC721 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC721 implementation.
    function setERC721Implementation(address newImplementation) external onlyOwner {
        tronicMembership = TronicMembership(newImplementation);
    }

    /// @notice Sets the ERC1155 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC1155 implementation.
    function setERC1155Implementation(address newImplementation) external onlyOwner {
        tronicERC1155 = TronicToken(newImplementation);
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
}
