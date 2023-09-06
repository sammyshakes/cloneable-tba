// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./ERC1155Cloneable.sol";
import "./ERC721CloneableTBA.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract TronicAdmin {
    struct ChannelInfo {
        address erc721Address;
        address erc1155Address;
        string channelName;
    }

    enum TokenType {
        ERC1155,
        ERC721
    }

    event ChannelAdded(
        uint256 indexed channelId,
        address indexed erc721Address,
        address indexed erc1155Address,
        string channelName
    );

    address public owner;
    address public tronicAdmin;
    address payable public tbaAccountImplementation;

    // Deployments
    IERC6551Registry public registry;
    ERC721CloneableTBA public tronicERC721;
    ERC1155Cloneable public tronicERC1155;

    uint256 public channelCounter;
    mapping(uint256 => ChannelInfo) public channels;
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

    function getChannelInfo(uint256 channelId) external view returns (ChannelInfo memory) {
        return channels[channelId];
    }

    /// @notice Deploys a new channel's contracts.
    /// @param name721 The name of the ERC721 token.
    /// @param symbol721 The symbol of the ERC721 token.
    /// @param uri721 The URI for the ERC721 token.
    /// @param name1155 The name of the ERC1155 token.
    /// @param symbol1155 The symbol of the ERC1155 token.
    /// @param uri1155 The URI for the ERC1155 token.
    /// @param channelName The name of the channel.
    /// @return erc721Address The address of the deployed ERC721 contract.
    /// @return erc1155Address The address of the deployed ERC1155 contract.
    function deployChannel(
        string memory name721,
        string memory symbol721,
        string memory uri721,
        uint256 maxSupply,
        string memory name1155,
        string memory symbol1155,
        string memory uri1155,
        string memory channelName
    ) external onlyAdmin returns (address erc721Address, address erc1155Address) {
        // Question: Will we know the TierIds beforehand?
        // Deploy the channel's contracts
        erc721Address = deployChannelERC721(name721, symbol721, uri721, maxSupply);
        erc1155Address = deployChannelERC1155(name1155, symbol1155, uri1155);

        // Assign channel id and associate the deployed contracts with the channel
        channels[channelCounter++] = ChannelInfo({
            erc721Address: erc721Address,
            erc1155Address: erc1155Address,
            channelName: channelName
        });

        emit ChannelAdded(channelCounter - 1, erc721Address, erc1155Address, channelName); // channelCounter - 1 will give the last added channel's ID
    }

    /// @notice Clones the ERC721 implementation and initializes it.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param uri The URI for the cloned contract.
    /// @return erc721CloneAddress The address of the newly cloned ERC721 contract.
    function deployChannelERC721(
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
    function deployChannelERC1155(string memory name, string memory symbol, string memory uri)
        private
        returns (address erc1155cloneAddress)
    {
        erc1155cloneAddress = Clones.clone(address(tronicERC1155));
        ERC1155Cloneable erc1155clone = ERC1155Cloneable(erc1155cloneAddress);
        erc1155clone.initialize(uri, tronicAdmin, name, symbol);
    }

    // Function to remove a channel's contracts (considering the challenges of removing from a mapping)
    function removeChannel(uint256 _channelId) external onlyAdmin {
        delete channels[_channelId];
    }

    /// @notice Creates a new ERC1155 fungible token type for a channel.
    /// @param maxSupply The maximum supply of the token type.
    /// @param uri The URI for the token type.
    /// @param channelId The ID of the channel to create the token type for.
    /// @return The ID of the newly created token type.
    function createFungibleTokenType(uint256 maxSupply, string memory uri, uint256 channelId)
        external
        onlyAdmin
        returns (uint256)
    {
        ChannelInfo memory channel = channels[channelId];
        return ERC1155Cloneable(channel.erc1155Address).createFungibleType(uint64(maxSupply), uri);
    }

    /// @notice Creates a new ERC1155 non-fungible token type for a channel.
    /// @param baseUri The URI for the token type.
    /// @param maxMintable The maximum number of tokens that can be minted.
    /// @param channelId The ID of the channel to create the token type for.
    /// @return nftTypeID The ID of the newly created token type.
    function createNonFungibleTokenType(
        string memory baseUri,
        uint64 maxMintable,
        uint256 channelId
    ) external onlyAdmin returns (uint256 nftTypeID) {
        ChannelInfo memory channel = channels[channelId];
        nftTypeID = ERC1155Cloneable(channel.erc1155Address).createNFTType(baseUri, maxMintable);
    }

    /// @notice Mints a new ERC721 token.
    /// @param _recipient The address to mint the token to.
    /// @param _channelId The ID of the channel to mint the token for.
    /// @return The address of the newly created token account.
    function mintERC721(address _recipient, uint256 _channelId)
        external
        onlyAdmin
        returns (address payable)
    {
        ChannelInfo memory channel = channels[_channelId];
        return ERC721CloneableTBA(channel.erc721Address).mint(_recipient);
    }

    /// @notice Mints a new ERC1155 token.
    /// @param _recipient The address to mint the token to.
    /// @param _tokenId The ID of the token to mint.
    /// @param _amount The amount of the token to mint.
    /// @param _channelId The ID of the channel to mint the token for.
    function mintFungibleERC1155(
        uint256 _channelId,
        address _recipient,
        uint256 _tokenId,
        uint64 _amount
    ) external onlyAdmin {
        ChannelInfo memory channel = channels[_channelId];
        ERC1155Cloneable(channel.erc1155Address).mintFungible(_recipient, _tokenId, _amount);
    }

    /// @notice Mints a new nonfungible ERC1155 token.
    /// @param _recipient The address to mint the token to.
    /// @param _typeId The ID of the token to mint.
    /// @param _channelId The ID of the channel to mint the token for.
    /// @param _amount The amount of the token to mint.
    function mintNonFungibleERC1155(
        uint256 _channelId,
        address _recipient,
        uint256 _typeId,
        uint256 _amount
    ) external onlyAdmin {
        ChannelInfo memory channel = channels[_channelId];
        ERC1155Cloneable(channel.erc1155Address).mintNFTs(_typeId, _recipient, _amount);
    }

    /// @notice Processes multiple minting operations for both ERC1155 and ERC721 tokens on behalf of channels.
    /// @param _channelIds   Array of channel IDs corresponding to each minting operation.
    /// @param _recipients   2D array of recipient addresses for each minting operation.
    /// @param _tokenTypes     4D array of token Typess to mint for each channel.
    ///                      For ERC1155, it could be multiple IDs, and for ERC721, it should contain a single ID.
    /// @param _amounts      4D array of token amounts to mint for each channel.
    ///                      For ERC1155, it represents the quantities of each token ID, and for ERC721, it should be either [1] (to mint) or [0] (to skip).
    /// @param _contractTypes   3D array specifying the type of each token contract (either ERC1155 or ERC721) to determine the minting logic.
    /// @dev Requires that all input arrays have matching lengths.
    ///      For ERC721 minting, the inner arrays of _tokenTypes and _amounts should have a length of 1.
    function batchProcess(
        uint256[] memory _channelIds,
        address[][] memory _recipients,
        uint256[][][][] memory _tokenTypes,
        uint256[][][][] memory _amounts,
        TokenType[][][] memory _contractTypes
    ) external {
        require(
            _channelIds.length == _tokenTypes.length && _tokenTypes.length == _amounts.length
                && _amounts.length == _recipients.length && _recipients.length == _contractTypes.length,
            "Outer arrays must have the same length"
        );

        // i = channelId, j = recipient, k = tokentype
        // Loop through each channel
        for (uint256 i = 0; i < _channelIds.length; i++) {
            ChannelInfo memory channel = channels[_channelIds[i]];

            for (uint256 j = 0; j < _recipients[i].length; j++) {
                address recipient = _recipients[i][j];

                for (uint256 k = 0; k < _contractTypes[i][j].length; k++) {
                    if (_contractTypes[i][j][k] == TokenType.ERC1155) {
                        ERC1155Cloneable(channel.erc1155Address).mintBatch(
                            recipient, _tokenTypes[i][j][k], _amounts[i][j][k], ""
                        );
                    } else if (_contractTypes[i][j][k] == TokenType.ERC721) {
                        ERC721CloneableTBA(channel.erc721Address).mint(recipient);
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
        return _admins[admin] || admin == tronicAdmin;
    }
}
