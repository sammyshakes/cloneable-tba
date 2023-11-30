# TronicMain
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/41cffe407c00f76a272c977491475b582628fb23/src/TronicMain.sol)

**Inherits:**
Initializable, UUPSUpgradeable

This contract is the main contract for the Tronic ecosystem.

*This contract is upgradeable using the UUPS proxy pattern.*

*This contract is the entry point for all Tronic transactions.*


## State Variables
### owner

```solidity
address public owner;
```


### tronicAdmin

```solidity
address public tronicAdmin;
```


### tbaAccountImplementation

```solidity
address payable public tbaAccountImplementation;
```


### maxTiersPerMembership

```solidity
uint8 public maxTiersPerMembership;
```


### nftTypeStartId

```solidity
uint64 public nftTypeStartId;
```


### brandCounter

```solidity
uint256 public brandCounter;
```


### brands

```solidity
mapping(uint256 => BrandInfo) private brands;
```


### membershipCounter

```solidity
uint256 public membershipCounter;
```


### memberships

```solidity
mapping(uint256 => MembershipInfo) private memberships;
```


### _admins

```solidity
mapping(address => bool) private _admins;
```


### registry

```solidity
IERC6551Registry public registry;
```


### tronicBrandLoyalty

```solidity
ITronicBrandLoyalty public tronicBrandLoyalty;
```


### tronicMembership

```solidity
ITronicMembership public tronicMembership;
```


### tronicToken

```solidity
ITronicToken public tronicToken;
```


## Functions
### constructor


```solidity
constructor();
```

### initialize

Initializes the TronicMain contract.


```solidity
function initialize(
    address _admin,
    address _brandLoyalty,
    address _tronicMembership,
    address _tronicToken,
    address _registry,
    address _tbaImplementation,
    uint8 _maxTiersPerMembership,
    uint64 _nftTypeStartId
) public initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_admin`|`address`|The address of the Tronic admin.|
|`_brandLoyalty`|`address`|The address of the Tronic Brand Loyalty contract (ERC721 implementation).|
|`_tronicMembership`|`address`|The address of the Tronic Membership contract (ERC1155 implementation).|
|`_tronicToken`|`address`|The address of the Tronic Token contract (ERC1155 implementation).|
|`_registry`|`address`|The address of the registry contract.|
|`_tbaImplementation`|`address`|The address of the tokenbound account implementation.|
|`_maxTiersPerMembership`|`uint8`|The maximum number of tiers per membership.|
|`_nftTypeStartId`|`uint64`|The starting ID for non-fungible token types.|


### onlyOwner

Checks if the caller is the owner.


```solidity
modifier onlyOwner();
```

### onlyAdmin

Checks if the caller is an admin.


```solidity
modifier onlyAdmin();
```

### getMembershipInfo

Gets MembershipInfo for a given membership ID.

*The membership ID is the index of the membership in the memberships mapping.*


```solidity
function getMembershipInfo(uint256 membershipId) public view returns (MembershipInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`membershipId`|`uint256`|The ID of the membership to get info for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`MembershipInfo`|The MembershipInfo struct for the given membership ID.|


### getBrandInfo

Gets BrandInfo for a given membership ID.

*The membership ID is the index of the membership in the memberships mapping.*


```solidity
function getBrandInfo(uint256 brandId) public view returns (BrandInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`brandId`|`uint256`|The ID of the membership to get info for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`BrandInfo`|The BrandInfo struct for the given membership ID.|


### deployMembership

Deploys a new membership's contracts.

*The membership ID is the index of the membership in the memberships mapping.*


```solidity
function deployMembership(
    uint256 brandId,
    string calldata membershipName,
    string calldata membershipSymbol,
    string calldata membershipBaseURI,
    uint256 maxMintable,
    bool isElastic,
    ITronicMembership.MembershipTier[] calldata tiers
) external onlyAdmin returns (uint256 membershipId, address membershipAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`brandId`|`uint256`|The ID of the brand to create the membership for.|
|`membershipName`|`string`|The membership name for the Membership token.|
|`membershipSymbol`|`string`|The membership symbol for the Brand Loyalty token.|
|`membershipBaseURI`|`string`|The base URI for the membership Brand Loyalty token.|
|`maxMintable`|`uint256`|The maximum number of brand loyalty tokens that can be minted.|
|`isElastic`|`bool`|Whether or not the brand loyalty token is elastic.|
|`tiers`|`ITronicMembership.MembershipTier[]`|The tiers to create for the membership.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`membershipId`|`uint256`|The ID of the newly created membership.|
|`membershipAddress`|`address`|The address of the deployed membership ERC1155 contract.|


### deployBrand

Deploys a new Brand's Loyalty and Achievement Token contracts.

*The brand ID is the index of the brand in the brands mapping.*


```solidity
function deployBrand(
    string calldata brandName,
    string calldata brandSymbol,
    string calldata brandBaseURI,
    bool isBound
) external onlyAdmin returns (uint256 brandId, address brandLoyaltyAddress, address tokenAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`brandName`|`string`|The name for the Brand Loyalty token.|
|`brandSymbol`|`string`|The symbol for the Brand Loyalty token.|
|`brandBaseURI`|`string`|The base URI for the Brand Loyalty token.|
|`isBound`|`bool`|Whether or not the brand loyalty token is bound.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`brandId`|`uint256`|The ID of the newly created brand.|
|`brandLoyaltyAddress`|`address`|The address of the deployed brand loyalty Brand Loyalty contract.|
|`tokenAddress`|`address`|The address of the deployed token ERC1155 contract.|


### _deployBrandLoyalty

Clones the Tronic Brand Loyalty (ERC721) implementation and initializes it.


```solidity
function _deployBrandLoyalty(
    string calldata brandName,
    string calldata brandSymbol,
    string calldata brandBaseURI,
    bool isBound
) private onlyAdmin returns (address brandLoyaltyAddress);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`brandLoyaltyAddress`|`address`|The address of the newly cloned Brand Loyalty contract.|


### _deployMembership

Clones the Tronic Membership (ERC721) implementation and initializes it.


```solidity
function _deployMembership(
    uint256 membershipId,
    string calldata name,
    string calldata symbol,
    string calldata baseURI,
    uint256 maxMintable,
    bool isElastic
) private returns (address membershipAddress);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`membershipAddress`|`address`|The address of the newly cloned Membership contract.|


### _deployToken

Clones the ERC1155 implementation and initializes it.


```solidity
function _deployToken() private returns (address tokenAddress);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tokenAddress`|`address`|The address of the newly cloned ERC1155 contract.|


### removeMembership

Removes a membership from the contract.


```solidity
function removeMembership(uint256 _membershipId) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`|The ID of the membership to remove.|


### createFungibleTokenType

Creates a new ERC1155 fungible token type for a membership.


```solidity
function createFungibleTokenType(uint256 brandId, uint256 maxSupply, string memory uri)
    external
    onlyAdmin
    returns (uint256 typeId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`brandId`|`uint256`|The ID of the brand to create the token type for.|
|`maxSupply`|`uint256`|The maximum supply of the token type.|
|`uri`|`string`|The URI for the token type.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`typeId`|`uint256`|The ID of the newly created token type.|


### createNonFungibleTokenType

Creates a new ERC1155 non-fungible token type for a membership.


```solidity
function createNonFungibleTokenType(uint256 brandId, string memory baseUri, uint64 maxMintable)
    external
    onlyAdmin
    returns (uint256 nftTypeID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`brandId`|`uint256`|The ID of the brand to create the token type for.|
|`baseUri`|`string`|The URI for the token type.|
|`maxMintable`|`uint64`|The maximum number of tokens that can be minted.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`nftTypeID`|`uint256`|The ID of the newly created token type.|


### mintBrandLoyaltyToken

Mints a new Brand Loyalty token.


```solidity
function mintBrandLoyaltyToken(address _recipient, uint256 _brandId)
    external
    onlyAdmin
    returns (address payable tbaAccount, uint256 brandTokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address to mint the token to.|
|`_brandId`|`uint256`|The ID of the membership to mint the token for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tbaAccount`|`address payable`|The payable address of the created tokenbound account.|
|`brandTokenId`|`uint256`|The ID of the newly minted token.|


### mintMembership

Mints a new Membership token for a specified brand.


```solidity
function mintMembership(address _recipient, uint256 _membershipId, uint8 _tierIndex)
    external
    onlyAdmin
    returns (uint256 tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address to mint the token to.|
|`_membershipId`|`uint256`|The ID of the membership to mint the token for.|
|`_tierIndex`|`uint8`|The index of the membership tier to associate with the token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The ID of the newly minted token.|


### _assignMembershipTier

Assigns a membership tier details of a specific token.

*This function can only be called by an admin.*

*The tier must exist.*

*The token must exist.*


```solidity
function _assignMembershipTier(address _membershipAddress, uint8 _tierIndex, uint256 _tokenId)
    private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipAddress`|`address`||
|`_tierIndex`|`uint8`|The index of the membership tier to associate with the token.|
|`_tokenId`|`uint256`|The ID of the token whose membership details are to be set.|


### createMembershipTier

Creates a new membership tier.

*This function can only be called by an admin.*

*The membership must exist.*


```solidity
function createMembershipTier(
    uint256 _membershipId,
    string memory _tierId,
    uint128 _duration,
    bool _isOpen,
    string memory _tierURI
) external onlyAdmin returns (uint8 tierIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`|The ID of the membership to create the tier for.|
|`_tierId`|`string`|The ID of the tier.|
|`_duration`|`uint128`|The duration of the tier.|
|`_isOpen`|`bool`|Whether or not the tier is open.|
|`_tierURI`|`string`|The URI of the tier.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`tierIndex`|`uint8`|The index of the newly created tier.|


### setMembershipTier

Sets the details of a membership tier.

*This function can only be called by an admin.*

*The membership must exist.*

*The tier must exist.*


```solidity
function setMembershipTier(
    uint256 _membershipId,
    uint8 _tierIndex,
    string memory _tierId,
    uint128 _duration,
    bool _isOpen,
    string memory _tierURI
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`|The ID of the membership to set the tier for.|
|`_tierIndex`|`uint8`|The index of the tier to set.|
|`_tierId`|`string`|The ID of the tier.|
|`_duration`|`uint128`|The duration of the tier.|
|`_isOpen`|`bool`|Whether or not the tier is open.|
|`_tierURI`|`string`|The URI of the tier.|


### getMembershipTierInfo

Gets the details of a membership tier.

*The membership must exist.*

*The tier must exist.*


```solidity
function getMembershipTierInfo(uint256 _membershipId, uint8 _tierIndex)
    external
    view
    returns (ITronicMembership.MembershipTier memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`|The ID of the membership to get the tier for.|
|`_tierIndex`|`uint8`|The index of the tier to get.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`ITronicMembership.MembershipTier`|The details of the membership tier.|


### getTierIndexByTierId

Retrieves tier index of a given tier ID.

*Returns 0 if the tier does not exist.*


```solidity
function getTierIndexByTierId(uint256 _membershipId, string memory tierId)
    external
    view
    returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`||
|`tierId`|`string`|The ID of the tier.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|The index of the tier.|


### mintFungibleToken

Mints a fungible ERC1155 token.


```solidity
function mintFungibleToken(uint256 _brandId, address _recipient, uint256 _tokenId, uint64 _amount)
    external
    onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_brandId`|`uint256`|The ID of the brand to mint the token for.|
|`_recipient`|`address`|The address to mint the token to.|
|`_tokenId`|`uint256`|The tokenID (same as typeID for fungibles) of the token to mint.|
|`_amount`|`uint64`|The amount of the token to mint.|


### mintNonFungibleToken

Mints a new nonfungible ERC1155 token.


```solidity
function mintNonFungibleToken(
    uint256 _brandId,
    address _recipient,
    uint256 _typeId,
    uint256 _amount
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_brandId`|`uint256`|The ID of the brand to mint the token for.|
|`_recipient`|`address`|The address to mint the token to.|
|`_typeId`|`uint256`|The typeID of the NFT to mint.|
|`_amount`|`uint256`|The amount of NFTs to mint.|


### transferMembershipFromBrandLoyaltyTBA

Processes multiple minting operations for both ERC1155 and ERC721 tokens on behalf of memberships.

transfers Membership token from a brand loyalty TBA to a specified address

*Requires that all input arrays have matching lengths.
For ERC721 minting, the inner arrays of _tokenTypes and _amounts should have a length of 1.*

*array indexes: _tokenTypeIDs[membershipId][recipient][contractType][tokenTypeIDs]*

*array indexes: _amounts[membershipId][recipient][contractType][amounts]*

*This contract address must be granted permissions to transfer tokens from the Brand Loyalty token TBA*

*The membership token must be owned by the Brand Loyalty token TBA*


```solidity
function transferMembershipFromBrandLoyaltyTBA(
    uint256 _loyaltyTokenId,
    uint256 _membershipId,
    uint256 _membershipTokenId,
    address _to
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_loyaltyTokenId`|`uint256`|The ID of the brand loyalty token that owns the TBA|
|`_membershipId`|`uint256`|The membership ID of the membership token to be transferred|
|`_membershipTokenId`|`uint256`|The tokenID of the membership token to be transferred|
|`_to`|`address`|The address to transfer the membership to|


### transferTokensFromBrandLoyaltyTBA

transfers tokens from a Brand Loyalty TBA to a specified address

*This contract address must be granted permissions to transfer tokens from the Brand Loyalty TBA*

*This function is only callable by the tronic admin or an authorized account*


```solidity
function transferTokensFromBrandLoyaltyTBA(
    uint256 _brandId,
    address _brandLoyaltyTbaAddress,
    address _to,
    uint256 _transferTokenId,
    uint256 _amount
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_brandId`|`uint256`|The ID of the brand|
|`_brandLoyaltyTbaAddress`|`address`|The address of the Brand Loyalty TBA|
|`_to`|`address`|The address to transfer the tokens to|
|`_transferTokenId`|`uint256`|The ID of the token to transfer|
|`_amount`|`uint256`|The amount of tokens to transfer|


### getBrandLoyaltyTBA

Gets the address of the tokenbound account for a given brand loyalty token.


```solidity
function getBrandLoyaltyTBA(uint256 _brandId, uint256 _brandLoyaltyTokenId)
    external
    view
    returns (address payable brandLoyaltyTbaAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_brandId`|`uint256`|The ID of the brand.|
|`_brandLoyaltyTokenId`|`uint256`|The ID of the brand loyalty token.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`brandLoyaltyTbaAddress`|`address payable`|The address of the tokenbound account.|


### getBrandIdFromBrandLoyaltyAddress

Gets the brand ID for a given brand loyalty address.


```solidity
function getBrandIdFromBrandLoyaltyAddress(address _brandLoyaltyAddress)
    external
    view
    returns (uint256 brandId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_brandLoyaltyAddress`|`address`|The address of the brand loyalty contract.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`brandId`|`uint256`|The ID of the brand.|


### getBrandIdFromMembershipId

Gets the brand ID for a given membership ID.


```solidity
function getBrandIdFromMembershipId(uint256 _membershipId)
    external
    view
    returns (uint256 brandId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`|The ID of the membership.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`brandId`|`uint256`|The ID of the brand.|


### setLoyaltyTokenImplementation

Sets the Tronic Loyalty contract address, callable only by the owner.


```solidity
function setLoyaltyTokenImplementation(address newImplementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|The address of the new Tronic Loyalty implementation.|


### setMembershipImplementation

Sets the Membership implementation address, callable only by the owner.


```solidity
function setMembershipImplementation(address newImplementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|The address of the new Tronic Membership implementation.|


### setTokenImplementation

Sets the Achievement Token implementation address, callable only by the owner.


```solidity
function setTokenImplementation(address newImplementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|The address of the new Tronic Token implementation.|


### setAccountImplementation

Sets the account implementation address, callable only by the owner.


```solidity
function setAccountImplementation(address payable newImplementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address payable`|The address of the new account implementation.|


### setRegistry

Sets the registry address, callable only by the owner.


```solidity
function setRegistry(address newRegistry) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newRegistry`|`address`|The address of the new registry.|


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


### _authorizeUpgrade

Upgrades the contract to a new implementation.

*This function is required for UUPSUpgradeable.*

*This function is only callable by the owner.*


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|The address of the new implementation.|


## Events
### MembershipMinted
The event emitted when a membership is minted.


```solidity
event MembershipMinted(
    uint256 indexed membershipId, uint256 indexed tokenId, address indexed recipientAddress
);
```

### LoyaltyTokenMinted
The event emitted when a brand loyalty token is minted.


```solidity
event LoyaltyTokenMinted(
    uint256 indexed brandId,
    uint256 indexed tokenId,
    address indexed recipientAddress,
    address tbaAccount
);
```

### TierAssigned
The event emitted when a membership tier is assigned to a token.


```solidity
event TierAssigned(
    address indexed membershipAddress, uint256 indexed tokenId, uint256 indexed tierIndex
);
```

### MembershipAdded
The event emitted when a membership is added.


```solidity
event MembershipAdded(
    uint256 indexed brandId, uint256 indexed membershipId, address indexed membershipAddress
);
```

### BrandAdded
The event emitted when a brand is added.


```solidity
event BrandAdded(
    uint256 indexed brandId,
    string brandName,
    address indexed brandLoyaltyAddress,
    address indexed tokenAddress
);
```

### MembershipRemoved
The event emitted when a membership is removed.


```solidity
event MembershipRemoved(uint256 indexed membershipId);
```

### FungibleTokenTypeCreated
The event emitted when a fungible token type is created.


```solidity
event FungibleTokenTypeCreated(uint256 indexed brandId, uint256 indexed tokenId);
```

### NonFungibleTokenTypeCreated
The event emitted when a non-fungible token type is created.


```solidity
event NonFungibleTokenTypeCreated(
    uint256 indexed brandId, uint256 indexed tokenId, uint256 maxMintable, string uri
);
```

## Structs
### BrandInfo
The struct for membership information.

*The membership ID is the index of the membership in the memberships mapping.*


```solidity
struct BrandInfo {
    string brandName;
    address brandLoyaltyAddress;
    address tokenAddress;
    uint256[] membershipIds;
}
```

### MembershipInfo
The struct for membership information.

*The membership ID is the index of the membership in the memberships mapping.*


```solidity
struct MembershipInfo {
    uint256 brandId;
    string membershipName;
    address membershipAddress;
}
```

## Enums
### TokenType
The enum for token type.


```solidity
enum TokenType {
    ERC1155,
    ERC721
}
```

