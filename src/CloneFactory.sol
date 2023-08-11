// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./ERC1155Cloneable.sol";
import "./ERC721CloneableTBA.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/// @title CloneFactory
/// @notice A contract for cloning and managing ERC721 and ERC1155 contracts.
contract CloneFactory {
    event CloneCreated(address clone, string name);

    IERC6551Registry public registry;
    ERC721CloneableTBA public erc721Implementation;
    ERC1155Cloneable public erc1155implementation;

    address public owner;
    address public tronicAdmin;
    address payable public accountImplementation;

    uint256 private _numERC1155Clones;
    uint256 private _numERC721Clones;

    mapping(uint256 => address) public erc1155Clones;
    mapping(uint256 => address) public erc721Clones;

    /// @notice Constructs the CloneFactory contract.
    /// @param _tronicAdmin The address of the Tronic admin.
    /// @param _erc721Implementation The address of the ERC721 implementation.
    /// @param _erc1155implementation The address of the ERC1155 implementation.
    /// @param _registry The address of the registry contract.
    /// @param _accountImplementation The address of the account implementation.
    constructor(
        address _tronicAdmin,
        address _erc721Implementation,
        address _erc1155implementation,
        address _registry,
        address _accountImplementation
    ) {
        owner = msg.sender;
        erc1155implementation = ERC1155Cloneable(_erc1155implementation);
        erc721Implementation = ERC721CloneableTBA(_erc721Implementation);
        tronicAdmin = _tronicAdmin;
        registry = IERC6551Registry(_registry);
        accountImplementation = payable(_accountImplementation);
    }

    /// @dev Modifier to require that the caller is the owner of the contract.
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /// @dev Modifier to require that the caller is the Tronic admin.
    modifier onlyTronicAdmin() {
        require(msg.sender == tronicAdmin, "Caller is not Tronic admin");
        _;
    }

    /// @notice Clones the ERC1155 implementation and initializes it.
    /// @param uri The URI for the cloned contract.
    /// @param admin The address of the admin for the cloned contract.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @return erc1155cloneAddress The address of the newly cloned ERC1155 contract.
    function cloneERC1155(
        string memory uri,
        address admin,
        string memory name,
        string memory symbol
    ) external onlyTronicAdmin returns (address erc1155cloneAddress) {
        erc1155cloneAddress = Clones.clone(address(erc1155implementation));
        ERC1155Cloneable erc1155clone = ERC1155Cloneable(erc1155cloneAddress);
        erc1155clone.initialize(uri, admin, name, symbol);

        erc1155Clones[_numERC1155Clones] = erc1155cloneAddress;
        _numERC1155Clones++;

        emit CloneCreated(erc1155cloneAddress, uri);
    }

    /// @notice Clones the ERC721 implementation and initializes it.
    /// @param name The name of the token.
    /// @param symbol The symbol of the token.
    /// @param uri The URI for the cloned contract.
    /// @param admin The address of the admin for the cloned contract.
    /// @return erc721CloneAddress The address of the newly cloned ERC721 contract.
    function cloneERC721(string memory name, string memory symbol, string memory uri, address admin)
        external
        onlyTronicAdmin
        returns (address erc721CloneAddress)
    {
        erc721CloneAddress = Clones.clone(address(erc721Implementation));
        ERC721CloneableTBA erc721Clone = ERC721CloneableTBA(erc721CloneAddress);
        erc721Clone.initialize(accountImplementation, address(registry), name, symbol, uri, admin);

        // Emit event, store clone, etc
        erc721Clones[_numERC721Clones] = erc721CloneAddress;
        _numERC721Clones++;

        emit CloneCreated(erc721CloneAddress, uri);
    }

    /// @notice Retrieves the address of a specific ERC1155 clone by its index.
    /// @param index The index of the ERC1155 clone.
    /// @return The address of the ERC1155 clone.
    function getERC1155Clone(uint256 index) external view returns (address) {
        return erc1155Clones[index];
    }

    /// @notice Retrieves the address of a specific ERC721 clone by its index.
    /// @param index The index of the ERC721 clone.
    /// @return The address of the ERC721 clone.
    function getERC721Clone(uint256 index) external view returns (address) {
        return erc721Clones[index];
    }

    /// @notice Retrieves the total number of ERC1155 clones.
    /// @return The total number of ERC1155 clones.
    function getNumERC1155Clones() external view returns (uint256) {
        return _numERC1155Clones;
    }

    /// @notice Retrieves the total number of ERC721 clones.
    /// @return The total number of ERC721 clones.
    function getNumERC721Clones() external view returns (uint256) {
        return _numERC721Clones;
    }

    /// @notice Sets the Tronic admin address, callable only by the tronic admin.
    /// @param newAdmin The address of the new Tronic admin.
    function setTronicAdmin(address newAdmin) external onlyTronicAdmin {
        tronicAdmin = newAdmin;
    }

    /// @notice Sets the ERC721 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC721 implementation.
    function setERC721Implementation(address newImplementation) external onlyOwner {
        erc721Implementation = ERC721CloneableTBA(newImplementation);
    }

    /// @notice Sets the ERC1155 implementation address, callable only by the owner.
    /// @param newImplementation The address of the new ERC1155 implementation.
    function setERC1155Implementation(address newImplementation) external onlyOwner {
        erc1155implementation = ERC1155Cloneable(newImplementation);
    }

    /// @notice Sets the account implementation address, callable only by the owner.
    /// @param newImplementation The address of the new account implementation.
    function setAccountImplementation(address payable newImplementation) external onlyOwner {
        accountImplementation = newImplementation;
    }

    /// @notice Sets the registry address, callable only by the owner.
    /// @param newRegistry The address of the new registry.
    function setRegistry(address newRegistry) external onlyOwner {
        registry = IERC6551Registry(newRegistry);
    }
}
