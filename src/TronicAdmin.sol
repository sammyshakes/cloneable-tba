// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./ERC1155Cloneable.sol";
import "./ERC721CloneableTBA.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract TronicAdmin {
    struct PartnerInfo {
        address erc721Address;
        address erc1155Address;
        string partnerName;
    }

    enum TokenType {
        ERC1155,
        ERC721
    }

    event PartnerAdded(
        uint256 indexed partnerId,
        address indexed erc721Address,
        address indexed erc1155Address,
        string partnerName
    );

    address public owner;
    address public tronicAdmin;
    address payable public tbaAccountImplementation;

    // Deployments
    IERC6551Registry public registry;
    ERC721CloneableTBA public tronicERC721;
    ERC1155Cloneable public tronicERC1155;

    uint256 public partnerCounter;
    mapping(uint256 => PartnerInfo) public partners;
    mapping(address => bool) private _admins;

    /// @notice Constructs the CloneFactory contract.
    /// @param _admin The address of the Tronic admin.
    /// @param _tronicERC721 The address of the Tronic ERC721 implementation.
    /// @param _tronicERC1155 The address of the Tronic ERC1155 implementation.
    /// @param _registry The address of the registry contract.
    /// @param _tbaAccountImplementation The address of the tokenbound account implementation.
    constructor(
        address _admin,
        address _tronicERC721,
        address _tronicERC1155,
        address _registry,
        address _tbaAccountImplementation
    ) {
        owner = msg.sender;
        tronicAdmin = _admin;
        tronicERC1155 = ERC1155Cloneable(_tronicERC1155);
        tronicERC721 = ERC721CloneableTBA(_tronicERC721);
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

    function getPartnerInfo(uint256 partnerId) external view returns (PartnerInfo memory) {
        return partners[partnerId];
    }

    /// @notice Deploys a new partner's contracts.
    /// @param name721 The name of the ERC721 token.
    /// @param symbol721 The symbol of the ERC721 token.
    /// @param uri721 The URI for the ERC721 token.
    /// @param name1155 The name of the ERC1155 token.
    /// @param symbol1155 The symbol of the ERC1155 token.
    /// @param uri1155 The URI for the ERC1155 token.
    /// @param partnerName The name of the partner.
    /// @return erc721Address The address of the deployed ERC721 contract.
    /// @return erc1155Address The address of the deployed ERC1155 contract.
    function deployPartner(
        string memory name721,
        string memory symbol721,
        string memory uri721,
        uint256 maxSupply,
        string memory name1155,
        string memory symbol1155,
        string memory uri1155,
        string memory partnerName
    ) external onlyAdmin returns (address erc721Address, address erc1155Address) {
        // Question: Will we know the TierIds beforehand?
        // Deploy the partner's contracts
        erc721Address = deployPartnerERC721(name721, symbol721, uri721, maxSupply);
        erc1155Address = deployPartnerERC1155(name1155, symbol1155, uri1155);

        // Assign partner id and associate the deployed contracts with the partner
        partners[partnerCounter++] = PartnerInfo({
            erc721Address: erc721Address,
            erc1155Address: erc1155Address,
            partnerName: partnerName
        });

        emit PartnerAdded(partnerCounter - 1, erc721Address, erc1155Address, partnerName); // partnerCounter - 1 will give the last added partner's ID
    }

    /// @notice Clones the ERC721 implementation and initializes it.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param uri The URI for the cloned contract.
    /// @return erc721CloneAddress The address of the newly cloned ERC721 contract.
    function deployPartnerERC721(
        string memory name,
        string memory symbol,
        string memory uri,
        uint256 maxSupply
    ) private returns (address erc721CloneAddress) {
        erc721CloneAddress = Clones.clone(address(tronicERC721));
        ERC721CloneableTBA erc721Clone = ERC721CloneableTBA(erc721CloneAddress);
        erc721Clone.initialize(
            tbaAccountImplementation, address(registry), name, symbol, uri, maxSupply, tronicAdmin
        );
    }

    /// @notice Clones the ERC1155 implementation and initializes it.
    /// @param uri The URI for the cloned contract.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @return erc1155cloneAddress The address of the newly cloned ERC1155 contract.
    function deployPartnerERC1155(string memory name, string memory symbol, string memory uri)
        private
        returns (address erc1155cloneAddress)
    {
        erc1155cloneAddress = Clones.clone(address(tronicERC1155));
        ERC1155Cloneable erc1155clone = ERC1155Cloneable(erc1155cloneAddress);
        erc1155clone.initialize(uri, tronicAdmin, name, symbol);
    }

    // Function to remove a partner's contracts (considering the challenges of removing from a mapping)
    function removePartner(uint256 _partnerId) external onlyAdmin {
        delete partners[_partnerId];
    }

    /// @notice Creates a new ERC1155 fungible token type for a partner.
    /// @param maxSupply The maximum supply of the token type.
    /// @param uri The URI for the token type.
    /// @param partnerId The ID of the partner to create the token type for.
    /// @return The ID of the newly created token type.
    function createFungibleTokenType(uint256 maxSupply, string memory uri, uint256 partnerId)
        external
        onlyAdmin
        returns (uint256)
    {
        PartnerInfo memory partner = partners[partnerId];
        return ERC1155Cloneable(partner.erc1155Address).createFungibleType(uint64(maxSupply), uri);
    }

    /// @notice Creates a new ERC1155 non-fungible token type for a partner.
    /// @param baseUri The URI for the token type.
    /// @param maxMintable The maximum number of tokens that can be minted.
    /// @param startingTokenId The ID of the first token to mint.
    /// @param partnerId The ID of the partner to create the token type for.
    /// @return nftTypeID The ID of the newly created token type.
    function createNonFungibleTokenType(
        string memory baseUri,
        uint64 maxMintable,
        uint64 startingTokenId,
        uint256 partnerId
    ) external onlyAdmin returns (uint256 nftTypeID) {
        PartnerInfo memory partner = partners[partnerId];
        nftTypeID = ERC1155Cloneable(partner.erc1155Address).createNFTType(
            baseUri, maxMintable, startingTokenId
        );
    }

    /// @notice Mints a new ERC721 token.
    /// @param _recipient The address to mint the token to.
    /// @param _partnerId The ID of the partner to mint the token for.
    /// @return The address of the newly created token account.
    function mintERC721(address _recipient, uint256 _partnerId)
        external
        onlyAdmin
        returns (address payable)
    {
        PartnerInfo memory partner = partners[_partnerId];
        return ERC721CloneableTBA(partner.erc721Address).mint(_recipient);
    }

    /// @notice Mints a new ERC1155 token.
    /// @param _recipient The address to mint the token to.
    /// @param _tokenId The ID of the token to mint.
    /// @param _amount The amount of the token to mint.
    /// @param _partnerId The ID of the partner to mint the token for.
    function mintFungibleERC1155(
        uint256 _partnerId,
        address _recipient,
        uint256 _tokenId,
        uint64 _amount
    ) external onlyAdmin {
        PartnerInfo memory partner = partners[_partnerId];
        ERC1155Cloneable(partner.erc1155Address).mintFungible(_recipient, _tokenId, _amount);
    }

    /// @notice Mints a new nonfungible ERC1155 token.
    /// @param _recipient The address to mint the token to.
    /// @param _typeId The ID of the token to mint.
    /// @param _partnerId The ID of the partner to mint the token for.
    /// @param _amount The amount of the token to mint.
    function mintNonFungibleERC1155(
        uint256 _partnerId,
        address _recipient,
        uint256 _typeId,
        uint256 _amount
    ) external onlyAdmin {
        PartnerInfo memory partner = partners[_partnerId];
        ERC1155Cloneable(partner.erc1155Address).mintNFTs(_typeId, _recipient, _amount);
    }

    /// @notice Processes multiple minting operations for both ERC1155 and ERC721 tokens on behalf of partners.
    /// @param _partnerIds   Array of partner IDs corresponding to each minting operation.
    /// @param _recipients   2D array of recipient addresses for each minting operation.
    /// @param _tokenIds     4D array of token IDs to mint for each partner.
    ///                      For ERC1155, it could be multiple IDs, and for ERC721, it should contain a single ID.
    /// @param _amounts      4D array of token amounts to mint for each partner.
    ///                      For ERC1155, it represents the quantities of each token ID, and for ERC721, it should be either [1] (to mint) or [0] (to skip).
    /// @param _tokenTypes   3D array specifying the type of each token (either ERC1155 or ERC721) to determine the minting logic.
    /// @dev Requires that all input arrays have matching lengths.
    ///      For ERC721 minting, the inner arrays of _tokenIds and _amounts should have a length of 1.
    function batchProcess(
        uint256[] memory _partnerIds,
        address[][] memory _recipients,
        uint256[][][][] memory _tokenIds,
        uint256[][][][] memory _amounts,
        TokenType[][][] memory _tokenTypes
    ) external {
        require(
            _partnerIds.length == _tokenIds.length && _tokenIds.length == _amounts.length
                && _amounts.length == _recipients.length && _recipients.length == _tokenTypes.length,
            "Outer arrays must have the same length"
        );

        // i = partnerId, j = recipient, k = token
        // Loop through each partner
        for (uint256 i = 0; i < _partnerIds.length; i++) {
            PartnerInfo memory partner = partners[_partnerIds[i]];

            for (uint256 j = 0; j < _recipients[i].length; j++) {
                address recipient = _recipients[i][j];

                for (uint256 k = 0; k < _tokenTypes[i][j].length; k++) {
                    if (_tokenTypes[i][j][k] == TokenType.ERC1155) {
                        ERC1155Cloneable(partner.erc1155Address).mintBatch(
                            recipient, _tokenIds[i][j][k], _amounts[i][j][k], ""
                        );
                    } else if (_tokenTypes[i][j][k] == TokenType.ERC721) {
                        ERC721CloneableTBA(partner.erc721Address).mint(recipient);
                    }
                }
            }
        }
    }

    /// @notice Sets the ERC721 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC721 implementation.
    function setERC721Implementation(address newImplementation) external onlyOwner {
        tronicERC721 = ERC721CloneableTBA(newImplementation);
    }

    /// @notice Sets the ERC1155 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC1155 implementation.
    function setERC1155Implementation(address newImplementation) external onlyOwner {
        tronicERC1155 = ERC1155Cloneable(newImplementation);
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
        return _admins[admin];
    }
}
