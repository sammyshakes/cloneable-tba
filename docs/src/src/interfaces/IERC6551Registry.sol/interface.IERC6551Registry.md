# IERC6551Registry
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/69000936679381ac7b4b9436ba05974e252ee19a/src/interfaces/IERC6551Registry.sol)


## Functions
### createAccount

*Creates a token bound account for a non-fungible token
If account has already been created, returns the account address without calling create2
If initData is not empty and account has not yet been created, calls account with
provided initData after creation
Emits AccountCreated event*


```solidity
function createAccount(
    address implementation,
    uint256 chainId,
    address tokenContract,
    uint256 tokenId,
    uint256 seed,
    bytes calldata initData
) external returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|the address of the account|


### account

*Returns the computed token bound account address for a non-fungible token*


```solidity
function account(
    address implementation,
    uint256 chainId,
    address tokenContract,
    uint256 tokenId,
    uint256 salt
) external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The computed address of the token bound account|


## Events
### AccountCreated
*The registry SHALL emit the AccountCreated event upon successful account creation*


```solidity
event AccountCreated(
    address account,
    address indexed implementation,
    uint256 chainId,
    address indexed tokenContract,
    uint256 indexed tokenId,
    uint256 salt
);
```

