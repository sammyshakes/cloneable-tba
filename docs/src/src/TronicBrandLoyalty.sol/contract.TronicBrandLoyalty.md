# TronicBrandLoyalty
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/41cffe407c00f76a272c977491475b582628fb23/src/TronicBrandLoyalty.sol)

**Inherits:**
[ITronicBrandLoyalty](/src/interfaces/ITronicBrandLoyalty.sol/interface.ITronicBrandLoyalty.md), ERC721, Initializable

This contract represents the membership token for the Tronic ecosystem.


## State Variables
### _name

```solidity
string private _name;
```


### _symbol

```solidity
string private _symbol;
```


### baseURI_

```solidity
string private baseURI_;
```


### isBound

```solidity
bool public isBound;
```


### owner

```solidity
address public owner;
```


### accountImplementation

```solidity
address public accountImplementation;
```


### _totalBurned

```solidity
uint256 private _totalBurned;
```


### _totalMinted

```solidity
uint256 private _totalMinted;
```


### registry

```solidity
IERC6551Registry public registry;
```


### _admins

```solidity
mapping(address => bool) private _admins;
```


## Functions
### onlyOwner

*Modifier to ensure only the owner can call certain functions.*


```solidity
modifier onlyOwner();
```

### onlyAdmin

*Modifier to ensure only the admin can call certain functions.*


```solidity
modifier onlyAdmin();
```

### tokenExists

*Modifier to ensure a token exists.*


```solidity
modifier tokenExists(uint256 tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token to check.|


### constructor

Constructor initializes the ERC721 with empty name and symbol.

*The name and symbol can be set using the initialize function.*

*The constructor is left empty because of the proxy pattern used.*


```solidity
constructor() ERC721("", "");
```

### initialize

Initializes the contract with given parameters.

*This function is called by the tronicMain contract.*


```solidity
function initialize(
    address payable _accountImplementation,
    address _registry,
    string memory name_,
    string memory symbol_,
    string memory uri,
    bool _isBound,
    address tronicAdmin
) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountImplementation`|`address payable`|Implementation of the account.|
|`_registry`|`address`|Address of the registry contract.|
|`name_`|`string`|Name of the token.|
|`symbol_`|`string`|Symbol of the token.|
|`uri`|`string`|Base URI of the token.|
|`_isBound`|`bool`|Whether the token is soulbound or not.|
|`tronicAdmin`|`address`|Address of the initial admin.|


### mint

Mints a new token.

*The tokenbound account is created using the registry contract.*


```solidity
function mint(address to) public onlyAdmin returns (address payable tbaAccount, uint256 tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address to mint the token to.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tbaAccount`|`address payable`|The payable address of the created tokenbound account.|
|`tokenId`|`uint256`|The ID of the minted token.|


### getTBAccount

Retrieves the tokenbound account of a given token ID.


```solidity
function getTBAccount(uint256 tokenId) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of the tokenbound account.|


### burn

Burns a token with the given ID.


```solidity
function burn(uint256 tokenId) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the token to burn.|


### setBaseURI

Sets the base URI for the token.


```solidity
function setBaseURI(string memory uri) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`uri`|`string`|The new base URI.|


### name

Returns the name of the token.


```solidity
function name() public view override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The name of the token.|


### symbol

Returns the symbol of the token.


```solidity
function symbol() public view override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The symbol of the token.|


### addAdmin

Adds an admin.

*Only callable by owner.*


```solidity
function addAdmin(address _admin) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_admin`|`address`|The address of the new admin.|


### removeAdmin

Removes an admin.

*Only callable by owner.*


```solidity
function removeAdmin(address _admin) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_admin`|`address`|The address of the admin to remove.|


### isAdmin

Checks if an address is an admin.


```solidity
function isAdmin(address _admin) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_admin`|`address`|The address to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the address is an admin, false otherwise.|


### updateImplementation

Updates the implementation of the account.

*Only callable by owner.*


```solidity
function updateImplementation(address payable _accountImplementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountImplementation`|`address payable`|The new account implementation address.|


### supportsInterface

Overrides the supportsInterface function to include support for IERC721.


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


### transferOwnership

Transfers ownership of the contract to a new owner.

*Only callable by owner.*


```solidity
function transferOwnership(address newOwner) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newOwner`|`address`|The address of the new owner.|


### transferFrom

Transfers an unbound token from one address to another.

*This function overrides the transferFrom function of ERC721.*

*it reverts if the token is bound or if msg.sender is admin.*


```solidity
function transferFrom(address from, address to, uint256 tokenId) public override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address to transfer the token from.|
|`to`|`address`|The address to transfer the token to.|
|`tokenId`|`uint256`|The ID of the token to transfer.|


### safeTransferFrom

Safely transfers an unbound token from one address to another.

*This function overrides the safeTransferFrom function of ERC721.*

*it reverts if the token is bound or if msg.sender is admin.*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)
    public
    override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The address to transfer the token from.|
|`to`|`address`|The address to transfer the token to.|
|`tokenId`|`uint256`|The ID of the token to transfer.|
|`_data`|`bytes`||


### totalSupply

Returns the total supply of the token.


```solidity
function totalSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total supply of the token.|


### _baseURI

Returns baseURI_.

*This function overrides the baseURI function of ERC721.*


```solidity
function _baseURI() internal view override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|baseURI_.|


