# ITronicMembership
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/69000936679381ac7b4b9436ba05974e252ee19a/src/interfaces/ITronicMembership.sol)


## Functions
### initialize


```solidity
function initialize(
    string memory name_,
    string memory symbol_,
    string memory uri,
    uint256 _maxSupply,
    bool _isElastic,
    uint8 _maxMembershipTiers,
    address tronicAdmin
) external;
```

### mint


```solidity
function mint(address to, uint8 tierIndex) external returns (uint256 tokenId);
```

### createMembershipTier


```solidity
function createMembershipTier(
    string memory tierId,
    uint128 duration,
    bool isOpen,
    string calldata tierURI
) external returns (uint8 tierIndex);
```

### createMembershipTiers


```solidity
function createMembershipTiers(MembershipTier[] calldata tiers) external;
```

### setMembershipTier


```solidity
function setMembershipTier(
    uint8 tierIndex,
    string calldata tierId,
    uint128 duration,
    bool isOpen,
    string calldata tierURI
) external;
```

### getMembershipTierDetails


```solidity
function getMembershipTierDetails(uint8 tierIndex) external view returns (MembershipTier memory);
```

### getMembershipTierId


```solidity
function getMembershipTierId(uint8 tierIndex) external view returns (string memory);
```

### setMembershipToken


```solidity
function setMembershipToken(uint256 tokenId, uint8 tierIndex) external;
```

### getMembershipToken


```solidity
function getMembershipToken(uint256 tokenId) external view returns (MembershipToken memory);
```

### getTierIndexByTierId


```solidity
function getTierIndexByTierId(string memory tierId) external view returns (uint8);
```

## Structs
### MembershipTier
*Struct representing a membership tier.*


```solidity
struct MembershipTier {
    string tierId;
    uint128 duration;
    bool isOpen;
    string tierURI;
}
```

### MembershipToken
*Struct representing the membership details of a token.*


```solidity
struct MembershipToken {
    uint8 tierIndex;
    uint128 timestamp;
}
```

