# ITronicMembership
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/aba5391f4163381727c241bd74844bf5ae213d0f/src/interfaces/ITronicMembership.sol)


## Functions
### initialize


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
) external;
```

### mint


```solidity
function mint(address to) external returns (address payable tbaAccount, uint256);
```

### createMembershipTier


```solidity
function createMembershipTier(string memory tierId, uint128 duration, bool isOpen)
    external
    returns (uint8 tierIndex);
```

### createMembershipTiers


```solidity
function createMembershipTiers(
    string[] memory tierIds,
    uint128[] memory durations,
    bool[] memory isOpens
) external;
```

### setMembershipTier


```solidity
function setMembershipTier(uint8 tierIndex, string calldata tierId, uint128 duration, bool isOpen)
    external;
```

### getMembershipTierDetails


```solidity
function getMembershipTierDetails(uint8 tierIndex) external view returns (MembershipTier memory);
```

### getMembershipTierId


```solidity
function getMembershipTierId(uint8 tierIndex) external view returns (string memory);
```

### setTokenMembership


```solidity
function setTokenMembership(uint256 tokenId, uint8 tierIndex) external;
```

### getTokenMembership


```solidity
function getTokenMembership(uint256 tokenId) external view returns (TokenMembership memory);
```

### getTBAccount


```solidity
function getTBAccount(uint256 tokenId) external view returns (address);
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
}
```

### TokenMembership
*Struct representing the membership details of a token.*


```solidity
struct TokenMembership {
    uint8 tierIndex;
    uint128 timestamp;
}
```

