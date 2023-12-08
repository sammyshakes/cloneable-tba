# ITronicBrandLoyalty
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/41cffe407c00f76a272c977491475b582628fb23/src/interfaces/ITronicBrandLoyalty.sol)


## Functions
### initialize


```solidity
function initialize(
    address payable _accountImplementation,
    address _registry,
    string memory name_,
    string memory symbol_,
    string memory uri,
    bool _isBound,
    address tronicAdmin
) external;
```

### mint


```solidity
function mint(address to) external returns (address payable tbaAccount, uint256);
```

### getTBAccount


```solidity
function getTBAccount(uint256 tokenId) external view returns (address);
```

### burn


```solidity
function burn(uint256 tokenId) external;
```

