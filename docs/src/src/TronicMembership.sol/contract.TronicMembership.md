# TronicMembership
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/69000936679381ac7b4b9436ba05974e252ee19a/src/TronicMembership.sol)

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


### isElastic

```solidity
bool public isElastic;
```


### maxMintable

```solidity
uint256 public maxMintable;
```


### owner

```solidity
address public owner;
```


### _numTiers

```solidity
uint8 private _numTiers;
```


### _maxTiers

```solidity
uint8 private _maxTiers;
```


### _totalBurned

```solidity
uint256 private _totalBurned;
```


### _totalMinted

```solidity
uint256 private _totalMinted;
```


### _tierIdToTierIndex

```solidity
mapping(string => uint8) private _tierIdToTierIndex;
```


### _membershipTiers

```solidity
mapping(uint8 => MembershipTier) private _membershipTiers;
```


### _membershipTokens

```solidity
mapping(uint256 => MembershipToken) private _membershipTokens;
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
    string memory name_,
    string memory symbol_,
    string memory uri,
    uint256 _maxMintable,
    bool _isElastic,
    uint8 _maxMembershipTiers,
    address tronicAdmin
) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|Name of the token.|
|`symbol_`|`string`|Symbol of the token.|
|`uri`|`string`|Base URI of the token.|
|`_maxMintable`|`uint256`|Maximum number of tokens that can be minted.|
|`_isElastic`|`bool`|Whether max mintable is adjustable or not.|
|`_maxMembershipTiers`|`uint8`|Maximum number of membership tiers.|
|`tronicAdmin`|`address`|Address of the initial admin.|


### mint

Mints a new token.

*This function can only be called by an admin.*

*The tier must exist.*


```solidity
function mint(address to, uint8 tierIndex) external onlyAdmin returns (uint256 tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address to mint the token to.|
|`tierIndex`|`uint8`|The index of the membership tier to associate with the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token.|


### createMembershipTier

Creates a new membership tier.

*Only callable by admin.*


```solidity
function createMembershipTier(
    string memory tierId,
    uint128 duration,
    bool isOpen,
    string calldata tierURI
) external onlyAdmin returns (uint8 tierIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierId`|`string`|The ID of the new tier.|
|`duration`|`uint128`|The duration of the new tier in seconds.|
|`isOpen`|`bool`|Whether the tier is open or closed.|
|`tierURI`|`string`|The URI of the tier.|


### createMembershipTiers

Creates multiple new membership tiers.

*Only callable by admin. Arrays must all have the same length.*


```solidity
function createMembershipTiers(MembershipTier[] calldata tiers) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tiers`|`MembershipTier[]`|An array of `MembershipTier` structs.|


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


### setMembershipTier

Sets the details of a membership tier.

*Only callable by admin.*

*the tier must exist.*


```solidity
function setMembershipTier(
    uint8 tierIndex,
    string calldata tierId,
    uint128 duration,
    bool isOpen,
    string calldata tierURI
) external onlyAdmin tierExists(tierIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tierIndex`|`uint8`|The index of the tier to update.|
|`tierId`|`string`||
|`duration`|`uint128`|The new duration in seconds.|
|`isOpen`|`bool`|The new open status.|
|`tierURI`|`string`||


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


### setMembershipToken

Sets the membership details of a specific token.

*This function can only be called by an admin.*

*The tier must exist.*


```solidity
function setMembershipToken(uint256 tokenId, uint8 tierIndex)
    external
    onlyAdmin
    tierExists(tierIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token whose membership details are to be set.|
|`tierIndex`|`uint8`|The index of the membership tier to associate with the token.|


### getMembershipToken

Retrieves the membership details of a specific token.


```solidity
function getMembershipToken(uint256 tokenId) external view returns (MembershipToken memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token whose membership details are to be retrieved.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`MembershipToken`|The membership details of the token, represented by a `TokenMembership` struct.|


### isValid

Checks if a token has a valid membership.


```solidity
function isValid(uint256 tokenId) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the token has a valid membership, false otherwise.|


### setMaxMintable

Sets the max supply of the token.

*Only callable by admin.*

*Only callable for elastic tokens.*

*The max supply must be greater than the total minted.*


```solidity
function setMaxMintable(uint256 _maxMintable) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_maxMintable`|`uint256`|The new max supply.|


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


### totalSupply

Returns the total supply of the token.


```solidity
function totalSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The total supply of the token.|


### maxSupply

Returns the max supply of the token.


```solidity
function maxSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The max supply of the token.|


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


