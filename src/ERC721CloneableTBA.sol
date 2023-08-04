// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./interfaces/IERC6551Registry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ERC721CloneableTBA is ERC721Enumerable, Ownable, Initializable {
    IERC6551Registry public registry;
    address public accountImplementation;

    mapping(address => bool) private _admins;
    string private _baseURI_;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    constructor() ERC721("", "") Ownable() {}

    function initialize(
        address payable _accountImplementation,
        address _registry,
        string memory name_,
        string memory symbol_,
        string memory uri,
        address admin
    ) external initializer {
        accountImplementation = _accountImplementation;
        registry = IERC6551Registry(_registry);
        _baseURI_ = uri;
        _admins[admin] = true;
        _name = name_;
        _symbol = symbol_;
    }

    function mint(address to, uint256 tokenId) public onlyAdmin returns (address payable account) {
        // Deploy token account
        account = payable(
            registry.createAccount(
                accountImplementation,
                block.chainid,
                address(this),
                tokenId,
                0, // salt
                "" // init data
            )
        );

        // Mint token
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public onlyAdmin {
        _burn(tokenId);
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _baseURI_ = uri;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender], "Only admin");
        _;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _id) public view override returns (string memory) {
        require(_exists(_id), "Token does not exist");

        return string(abi.encodePacked(_baseURI_, Strings.toString(_id)));
    }

    function addAdmin(address _admin) external onlyOwner {
        _admins[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {
        _admins[_admin] = false;
    }

    function isAdmin(address _admin) external view returns (bool) {
        return _admins[_admin];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC721).interfaceId || super.supportsInterface(interfaceId);
    }
}
