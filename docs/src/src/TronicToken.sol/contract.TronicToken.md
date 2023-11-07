# TronicToken
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/aba5391f4163381727c241bd74844bf5ae213d0f/src/TronicToken.sol)

**Inherits:**
[ITronicToken](/src/interfaces/ITronicToken.sol/interface.ITronicToken.md), ERC1155, Initializable

This contract represents the fungible and non-fungible tokens (NFTs) for the Tronic ecosystem.

*This contract is based on the ERC1155 standard.*

*This contract is cloneable.*


## State Variables
### _tokenTypeCounter

```solidity
uint32 private _tokenTypeCounter;
```


### _nextNFTTypeStartId

```solidity
uint64 private _nextNFTTypeStartId = 100_000;
```


### owner

```solidity
address public owner;
```


### name

```solidity
string public name;
```


### symbol

```solidity
string public symbol;
```


### _fungibleTokens

```solidity
mapping(uint256 => FungibleTokenInfo) private _fungibleTokens;
```


### _nftTypes

```solidity
mapping(uint256 => NFTokenInfo) private _nftTypes;
```


### tokenLevels

```solidity
mapping(uint256 => uint256) public tokenLevels;
```


### nftOwners

```solidity
mapping(uint256 => address) public nftOwners;
```


### nftIdsForOwner

```solidity
mapping(address => uint256[]) public nftIdsForOwner;
```


### _admins

```solidity
mapping(address => bool) private _admins;
```


## Functions
### constructor

Constructor initializes ERC1155 with an empty URI.


```solidity
constructor() ERC1155("");
```

### onlyOwner

*Modifier to ensure only the owner can call certain functions.*


```solidity
modifier onlyOwner();
```

### onlyAdmin

*Modifier to ensure only an admin can call certain functions.*


```solidity
modifier onlyAdmin();
```

### initialize

Initializes the contract with tronic Admin address.

*This function is called by the TronicMain contract.*


```solidity
function initialize(address _tronicAdmin) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tronicAdmin`|`address`|Address of the Tronic admin.|


### getFungibleTokenInfo

Gets the information of a fungible token type.


```solidity
function getFungibleTokenInfo(uint256 typeId) external view returns (FungibleTokenInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`typeId`|`uint256`|The ID of the token type.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`FungibleTokenInfo`|The information of the token type.|


### getNFTokenInfo

Gets the information of a non-fungible token (NFT) type.


```solidity
function getNFTokenInfo(uint256 typeId) external view returns (NFTokenInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`typeId`|`uint256`|The ID of the token type.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NFTokenInfo`|The information of the token type.|


### getNftIdsForOwner

Gets the non-fungible token (NFT) IDs for a specific address.


```solidity
function getNftIdsForOwner(address _owner) external view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The address to get the NFT IDs for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|The NFT IDs for the address.|


### createNFTType

Creates a new non-fungible token (NFT) type.

*Only callable by admin.*

*Requires that the max mintable is greater than 0.*


```solidity
function createNFTType(string memory baseURI, uint64 maxMintable)
    external
    onlyAdmin
    returns (uint256 nftTypeId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`baseURI`|`string`|Base URI for the token metadata.|
|`maxMintable`|`uint64`|Max mintable for the NFT type.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`nftTypeId`|`uint256`|The ID of the new NFT type.|


### createFungibleType

Creates a new fungible token type.

*Only callable by admin.*

*Requires that the max supply is greater than 0.*


```solidity
function createFungibleType(uint64 _maxSupply, string memory _uri)
    external
    onlyAdmin
    returns (uint256 fungibleTokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_maxSupply`|`uint64`|Max supply for the fungible token type.|
|`_uri`|`string`|URI for the token type's metadata.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`fungibleTokenId`|`uint256`|The ID of the new fungible token type.|


### mintFungible

Mints fungible tokens to a specific address.

*Requires that the token type exists and minting amount does not exceed max supply.*


```solidity
function mintFungible(address to, uint256 id, uint64 amount) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address to mint the tokens to.|
|`id`|`uint256`|ID of the fungible token type.|
|`amount`|`uint64`|The amount of tokens to mint.|


### mintNFT

Mints a non-fungible token (NFT) to a specific address.

*Requires that the NFT type already exists.*

*Requires that the amount does not exceed the max mintable for the NFT type.*


```solidity
function mintNFT(uint256 typeId, address to) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`typeId`|`uint256`|Type ID of the NFT.|
|`to`|`address`|Address to mint the NFT to.|


### mintNFTs

Mints multiple non-fungible tokens (NFTs) to a specific address.

*Requires that the NFT type already exists.*

*Requires that the amount does not exceed the max mintable for the NFT type.*

*only callable by admin*


```solidity
function mintNFTs(uint256 typeId, address to, uint256 amount) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`typeId`|`uint256`|Type ID of the NFT.|
|`to`|`address`|Address to mint the NFTs to.|
|`amount`|`uint256`|The amount of NFTs to mint.|


### _mintNFTs

Mints multiple non-fungible tokens (NFTs) to a specific address.

*Requires that the NFT type already exists.*

*Requires that the amount does not exceed the max mintable for the NFT type.*


```solidity
function _mintNFTs(uint256 typeId, address to, uint256 amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`typeId`|`uint256`|Type ID of the NFT.|
|`to`|`address`|Address to mint the NFTs to.|
|`amount`|`uint256`|The amount of NFTs to mint.|


### setLevel

Sets the level of a specific token ID.

*Only callable by admin.*


```solidity
function setLevel(uint256 tokenId, uint256 level) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token.|
|`level`|`uint256`|The level to set.|


### getLevel

Gets the level of a specific token ID.


```solidity
function getLevel(uint256 tokenId) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The level of the token.|


### mintBatch

Mints multiple tokens to a specific address.

*Requires that the token type IDs and amounts arrays have matching lengths.*


```solidity
function mintBatch(
    address to,
    uint256[] memory typeIds,
    uint256[] memory amounts,
    bytes memory data
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address to mint the tokens to.|
|`typeIds`|`uint256[]`|Type IDs of the tokens to mint.|
|`amounts`|`uint256[]`|Amounts of each token to mint.|
|`data`|`bytes`|Additional data to include in the minting call.|


### burn

Burns tokens from a specific address.

*For NFT types the amount is always 1.*

*Requires that the caller is an admin.*


```solidity
function burn(address account, uint256 id, uint256 amount) public onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to burn tokens from.|
|`id`|`uint256`|ID of the token type to burn.|
|`amount`|`uint256`|The amount of tokens to burn.|


### _getNextNFTTypeStartId

Gets the next non-fungible token (NFT) type start ID.


```solidity
function _getNextNFTTypeStartId(uint64 maxMintable) private returns (uint64 startId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxMintable`|`uint64`|Max mintable for the NFT type.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`startId`|`uint64`|The next NFT type start ID.|


### isFungible

Checks if a token ID is fungible.


```solidity
function isFungible(uint256 tokenId) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the token ID is fungible, false otherwise.|


### _updateOwnership

*Updates the ownership of a token.*


```solidity
function _updateOwnership(address from, address to, uint256 tokenId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address to transfer from.|
|`to`|`address`|The address to transfer to.|
|`tokenId`|`uint256`|The ID of the token.|


### uri

Returns the URI for a specific token ID.

*Overrides the base implementation to support fungible tokens.*


```solidity
function uri(uint256 tokenId) public view override returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The URI of the token.|


### safeTransferFrom

Overrides the base implementation to support non-fungible tokens.


```solidity
function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data)
    public
    override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address to transfer from.|
|`to`|`address`|The address to transfer to.|
|`id`|`uint256`|The ID of the token.|
|`amount`|`uint256`|The amount of tokens to transfer.|
|`data`|`bytes`|Additional data to include in the transfer call.|


### safeBatchTransferFrom

Overrides the base implementation to support non-fungible tokens.


```solidity
function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
) public override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address to transfer from.|
|`to`|`address`|The address to transfer to.|
|`ids`|`uint256[]`|The IDs of the tokens.|
|`amounts`|`uint256[]`|The amounts of each token to transfer.|
|`data`|`bytes`|Additional data to include in the transfer call.|


### addAdmin

Adds an admin to the contract.


```solidity
function addAdmin(address admin) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|The address of the new admin.|


### removeAdmin

Removes an admin from the contract.


```solidity
function removeAdmin(address admin) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|The address of the admin to remove.|


### isAdmin

Checks if an address is an admin of the contract.


```solidity
function isAdmin(address admin) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`admin`|`address`|The address to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the address is an admin, false otherwise.|


### supportsInterface

Checks if the contract supports a specific interface.


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface ID to check for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the interface is supported, false otherwise.|


## Events
### FungibleTokenTypeCreated

```solidity
event FungibleTokenTypeCreated(uint256 indexed typeId, uint64 maxSupply, string uri);
```

### NFTokenTypeCreated

```solidity
event NFTokenTypeCreated(uint256 indexed typeId, uint64 maxMintable, string baseURI);
```

