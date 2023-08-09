# Tronic Membership Contract Scenario

## Deploy Initial Contracts

### Deploys:

- Main Tronic Member Nft Contract (cloneable ERC721)
- Cloneable ERC1155 Contract Template

```js
forge script script/Deploy.s.sol:Deploy -vvvv --rpc-url sepolia --broadcast --verify
```

```bash
# testnet contract addresses
TOKENBOUND_DEFAULT_ACCOUNT_ADDRESS=0x2d25602551487c3f3354dd80d76d54383a243358
ERC6551_REGISTRY_ADDRESS=0x02101dfB77FDE026414827Fdc604ddAF224F0921
ERC721_CLONEABLE_ADDRESS=0xFe7c64f016A6bD0D83e39D3382541b3d4058Ad15
ERC1155_CLONEABLE_ADDRESS=0xFa2b9fCF23Ab80bDde6f567580f17e00eB22D5C1

```

## Verify Contracts (If not successfully verified in previous step)

### Verfiy ERC721

```js
forge verify-contract --chain-id 11155111 --watch 0xFe7c64f016A6bD0D83e39D3382541b3d4058Ad15 --etherscan-api-key etherscan src/ERC721CloneableTBA.sol:ERC721CloneableTBA
```

### Verfiy ERC1155

```js
forge verify-contract --chain-id 11155111 --watch 0xFa2b9fCF23Ab80bDde6f567580f17e00eB22D5C1 --etherscan-api-key etherscan src/ERC1155Cloneable.sol:ERC1155Cloneable
```

## Deploy and verify CloneFactory.sol and initialize Tronic ERC721

- Deploys `CloneFactory.sol`
- Initializes Tronic Member Nft Contract

```js
forge script script/DeployCloneFactory.s.sol:DeployCloneFactory -vvvv --rpc-url sepolia --broadcast --verify
```

```bash
# deployed clone factory address
CLONE_FACTORY_ADDRESS=0xd3065Ed995ea1ad63f36caD3fB2539313E37EB3D
```

### Verify CloneFactory (only if verification fails in previous step)

```js
forge verify-contract --chain-id 11155111 --watch 0xd3065Ed995ea1ad63f36caD3fB2539313E37EB3D --constructor-args $(cast abi-encode "constructor(address,address,address,address,address)" 0x42C7eF198f8aC9888E2B1b73e5B71f1D4535194A 0xFe7c64f016A6bD0D83e39D3382541b3d4058Ad15 0xFa2b9fCF23Ab80bDde6f567580f17e00eB22D5C1 0x02101dfB77FDE026414827Fdc604ddAF224F0921 0x2d25602551487c3f3354dd80d76d54383a243358) --etherscan-api-key etherscan src/CloneFactory.sol:CloneFactory
```

## Deploy New Project/Partner/Brand (Project X)

- Clones a partner ERC1155 to Project X

```bash
forge script script/NewProjectEntry.s.sol:NewProjectEntry -vvvv --rpc-url sepolia --broadcast
```

```bash
# project x cloned contracts
PROJECT_X_CLONED_ERC721_ADDRESS=0xeCcFD42a53045D704a7B97E74ab477bd748BA156
PROJECT_X_CLONED_ERC1155_ADDRESS=0x81a71A6DC43395eae7e94df05bD6b54555EAc9c8

# project y cloned contracts
PROJECT_Y_CLONED_ERC721_ADDRESS=0x0518b4D2EB57E51F71dc0e892a729d31413c6d6A
PROJECT_Y_CLONED_ERC1155_ADDRESS=0x1b925f96973ecC0bc387E7e64BFCFFE59Bd17E0A
```

## New User Entry

- Mints a new Tronic MemberNFT to user
- Creates a Tokenbound Account for this NFT

```bash
forge script script/NewUserEntry.s.sol:NewUserEntry -vvvv --rpc-url sepolia --broadcast
```

```bash
# Tokenbound Account
TOKENBOUND_ACCOUNT_TOKENID_1=0x92a4148F4d957f4A6753AC143D32B5AF390214b3
```

## New User Earns (PART 1) Project NFTs from Project X and Project Y

- User receives NFT from Project X
- User receives NFT from Project Y

NOTE: This will create tokenbound accounts for each project nft

```bash
forge script script/NewUserEarns1.s.sol:NewUserEarns1 -vvvv --rpc-url sepolia --broadcast
```

```bash
# tokenbound accounts for project nfts
PROJECT_X_TOKENBOUND_ACCOUNT_TOKENID_1=0xb067d2d42a94D43d5e2757fdE4fBE26eA20CA88A
PROJECT_Y_TOKENBOUND_ACCOUNT_TOKENID_1=0xE163F1Ac494862C3a4Dc36528a2C12C1AA0D585d
```

## New User Earns (PART 2) Loyalty Rewards from Project X and Project Y

- User receives 100 Project X Loyalty Tokens Level 1
- User receives 50 Project X Loyalty Tokens Level 2
- User receives 100 Project Y Loyalty Tokens Level 1
- User receives 50 Project Y Loyalty Tokens Level 2

```bash
forge script script/NewUserEarns2.s.sol:NewUserEarns2 -vvvv --rpc-url sepolia --broadcast
```

## New User Earns (PART 3) Loyalty Rewards from Project X and TRONIC

- User receives 25 Project X Loyalty Tokens Level 3
- User receives 10 TRONIC Loyalty Tokens Level 1

```bash
forge script script/NewUserEarns3.s.sol:NewUserEarns3 -vvvv --rpc-url sepolia --broadcast
```
