# IERC6551Account
[Git Source](https://github.com/sammyshakes/cloneable-tba/blob/41cffe407c00f76a272c977491475b582628fb23/src/interfaces/IERC6551Account.sol)

*the ERC-165 identifier for this interface is `0x6faff5f1`*


## Functions
### receive

*Allows the account to receive Ether
Accounts MUST implement a `receive` function
Accounts MAY perform arbitrary logic to restrict conditions
under which Ether can be received*


```solidity
receive() external payable;
```

### token

*Returns the identifier of the non-fungible token which owns the account
The return value of this function MUST be constant - it MUST NOT change over time*


```solidity
function token() external view returns (uint256 chainId, address tokenContract, uint256 tokenId);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`chainId`|`uint256`|      The EIP-155 ID of the chain the token exists on|
|`tokenContract`|`address`|The contract address of the token|
|`tokenId`|`uint256`|      The ID of the token|


### state

*Returns a value that SHOULD be modified each time the account changes state*


```solidity
function state() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The current account state|


### isValidSigner

*Returns a magic value indicating whether a given signer is authorized to act on behalf
of the account
MUST return the bytes4 magic value 0x523e3260 if the given signer is valid
By default, the holder of the non-fungible token the account is bound to MUST be considered
a valid signer
Accounts MAY implement additional authorization logic which invalidates the holder as a
signer or grants signing permissions to other non-holder accounts*


```solidity
function isValidSigner(address signer, bytes calldata context)
    external
    view
    returns (bytes4 magicValue);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`signer`|`address`|    The address to check signing authorization for|
|`context`|`bytes`|   Additional data used to determine whether the signer is valid|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`magicValue`|`bytes4`|Magic value indicating whether the signer is valid|


### executeCall


```solidity
function executeCall(address to, uint256 value, bytes calldata data)
    external
    payable
    returns (bytes memory);
```

### owner


```solidity
function owner() external view returns (address);
```

### isAuthorized


```solidity
function isAuthorized(address caller) external view returns (bool);
```

### setPermissions


```solidity
function setPermissions(address[] calldata callers, bool[] calldata _permissions) external;
```

