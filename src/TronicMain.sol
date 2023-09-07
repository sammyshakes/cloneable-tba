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

    event MembershipAdded(
        uint256 indexed membershipId,
        address indexed membershipAddress,
        address indexed tokenAddress
    );

    event MembershipRemoved(uint256 indexed membershipId);

    address public owner;
    address public tronicAdmin;
    address payable public tbaAccountImplementation;

    // Deployments
    IERC6551Registry public registry;
    TronicMembership public tronicERC721;
    TronicToken public tronicERC1155;

    uint256 public membershipCounter;
    mapping(uint256 => MembershipInfo) public memberships;
    mapping(address => bool) private _admins;

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
        tronicERC721 = TronicMembership(_tronicMembership);
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
    /// @return membershipAddress The address of the deployed membership ERC721 contract.
    /// @return tokenAddress The address of the deployed token ERC1155 contract.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    function deployMembership(
        string memory membershipName,
        string memory membershipSymbol,
        string memory membershipBaseURI,
        uint256 maxMintable
    ) external onlyAdmin returns (address membershipAddress, address tokenAddress) {
        // Question: Will we know the TierIds beforehand?
        // Deploy the membership's contracts
        membershipAddress =
            _deployMembership(membershipName, membershipSymbol, membershipBaseURI, maxMintable);
        tokenAddress = _deployToken();

        // Assign membership id and associate the deployed contracts with the membership
        memberships[membershipCounter] = MembershipInfo({
            membershipAddress: membershipAddress,
            tokenAddress: tokenAddress,
            membershipName: membershipName
        });

        emit MembershipAdded(membershipCounter++, membershipAddress, tokenAddress);
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
        uint256 maxSupply
    ) private returns (address membershipAddress) {
        membershipAddress = Clones.clone(address(tronicERC721));
        TronicMembership(membershipAddress).initialize(
            tbaAccountImplementation, address(registry), name, symbol, uri, maxSupply, tronicAdmin
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

    /// @notice Mints a new ERC721 token.
    /// @param _recipient The address to mint the token to.
    /// @param _membershipId The ID of the membership to mint the token for.
    /// @return The address of the newly created token account.
    function mintMembership(address _recipient, uint256 _membershipId)
        external
        onlyAdmin
        returns (address payable)
    {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");
        return TronicMembership(membership.membershipAddress).mint(_recipient);
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
    function transferTokensFromMembershipTBA(
        uint256 _tronicTokenId,
        uint256 _membershipId,
        uint256 _membershipTokenId,
        address _to,
        uint256 _transferTokenId,
        uint256 _amount
    ) external {
        address payable tronicTbaAddress = payable(tronicERC721.getTBAccount(_tronicTokenId));
        IERC6551Account tronicTBA = IERC6551Account(tronicTbaAddress);
        //ensure caller is either admin or authorized to transfer tokens
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

    /// @notice Sets the ERC721 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC721 implementation.
    function setERC721Implementation(address newImplementation) external onlyOwner {
        tronicERC721 = TronicMembership(newImplementation);
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
