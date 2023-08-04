// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ERC1155Cloneable is ERC1155, Initializable {
    uint256 public constant STARING_NFT_ID = 1000;
    address public owner;
    string public name;
    string public symbol;
    mapping(address => bool) private _admins;

    // Token ID => URI mapping
    mapping(uint256 => string) private _fungibleTokenURIs;

    constructor() ERC1155("") {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender], "Only admin");
        _;
    }

    function initialize(
        string memory _baseURI,
        address _admin,
        string memory _name,
        string memory _symbol
    ) external initializer {
        _setURI(_baseURI);
        _admins[_admin] = true;
        owner = _admin;
        name = _name;
        symbol = _symbol;
    }

    // Create new fungible token type
    function createFungibleType(uint256 _id, string memory _uri) external onlyAdmin {
        require((bytes(_fungibleTokenURIs[_id]).length == 0), "Token type already exists");

        // Set URI
        _fungibleTokenURIs[_id] = _uri;
    }

    // update token type
    function setFungibleURI(uint256 id, string memory uri_) external onlyAdmin {
        require((bytes(_fungibleTokenURIs[id]).length > 0), "Token type does not exists");
        _fungibleTokenURIs[id] = uri_;
    }

    function mintFungible(address to, uint256 id, uint256 amount) public onlyAdmin {
        require((bytes(_fungibleTokenURIs[id]).length > 0), "Token type does not exists");
        _mint(to, id, amount, "");
    }

    function mintNFT(address to, uint256 id) public onlyAdmin {
        require((bytes(_fungibleTokenURIs[id]).length == 0), "Token type already exists");
        _mint(to, id, 1, "");
    }

    function burn(address account, uint256 id, uint256 amount) public onlyAdmin {
        _burn(account, id, amount);
    }

    function uri(uint256 id) public view override returns (string memory) {
        if (bytes(_fungibleTokenURIs[id]).length > 0) {
            return _fungibleTokenURIs[id];
        } else {
            return super.uri(id);
        }
    }

    function addAdmin(address admin) external onlyOwner {
        _admins[admin] = true;
    }

    function removeAdmin(address admin) external onlyOwner {
        _admins[admin] = false;
    }

    function isAdmin(address admin) external view returns (bool) {
        return _admins[admin];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155).interfaceId || super.supportsInterface(interfaceId);
    }
}
