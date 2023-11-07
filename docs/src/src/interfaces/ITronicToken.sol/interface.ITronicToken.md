# ITronicToken
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/aba5391f4163381727c241bd74844bf5ae213d0f/src/interfaces/ITronicToken.sol)


## Functions
### initialize


```solidity
function initialize(address _tronicAdmin) external;
```

### getFungibleTokenInfo


```solidity
function getFungibleTokenInfo(uint256 typeId) external view returns (FungibleTokenInfo memory);
```

### getNFTokenInfo


```solidity
function getNFTokenInfo(uint256 typeId) external view returns (NFTokenInfo memory);
```

### getNftIdsForOwner


```solidity
function getNftIdsForOwner(address _owner) external view returns (uint256[] memory);
```

### createNFTType


```solidity
function createNFTType(string memory baseURI, uint64 maxMintable)
    external
    returns (uint256 nftTypeId);
```

### createFungibleType


```solidity
function createFungibleType(uint64 maxSupply, string memory uri)
    external
    returns (uint256 fungibleTokenId);
```

### mintFungible


```solidity
function mintFungible(address to, uint256 id, uint64 amount) external;
```

### mintNFT


```solidity
function mintNFT(uint256 typeId, address to) external;
```

### mintNFTs


```solidity
function mintNFTs(uint256 typeId, address to, uint256 amount) external;
```

### setLevel


```solidity
function setLevel(uint256 tokenId, uint256 level) external;
```

### getLevel


```solidity
function getLevel(uint256 tokenId) external view returns (uint256);
```

### mintBatch


```solidity
function mintBatch(
    address to,
    uint256[] memory typeIds,
    uint256[] memory amounts,
    bytes memory data
) external;
```

## Structs
### FungibleTokenInfo
*Struct representing a fungible token type.*


```solidity
struct FungibleTokenInfo {
    uint64 maxSupply;
    uint64 totalMinted;
    uint64 totalBurned;
    string uri;
}
```

### NFTokenInfo
*Struct representing a non-fungible token type.*


```solidity
struct NFTokenInfo {
    uint64 startingTokenId;
    uint64 totalMinted;
    uint64 maxMintable;
    string baseURI;
}
```

