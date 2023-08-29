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
        tronicERC1155 = ERC1155Cloneable(_tronicERC1155);
        tronicERC721 = ERC721CloneableTBA(_tronicERC721);
        registry = IERC6551Registry(_registry);
        tbaAccountImplementation = payable(_tbaAccountImplementation);
        _admins[_admin] = true;
    }

    // Modifiers for access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender], "Only admin");
        _;
    }

    function getPartnerInfo(uint256 partnerId) external view returns (PartnerInfo memory) {
        return partners[partnerId];
    }

    // Function to deploy partner contracts using CloneFactory and then associate them with a partner
    function deployPartner(
        string memory name721,
        string memory symbol721,
        string memory uri721,
        string memory name1155,
        string memory symbol1155,
        string memory uri1155,
        string memory partnerName
    ) external onlyAdmin returns (address erc721Address, address erc1155Address) {
        // Deploy the partner's contracts
        erc721Address = deployPartnerERC721(name721, symbol721, uri721, address(this));
        erc1155Address = deployPartnerERC1155(name1155, symbol1155, uri1155, address(this));

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
    /// @param admin The address of the admin for the cloned contract.
    /// @return erc721CloneAddress The address of the newly cloned ERC721 contract.
    function deployPartnerERC721(
        string memory name,
        string memory symbol,
        string memory uri,
        address admin
    ) private returns (address erc721CloneAddress) {
        erc721CloneAddress = Clones.clone(address(tronicERC721));
        ERC721CloneableTBA erc721Clone = ERC721CloneableTBA(erc721CloneAddress);
        erc721Clone.initialize(
            tbaAccountImplementation, address(registry), name, symbol, uri, admin
        );
    }

    /// @notice Clones the ERC1155 implementation and initializes it.
    /// @param uri The URI for the cloned contract.
    /// @param admin The address of the admin for the cloned contract.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @return erc1155cloneAddress The address of the newly cloned ERC1155 contract.
    function deployPartnerERC1155(
        string memory name,
        string memory symbol,
        string memory uri,
        address admin
    ) private returns (address erc1155cloneAddress) {
        erc1155cloneAddress = Clones.clone(address(tronicERC1155));
        ERC1155Cloneable erc1155clone = ERC1155Cloneable(erc1155cloneAddress);
        erc1155clone.initialize(uri, admin, name, symbol);
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
        uint256 maxMintable,
        uint256 startingTokenId,
        uint256 partnerId
    ) external onlyAdmin returns (uint256 nftTypeID) {
        PartnerInfo memory partner = partners[partnerId];
        nftTypeID = ERC1155Cloneable(partner.erc1155Address).createNFTType(
            baseUri, maxMintable, startingTokenId
        );
    }

    /// @notice Processes multiple minting operations for both ERC1155 and ERC721 tokens on behalf of partners.
    /// @param _partnerIds   Array of partner IDs corresponding to each minting operation.
    /// @param _tokenIds     2D array of token IDs to mint for each partner.
    ///                      For ERC1155, it could be multiple IDs, and for ERC721, it should contain a single ID.
    /// @param _amounts      2D array of token amounts to mint for each partner.
    ///                      For ERC1155, it represents the quantities of each token ID, and for ERC721, it should be either [1] (to mint) or [0] (to skip).
    /// @param _recipients   Array of recipient addresses for each minting operation.
    /// @param _tokenTypes   Array specifying the type of each token (either ERC1155 or ERC721) to determine the minting logic.
    /// @dev Requires that all input arrays have matching lengths.
    ///      For ERC721 minting, the inner arrays of _tokenIds and _amounts should have a length of 1.
    function batchProcess(
        address[] memory _recipients,
        uint256[][] memory _partnerIds,
        uint256[][][] memory _tokenIds,
        uint256[][][] memory _amounts,
        TokenType[][] memory _tokenTypes
    ) external onlyAdmin {
        require(
            _partnerIds.length == _tokenIds.length && _tokenIds.length == _amounts.length
                && _amounts.length == _recipients.length && _recipients.length == _tokenTypes.length,
            "Outer arrays must have the same length"
        );

        for (uint256 i = 0; i < _recipients.length; i++) {
            require(
                _partnerIds[i].length == _tokenIds[i].length
                    && _tokenIds[i].length == _amounts[i].length
                    && _amounts[i].length == _tokenTypes[i].length,
                "Inner arrays for a recipient must have the same length"
            );

            for (uint256 j = 0; j < _partnerIds[i].length; j++) {
                PartnerInfo memory partner = partners[_partnerIds[i][j]];

                if (_tokenTypes[i][j] == TokenType.ERC1155) {
                    // Check if the tokenIds and amounts for this partner have the same length
                    require(
                        _tokenIds[i][j].length == _amounts[i][j].length,
                        "TokenIds and amounts arrays for a partner must have the same length"
                    );

                    // Call the mintBatch function
                    ERC1155Cloneable(partner.erc1155Address).mintBatch(
                        _recipients[i], _tokenIds[i][j], _amounts[i][j], ""
                    );
                } else if (_tokenTypes[i][j] == TokenType.ERC721) {
                    require(
                        _tokenIds[i][j].length == 1,
                        "ERC721 should have a single tokenId for minting"
                    );
                    require(_amounts[i][j][0] == 1, "ERC721 minting amount should be 1");

                    // Call the mint function
                    ERC721CloneableTBA(partner.erc721Address).mint(
                        _recipients[i], _tokenIds[i][j][0]
                    );
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
