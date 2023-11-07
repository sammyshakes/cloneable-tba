# TronicMembership
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/aba5391f4163381727c241bd74844bf5ae213d0f/src/TronicMembership.sol)

**Inherits:**
[ITronicMembership](/src/interfaces/ITronicMembership.sol/interface.ITronicMembership.md), ERC721, Initializable

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


### _baseURI_

```solidity
string private _baseURI_;
```


### owner

```solidity
address public owner;
```


### accountImplementation

```solidity
address public accountImplementation;
```


### _numTiers

```solidity
uint8 private _numTiers;
```


### _maxTiers

```solidity
uint8 private _maxTiers;
```


### isElastic

```solidity
bool public isElastic;
```


### isBound

```solidity
bool public isBound;
```


### maxSupply

```solidity
uint256 public maxSupply;
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


### _membershipTiers

```solidity
mapping(uint8 => MembershipTier) private _membershipTiers;
```


### _tokenMemberships

```solidity
mapping(uint256 => TokenMembership) private _tokenMemberships;
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

### tierExists

*Modifier to ensure a tier exists.*


```solidity
modifier tierExists(uint8 tierIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierIndex`|`uint8`|The index of the tier to check.|


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
    uint8 _maxMembershipTiers,
    uint256 _maxSupply,
    bool _isElastic,
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
|`_maxMembershipTiers`|`uint8`|Maximum number of membership tiers.|
|`_maxSupply`|`uint256`|Maximum supply of the token.|
|`_isElastic`|`bool`|Whether the max token supply is elastic or not.|
|`_isBound`|`bool`|Whether the token is soulbound or not.|
|`tronicAdmin`|`address`|Address of the initial admin.|


### mint

Mints a new token.

*The tokenbound account is created using the registry contract.*


```solidity
function mint(address to) public onlyAdmin returns (address payable tbaAccount, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address to mint the token to.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tbaAccount`|`address payable`|The payable address of the created tokenbound account.|
|`<none>`|`uint256`||


### createMembershipTier

Creates a new membership tier.

*Only callable by admin.*


```solidity
function createMembershipTier(string memory tierId, uint128 duration, bool isOpen)
    external
    onlyAdmin
    returns (uint8 tierIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierId`|`string`|The ID of the new tier.|
|`duration`|`uint128`|The duration of the new tier in seconds.|
|`isOpen`|`bool`|Whether the tier is open or closed.|


### createMembershipTiers

Creates multiple new membership tiers.

*Only callable by admin. Arrays must all have the same length.*


```solidity
function createMembershipTiers(
    string[] memory tierIds,
    uint128[] memory durations,
    bool[] memory isOpens
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierIds`|`string[]`|The IDs of the new tiers.|
|`durations`|`uint128[]`|The durations of the new tiers in seconds.|
|`isOpens`|`bool[]`|Whether the tiers are open or closed.|


### setMembershipTier

Sets the details of a membership tier.

*Only callable by admin.*

*the tier must exist.*


```solidity
function setMembershipTier(uint8 tierIndex, string calldata tierId, uint128 duration, bool isOpen)
    external
    onlyAdmin
    tierExists(tierIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierIndex`|`uint8`|The index of the tier to update.|
|`tierId`|`string`||
|`duration`|`uint128`|The new duration in seconds.|
|`isOpen`|`bool`|The new open status.|


### getMembershipTierDetails

Retrieves the details of a membership tier.


```solidity
function getMembershipTierDetails(uint8 tierIndex) external view returns (MembershipTier memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierIndex`|`uint8`|The index of the tier to retrieve.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`MembershipTier`|The details of the tier.|


### getMembershipTierId

Retrieves the ID of a membership tier.


```solidity
function getMembershipTierId(uint8 tierIndex) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierIndex`|`uint8`|The index of the tier to retrieve.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|The ID of the tier.|


### setTokenMembership

Sets the membership details of a specific token.

*This function can only be called by an admin.*

*The tier must exist.*

*The token must exist.*


```solidity
function setTokenMembership(uint256 tokenId, uint8 tierIndex)
    external
    onlyAdmin
    tierExists(tierIndex)
    tokenExists(tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token whose membership details are to be set.|
|`tierIndex`|`uint8`|The index of the membership tier to associate with the token.|


### getTokenMembership

Retrieves the membership details of a specific token.

*The token must exist.*


```solidity
function getTokenMembership(uint256 tokenId)
    external
    view
    tokenExists(tokenId)
    returns (TokenMembership memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token whose membership details are to be retrieved.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TokenMembership`|The membership details of the token, represented by a `TokenMembership` struct.|


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


### getTierIndexByTierId

Retrieves tier index of a given tier ID.

*Returns 0 if the tier does not exist.*


```solidity
function getTierIndexByTierId(string memory tierId) external view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierId`|`string`|The ID of the tier.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|The index of the tier.|


### isValid

Checks if a token has a valid membership.

*The token must exist.*


```solidity
function isValid(uint256 tokenId) external view tokenExists(tokenId) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the token has a valid membership, false otherwise.|


### burn

Burns a token with the given ID.


```solidity
function burn(uint256 tokenId) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the token to burn.|


### setMaxSupply

Sets the max supply of the token.

*Only callable by admin.*

*Only callable for elastic tokens.*

*The max supply must be greater than the total minted.*


```solidity
function setMaxSupply(uint256 _maxSupply) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_maxSupply`|`uint256`|The new max supply.|


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

*it reverts if the token is bound.*


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

*it reverts if the token is bound.*


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

Returns _baseURI_.

*This function overrides the baseURI function of ERC721.*


```solidity
function _baseURI() internal view override returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|_baseURI_.|


