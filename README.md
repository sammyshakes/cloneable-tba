# Tronic Membership Contract Scenario

## Deploy Initial Contracts

### Deploys:

- Tokenbound Account Implementation
- Main Tronic Member Nft Contract (cloneable ERC721)
- Cloneable ERC1155 Contract Template
- Tokenbound Registry Contract

```js
forge script script/Deploy.s.sol:Deploy -vvvv --rpc-url goerli --broadcast
```

```bash
# testnet contract addresses
TOKENBOUND_ACCOUNT_ADDRESS=0xCB732ebe48daaf08E9F7C3d14968a5F1E72A045A
ERC721_CLONEABLE_ADDRESS=0xe931e45265b58a77328B0c0bABcb6Af417c18154
ERC1155_CLONEABLE_ADDRESS=0x1AEaFDcfb6b7E0322023FC58cf91B34D3076B21d
ERC6551_REGISTRY_ADDRESS=0xb6F028F59c95F09331776069ccd2bEf85b0C2b1E

```

## Verify Contracts

### Verfiy Tokenbound Account

```js
forge verify-contract --chain-id 5 --watch 0xCB732ebe48daaf08E9F7C3d14968a5F1E72A045A --etherscan-api-key goerli src/TokenboundAccount.sol:TokenboundAccount
```

### Verfiy ERC721

```js
forge verify-contract --chain-id 5 --watch 0xe931e45265b58a77328B0c0bABcb6Af417c18154 --etherscan-api-key goerli src/ERC721CloneableTBA.sol:ERC721CloneableTBA
```

### Verfiy ERC1155

```js
forge verify-contract --chain-id 5 --watch 0x1b4A7aAab32D2D44Ba8b412B8c2EF6801B0dFc5F --etherscan-api-key goerli src/ERC1155Cloneable.sol:ERC1155Cloneable
```

### Verfiy ERC6551Registry

```js
forge verify-contract --chain-id 5 --watch 0xb6F028F59c95F09331776069ccd2bEf85b0C2b1E --etherscan-api-key goerli src/erc6551/ERC6551Registry.sol:ERC6551Registry
```

## Deploy CloneFactory.sol and initialize Tronic ERC721

- Deploys `CloneFactory.sol`
- Initializes Tronic Member Nft Contract

```js
forge script script/DeployCloneFactory.s.sol:DeployCloneFactory -vvvv --rpc-url goerli --broadcast
```

```bash
# deployed clone factory address
CLONE_FACTORY_TESTNET_ADDRESS=0x6340E5F51799B17323e1Da683b0397022e80255d
```

### Verify CloneFactory

```js
forge verify-contract --chain-id 5 --watch 0x6340E5F51799B17323e1Da683b0397022e80255d --constructor-args $(cast abi-encode "constructor(address,address,address,address,address)" 0x42C7eF198f8aC9888E2B1b73e5B71f1D4535194A 0xe931e45265b58a77328B0c0bABcb6Af417c18154 0x1AEaFDcfb6b7E0322023FC58cf91B34D3076B21d 0xb6F028F59c95F09331776069ccd2bEf85b0C2b1E 0xCB732ebe48daaf08E9F7C3d14968a5F1E72A045A) --etherscan-api-key goerli src/CloneFactory.sol:CloneFactory
```

## Deploy New Project/Partner/Brand

- Clones a partner ERC1155

```bash
forge script script/NewProjectEntry.s.sol:NewProjectEntry -vvvv --rpc-url goerli --broadcast
```

```bash
# deployed partner erc1155 clone address
CLONED_ERC1155_ADDRESS=0x2f51072d0E2524f9E517F9d44aAa87e56403a239
```

## New User Entry

- Mints a new Tronic MemberNFT to user (Tokenbound Account)
- Mints Partner ERC1155 loyalty points to users tba

```bash
forge script script/NewUserEntry.s.sol:NewUserEntry -vvvv --rpc-url goerli --broadcast
```
