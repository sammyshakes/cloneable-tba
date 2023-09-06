// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicLoyalty.sol";
import "./TronicMembership.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract TronicMain {
    struct MembershipInfo {
        address membershipAddress;
        address loyaltyAddress;
        string membershipName;
    }

    enum TokenType {
        ERC1155,
        ERC721
    }

    event MembershipAdded(
        uint256 indexed membershipId,
        address indexed membershipAddress,
        address indexed loyaltyAddress,
        string membershipName,
        string membershipSymbol
    );

    address public owner;
    address public tronicAdmin;
    address payable public tbaAccountImplementation;

    // Deployments
    IERC6551Registry public registry;
    TronicMembership public tronicERC721;
    TronicLoyalty public tronicERC1155;

    uint256 public membershipCounter;
    mapping(uint256 => MembershipInfo) public memberships;
    mapping(address => bool) private _admins;

    /// @notice Constructs the CloneFactory contract.
    /// @param _admin The address of the Tronic admin.
    /// @param _tronicMembership The address of the Tronic Membership contract (ERC721 implementation).
    /// @param _tronicLoyalty The address of the Tronic Loyalty contract (ERC1155 implementation).
    /// @param _registry The address of the registry contract.
    /// @param _tbaAccountImplementation The address of the tokenbound account implementation.
    constructor(
        address _admin,
        address _tronicMembership,
        address _tronicLoyalty,
        address _registry,
        address _tbaAccountImplementation
    ) {
        owner = msg.sender;
        tronicAdmin = _admin;
        tronicERC1155 = TronicLoyalty(_tronicLoyalty);
        tronicERC721 = TronicMembership(_tronicMembership);
        registry = IERC6551Registry(_registry);
        tbaAccountImplementation = payable(_tbaAccountImplementation);
    }

    // Modifiers for access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender] || msg.sender == tronicAdmin, "Only admin");
        _;
    }

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
    /// @return loyaltyAddress The address of the deployed loyalty ERC1155 contract.
    /// @dev The membership ID is the index of the membership in the memberships mapping.
    function deployMembership(
        string memory membershipName,
        string memory membershipSymbol,
        string memory membershipBaseURI,
        uint256 maxMintable
    ) external onlyAdmin returns (address membershipAddress, address loyaltyAddress) {
        // Question: Will we know the TierIds beforehand?
        // Deploy the membership's contracts
        membershipAddress =
            _deployMembership(membershipName, membershipSymbol, membershipBaseURI, maxMintable);
        loyaltyAddress = _deployLoyalty();

        // Assign membership id and associate the deployed contracts with the membership
        memberships[membershipCounter] = MembershipInfo({
            membershipAddress: membershipAddress,
            loyaltyAddress: loyaltyAddress,
            membershipName: membershipName
        });

        emit MembershipAdded(
            membershipCounter++, membershipAddress, loyaltyAddress, membershipName, membershipSymbol
        );
    }

    /// @notice Clones the ERC721 implementation and initializes it.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param uri The URI for the cloned contract.
    /// @return erc721CloneAddress The address of the newly cloned ERC721 contract.
    function _deployMembership(
        string memory name,
        string memory symbol,
        string memory uri,
        uint256 maxSupply
    ) private returns (address erc721CloneAddress) {
        erc721CloneAddress = Clones.clone(address(tronicERC721));
        TronicMembership erc721Clone = TronicMembership(erc721CloneAddress);
        erc721Clone.initialize(
            tbaAccountImplementation, address(registry), name, symbol, uri, maxSupply, tronicAdmin
        );
    }

    /// @notice Clones the ERC1155 implementation and initializes it.
    /// @return erc1155cloneAddress The address of the newly cloned ERC1155 contract.
    function _deployLoyalty() private returns (address erc1155cloneAddress) {
        erc1155cloneAddress = Clones.clone(address(tronicERC1155));
        TronicLoyalty erc1155clone = TronicLoyalty(erc1155cloneAddress);
        erc1155clone.initialize(tronicAdmin);
    }

    // Function to remove a membership's contracts (considering the challenges of removing from a mapping)
    function removeMembership(uint256 _membershipId) external onlyAdmin {
        delete memberships[_membershipId];
    }

    /// @notice Creates a new ERC1155 fungible token type for a membership.
    /// @param maxSupply The maximum supply of the token type.
    /// @param uri The URI for the token type.
    /// @param membershipId The ID of the membership to create the token type for.
    /// @return The ID of the newly created token type.
    function createFungibleTokenType(uint256 maxSupply, string memory uri, uint256 membershipId)
        external
        onlyAdmin
        returns (uint256)
    {
        MembershipInfo memory membership = memberships[membershipId];
        require(membership.loyaltyAddress != address(0), "Membership does not exist");
        return TronicLoyalty(membership.loyaltyAddress).createFungibleType(uint64(maxSupply), uri);
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
        require(membership.loyaltyAddress != address(0), "Membership does not exist");
        nftTypeID = TronicLoyalty(membership.loyaltyAddress).createNFTType(baseUri, maxMintable);
    }

    /// @notice Mints a new ERC721 token.
    /// @param _recipient The address to mint the token to.
    /// @param _membershipId The ID of the membership to mint the token for.
    /// @return The address of the newly created token account.
    function mintERC721(address _recipient, uint256 _membershipId)
        external
        onlyAdmin
        returns (address payable)
    {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.membershipAddress != address(0), "Membership does not exist");
        return TronicMembership(membership.membershipAddress).mint(_recipient);
    }

    /// @notice Mints a new ERC1155 token.
    /// @param _recipient The address to mint the token to.
    /// @param _tokenId The ID of the token to mint.
    /// @param _amount The amount of the token to mint.
    /// @param _membershipId The ID of the membership to mint the token for.
    function mintFungibleERC1155(
        uint256 _membershipId,
        address _recipient,
        uint256 _tokenId,
        uint64 _amount
    ) external onlyAdmin {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.loyaltyAddress != address(0), "Membership does not exist");
        TronicLoyalty(membership.loyaltyAddress).mintFungible(_recipient, _tokenId, _amount);
    }

    /// @notice Mints a new nonfungible ERC1155 token.
    /// @param _recipient The address to mint the token to.
    /// @param _typeId The ID of the token to mint.
    /// @param _membershipId The ID of the membership to mint the token for.
    /// @param _amount The amount of the token to mint.
    function mintNonFungibleERC1155(
        uint256 _membershipId,
        address _recipient,
        uint256 _typeId,
        uint256 _amount
    ) external onlyAdmin {
        MembershipInfo memory membership = memberships[_membershipId];
        require(membership.loyaltyAddress != address(0), "Membership does not exist");
        TronicLoyalty(membership.loyaltyAddress).mintNFTs(_typeId, _recipient, _amount);
    }

    /// @notice Processes multiple minting operations for both ERC1155 and ERC721 tokens on behalf of memberships.
    /// @param _membershipIds   Array of membership IDs corresponding to each minting operation.
    /// @param _recipients   2D array of recipient addresses for each minting operation.
    /// @param _tokenTypes     4D array of token Typess to mint for each membership.
    ///                      For ERC1155, it could be multiple IDs, and for ERC721, it should contain a single ID.
    /// @param _amounts      4D array of token amounts to mint for each membership.
    ///                      For ERC1155, it represents the quantities of each token ID, and for ERC721, it should be either [1] (to mint) or [0] (to skip).
    /// @param _contractTypes   3D array specifying the type of each token contract (either ERC1155 or ERC721) to determine the minting logic.
    /// @dev Requires that all input arrays have matching lengths.
    ///      For ERC721 minting, the inner arrays of _tokenTypes and _amounts should have a length of 1.
    /// @dev array indexes: _tokenTypes[membershipId][recipient][contractType][tokenType]
    /// @dev array indexes: _amounts[membershipId][recipient][contractType][amounts]
    function batchProcess(
        uint256[] memory _membershipIds,
        address[][] memory _recipients,
        uint256[][][][] memory _tokenTypes,
        uint256[][][][] memory _amounts,
        TokenType[][][] memory _contractTypes
    ) external {
        require(
            _membershipIds.length == _tokenTypes.length && _tokenTypes.length == _amounts.length
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
                        TronicLoyalty(membership.loyaltyAddress).mintBatch(
                            recipient, _tokenTypes[i][j][k], _amounts[i][j][k], ""
                        );
                    } else if (_contractTypes[i][j][k] == TokenType.ERC721) {
                        TronicMembership(membership.membershipAddress).mint(recipient);
                    }
                }
            }
        }
    }

    /// @notice Sets the ERC721 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC721 implementation.
    function setERC721Implementation(address newImplementation) external onlyOwner {
        tronicERC721 = TronicMembership(newImplementation);
    }

    /// @notice Sets the ERC1155 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC1155 implementation.
    function setERC1155Implementation(address newImplementation) external onlyOwner {
        tronicERC1155 = TronicLoyalty(newImplementation);
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
