# Tronic Membership Contract Scenario

## Deploy Initial Contracts

### Deploys:

- Main Tronic Member Nft Contract (cloneable ERC721)
- Cloneable ERC1155 Contract Template

```js
forge script script/Deploy.s.sol:Deploy -vvvv --rpc-url goerli --broadcast
```

```bash
# testnet contract addresses
TOKENBOUND_DEFAULT_ACCOUNT_ADDRESS=0x2d25602551487c3f3354dd80d76d54383a243358
ERC721_CLONEABLE_ADDRESS=0xe22CdB0145301d107F244bC8eA33080C42556cB1
ERC1155_CLONEABLE_ADDRESS=0x6e2a39419e786d7543922FDF75C1Fe05D4f32C0F
ERC6551_REGISTRY_ADDRESS=0x02101dfB77FDE026414827Fdc604ddAF224F0921

```

## Verify Contracts

### Verfiy ERC721

```js
forge verify-contract --chain-id 5 --watch 0xe22CdB0145301d107F244bC8eA33080C42556cB1 --etherscan-api-key goerli src/ERC721CloneableTBA.sol:ERC721CloneableTBA
```

### Verfiy ERC1155

```js
forge verify-contract --chain-id 5 --watch 0x6e2a39419e786d7543922FDF75C1Fe05D4f32C0F --etherscan-api-key goerli src/ERC1155Cloneable.sol:ERC1155Cloneable
```

## Deploy and verify CloneFactory.sol and initialize Tronic ERC721

- Deploys `CloneFactory.sol`
- Initializes Tronic Member Nft Contract

```js
forge script script/DeployCloneFactory.s.sol:DeployCloneFactory -vvvv --rpc-url goerli --broadcast --verify
```

```bash
# deployed clone factory address
CLONE_FACTORY_TESTNET_ADDRESS=0x8Cd4382eFC7A2033dc69d6A45406620dECe2bc71
```

### Verify CloneFactory (only if verification fails in previous step)

```js
forge verify-contract --chain-id 5 --watch 0x6340E5F51799B17323e1Da683b0397022e80255d --constructor-args $(cast abi-encode "constructor(address,address,address,address,address)" 0x42C7eF198f8aC9888E2B1b73e5B71f1D4535194A 0xe931e45265b58a77328B0c0bABcb6Af417c18154 0x1AEaFDcfb6b7E0322023FC58cf91B34D3076B21d 0xb6F028F59c95F09331776069ccd2bEf85b0C2b1E 0xCB732ebe48daaf08E9F7C3d14968a5F1E72A045A) --etherscan-api-key goerli src/CloneFactory.sol:CloneFactory
```

## Deploy New Project/Partner/Brand (Project X)

- Clones a partner ERC1155 to Project X

```bash
forge script script/NewProjectEntry.s.sol:NewProjectEntry -vvvv --rpc-url goerli --broadcast
```

```bash
# deployed partner erc1155 clone address
CLONED_ERC1155_ADDRESS=0x197179FD63926FfD46F874F9561E2af34549DeeD
```

## New User Entry

- Mints a new Tronic MemberNFT to user
- Creates a Tokenbound Account for this NFT

```bash
forge script script/NewUserEntry.s.sol:NewUserEntry -vvvv --rpc-url goerli --broadcast
```

```bash
# Tokenbound Account
TOKENBOUND_ACCOUNT_TOKENID_1=0x68e65ccf569EaC9F2c79ABc81915919b61fa54bD
```

## New User Earns Rewards from Project X

- User receives 100 Project X Loyalty Tokens Level 1
- User receives 100 Project X Loyalty Tokens Level 2

```bash
forge script script/UserEarns.s.sol:UserEarns -vvvv --rpc-url goerli --broadcast
```
