// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./ERC1155Cloneable.sol";
import "./ERC721CloneableTBA.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

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

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier onlyTronicAdmin() {
        require(msg.sender == tronicAdmin, "Caller is not Tronic admin");
        _;
    }

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

    function getERC1155Clone(uint256 index) external view returns (address) {
        return erc1155Clones[index];
    }

    function getERC721Clone(uint256 index) external view returns (address) {
        return erc721Clones[index];
    }

    function getNumERC1155Clones() external view returns (uint256) {
        return _numERC1155Clones;
    }

    function getNumERC721Clones() external view returns (uint256) {
        return _numERC721Clones;
    }

    function setTronicAdmin(address newAdmin) external onlyOwner {
        require(msg.sender == tronicAdmin, "Caller is not the tronicAdmin");
        tronicAdmin = newAdmin;
    }

    function setERC721Implementation(address newImplementation) external onlyOwner {
        erc721Implementation = ERC721CloneableTBA(newImplementation);
    }

    function setERC1155Implementation(address newImplementation) external onlyOwner {
        erc1155implementation = ERC1155Cloneable(newImplementation);
    }

    function setAccountImplementation(address payable newImplementation) external onlyOwner {
        accountImplementation = newImplementation;
    }

    function setRegistry(address newRegistry) external onlyOwner {
        registry = IERC6551Registry(newRegistry);
    }
}
