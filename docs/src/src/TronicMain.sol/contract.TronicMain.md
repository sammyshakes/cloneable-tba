# TronicMain
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/aba5391f4163381727c241bd74844bf5ae213d0f/src/TronicMain.sol)

**Inherits:**
Initializable, UUPSUpgradeable


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


### tronicMembership

```solidity
ITronicMembership public tronicMembership;
```


### tronicERC1155

```solidity
ITronicToken public tronicERC1155;
```


## Functions
### initialize

Initializes the TronicMain contract.


```solidity
function initialize(
    address _admin,
    address _tronicMembership,
    address _tronicToken,
    address _registry,
    address _tbaImplementation,
    uint8 _maxTiersPerMembership
) public initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_admin`|`address`|The address of the Tronic admin.|
|`_tronicMembership`|`address`|The address of the Tronic Membership contract (ERC721 implementation).|
|`_tronicToken`|`address`|The address of the Tronic Token contract (ERC1155 implementation).|
|`_registry`|`address`|The address of the registry contract.|
|`_tbaImplementation`|`address`|The address of the tokenbound account implementation.|
|`_maxTiersPerMembership`|`uint8`||


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
function getMembershipInfo(uint256 membershipId) external view returns (MembershipInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`membershipId`|`uint256`|The ID of the membership to get info for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`MembershipInfo`|The MembershipInfo struct for the given membership ID.|


### deployMembership

Deploys a new membership's contracts.

*The membership ID is the index of the membership in the memberships mapping.*


```solidity
function deployMembership(
    string memory membershipName,
    string memory membershipSymbol,
    string memory membershipBaseURI,
    uint256 maxMintable,
    bool isElastic,
    bool isBound,
    string[] memory tierIds,
    uint128[] memory durations,
    bool[] memory isOpens
) external onlyAdmin returns (uint256 memberId, address membershipAddress, address tokenAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`membershipName`|`string`|The membership name for the ERC721 token.|
|`membershipSymbol`|`string`|The membership symbol for the ERC721 token.|
|`membershipBaseURI`|`string`|The base URI for the membership ERC721 token.|
|`maxMintable`|`uint256`|The maximum number of memberships that can be minted.|
|`isElastic`|`bool`||
|`isBound`|`bool`||
|`tierIds`|`string[]`||
|`durations`|`uint128[]`||
|`isOpens`|`bool[]`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`memberId`|`uint256`|The ID of the newly created membership.|
|`membershipAddress`|`address`|The address of the deployed membership ERC721 contract.|
|`tokenAddress`|`address`|The address of the deployed token ERC1155 contract.|


### _deployMembership

Clones the Tronic Membership (ERC721) implementation and initializes it.


```solidity
function _deployMembership(
    string memory name,
    string memory symbol,
    string memory uri,
    uint256 maxSupply,
    bool isElastic,
    bool isBound
) private returns (address membershipAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name`|`string`|The name of the token.|
|`symbol`|`string`|The symbol of the token.|
|`uri`|`string`|The URI for the cloned contract.|
|`maxSupply`|`uint256`|The maximum supply of the token. If no maxSupply is desired, set to MaxValue.|
|`isElastic`|`bool`|Whether or not the token maxSupply is elastic.|
|`isBound`|`bool`|Whether or not the token is soulbound (non-transferable).|

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
function createFungibleTokenType(uint256 maxSupply, string memory uri, uint256 membershipId)
    external
    onlyAdmin
    returns (uint256 typeId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`maxSupply`|`uint256`|The maximum supply of the token type.|
|`uri`|`string`|The URI for the token type.|
|`membershipId`|`uint256`|The ID of the membership to create the token type for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`typeId`|`uint256`|The ID of the newly created token type.|


### createNonFungibleTokenType

Creates a new ERC1155 non-fungible token type for a membership.


```solidity
function createNonFungibleTokenType(string memory baseUri, uint64 maxMintable, uint256 membershipId)
    external
    onlyAdmin
    returns (uint256 nftTypeID);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`baseUri`|`string`|The URI for the token type.|
|`maxMintable`|`uint64`|The maximum number of tokens that can be minted.|
|`membershipId`|`uint256`|The ID of the membership to create the token type for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`nftTypeID`|`uint256`|The ID of the newly created token type.|


### mintMembership

Mints a new ERC721 token for a specified membership.


```solidity
function mintMembership(address _recipient, uint256 _membershipId, uint8 _tierIndex)
    external
    onlyAdmin
    returns (address payable, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_recipient`|`address`|The address to mint the token to.|
|`_membershipId`|`uint256`|The ID of the membership to mint the token for.|
|`_tierIndex`|`uint8`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address payable`|The address of the newly created token account.|
|`<none>`|`uint256`||


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
    bool _isOpen
) external onlyAdmin returns (uint8 tierIndex);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`|The ID of the membership to create the tier for.|
|`_tierId`|`string`|The ID of the tier.|
|`_duration`|`uint128`|The duration of the tier.|
|`_isOpen`|`bool`|Whether or not the tier is open.|

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
    bool _isOpen
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
function mintFungibleToken(
    uint256 _membershipId,
    address _recipient,
    uint256 _tokenId,
    uint64 _amount
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`|The ID of the membership to mint the token for.|
|`_recipient`|`address`|The address to mint the token to.|
|`_tokenId`|`uint256`|The tokenID (same as typeID for fungibles) of the token to mint.|
|`_amount`|`uint64`|The amount of the token to mint.|


### mintNonFungibleToken

Mints a new nonfungible ERC1155 token.


```solidity
function mintNonFungibleToken(
    uint256 _membershipId,
    address _recipient,
    uint256 _typeId,
    uint256 _amount
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipId`|`uint256`|The ID of the membership to mint the token for.|
|`_recipient`|`address`|The address to mint the token to.|
|`_typeId`|`uint256`|The typeID of the NFT to mint.|
|`_amount`|`uint256`|The amount of NFTs to mint.|


### batchProcess

Processes multiple minting operations for both ERC1155 and ERC721 tokens on behalf of memberships.

*Requires that all input arrays have matching lengths.
For ERC721 minting, the inner arrays of _tokenTypes and _amounts should have a length of 1.*

*array indexes: _tokenTypeIDs[membershipId][recipient][contractType][tokenTypeIDs]*

*array indexes: _amounts[membershipId][recipient][contractType][amounts]*


```solidity
function batchProcess(
    uint256[] memory _membershipIds,
    address[][] memory _recipients,
    uint256[][][][] memory _tokenTypeIDs,
    uint256[][][][] memory _amounts,
    TokenType[][][] memory _contractTypes
) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_membershipIds`|`uint256[]`|  Array of membership IDs corresponding to each minting operation.|
|`_recipients`|`address[][]`|  2D array of recipient addresses for each minting operation.|
|`_tokenTypeIDs`|`uint256[][][][]`|    4D array of token TypeIDs to mint for each membership. For ERC1155, it could be multiple IDs, and for ERC721, it should contain a single ID.|
|`_amounts`|`uint256[][][][]`|     4D array of token amounts to mint for each membership. For ERC1155, it represents the quantities of each token ID, and for ERC721, it should be either [1] (to mint) or [0] (to skip).|
|`_contractTypes`|`TokenType[][][]`|  3D array specifying the type of each token contract (either ERC1155 or ERC721) to determine the minting logic.|


### transferTokensFromMembershipTBA

transfers tokens from a membership TBA to a specified address

*This contract address must be granted permissions to transfer tokens from the membership TBA*

*The membership TBA must be owned by the Tronic tokenId TBA*

*This function is only callable by the tronic admin or an authorized account*


```solidity
function transferTokensFromMembershipTBA(
    uint256 _tronicTokenId,
    uint256 _membershipId,
    uint256 _membershipTokenId,
    address _to,
    uint256 _transferTokenId,
    uint256 _amount
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tronicTokenId`|`uint256`|The ID of the tronic token that owns the Tronic TBA|
|`_membershipId`|`uint256`|The ID of the membership that issued the membership TBA|
|`_membershipTokenId`|`uint256`|The ID of the membership TBA|
|`_to`|`address`|The address to transfer the tokens to|
|`_transferTokenId`|`uint256`|The ID of the token to transfer|
|`_amount`|`uint256`|The amount of tokens to transfer|


### transferTokensFromTronicTBA

transfers tokens from a tronic TBA to a specified address

*This contract address must be granted permissions to transfer tokens from the Tronic token TBA*

*The tronic TBA must be owned by the Tronic tokenId TBA*

*This function is only callable by the tronic admin or an authorized account*


```solidity
function transferTokensFromTronicTBA(
    uint256 _tronicTokenId,
    uint256 _transferTokenId,
    uint256 _amount,
    address _to
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tronicTokenId`|`uint256`|The ID of the tronic token that owns the Tronic TBA|
|`_transferTokenId`|`uint256`|The ID of the token to transfer|
|`_amount`|`uint256`|The amount of tokens to transfer|
|`_to`|`address`|The address to transfer the tokens to|


### transferMembershipFromTronicTBA

transfers membership from a tronic TBA to a specified address

*This contract address must be granted permissions to transfer tokens from the Tronic token TBA*

*The membership token TBA must be owned by the Tronic token TBA*


```solidity
function transferMembershipFromTronicTBA(
    uint256 _tronicTokenId,
    uint256 _membershipId,
    uint256 _membershipTokenId,
    address _to
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tronicTokenId`|`uint256`|The ID of the tronic token that owns the Tronic TBA|
|`_membershipId`|`uint256`|The ID of the membership that issued the membership TBA|
|`_membershipTokenId`|`uint256`|The ID of the membership TBA|
|`_to`|`address`|The address to transfer the membership to|


### setERC721Implementation

Sets the ERC721 implementation address, callable only by the owner.


```solidity
function setERC721Implementation(address newImplementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|The address of the new ERC721 implementation.|


### setERC1155Implementation

Sets the ERC1155 implementation address, callable only by the owner.


```solidity
function setERC1155Implementation(address newImplementation) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newImplementation`|`address`|The address of the new ERC1155 implementation.|


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
    address indexed membershipAddress, address indexed recipientAddress, uint256 indexed tokenId
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
    uint256 indexed membershipId, address indexed membershipAddress, address indexed tokenAddress
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
event FungibleTokenTypeCreated(uint256 indexed tokenId);
```

## Structs
### MembershipInfo
The struct for membership information.

*The membership ID is the index of the membership in the memberships mapping.*


```solidity
struct MembershipInfo {
    address membershipAddress;
    address tokenAddress;
    string membershipName;
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

