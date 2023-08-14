# Tronic Membership Contract Scenario

## Deploy Initial Contracts

### Deploys:

- Main Tronic Member Nft Contract (cloneable ERC721)
- Cloneable ERC1155 Contract Template
- Deploys `CloneFactory.sol`

Verifies all contrcats on etherscan

```js
forge script script/Deploy.s.sol:Deploy -vvvv --rpc-url sepolia --broadcast --verify
```

```bash
# tokenbound default contract addresses
TOKENBOUND_DEFAULT_ACCOUNT_ADDRESS=0x2d25602551487c3f3354dd80d76d54383a243358
ERC6551_REGISTRY_ADDRESS=0x02101dfB77FDE026414827Fdc604ddAF224F0921

# testnet deployed contract addresses
ERC721_CLONEABLE_ADDRESS=0x90247B092feFf3AaB77dE4C9a232c983100c3b84
ERC1155_CLONEABLE_ADDRESS=0x2759A615eF0f0888d70c70d5AAA0Eb22AA7Fa7F6
CLONE_FACTORY_ADDRESS=0x27892e79C87Bfe6756c7A4A833838Eec5Fdb3D36

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

### Verify CloneFactory

```js
forge verify-contract --chain-id 11155111 --watch 0xd3065Ed995ea1ad63f36caD3fB2539313E37EB3D --constructor-args $(cast abi-encode "constructor(address,address,address,address,address)" 0x42C7eF198f8aC9888E2B1b73e5B71f1D4535194A 0xFe7c64f016A6bD0D83e39D3382541b3d4058Ad15 0xFa2b9fCF23Ab80bDde6f567580f17e00eB22D5C1 0x02101dfB77FDE026414827Fdc604ddAF224F0921 0x2d25602551487c3f3354dd80d76d54383a243358) --etherscan-api-key etherscan src/CloneFactory.sol:CloneFactory
```

## initialize Tronic ERC721 and ERC1155

- Initializes Tronic Member Nft Contract
- Initializes Tronic ERC1155 Contract
- Creates 4 Fungible Reward Tokens for Tronic

```js
forge script script/Initialize.s.sol:Initialize -vvvv --rpc-url sepolia --broadcast
```

## Deploy New Project/Partner/Brand (Project X)

- Clones a partner ERC721 and ERC1155 to Project X
- Clones a partner ERC721 and ERC1155 to Project Y
- Initializes both projects
- creates fungible reward tokens for both projects

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
TOKENBOUND_ACCOUNT_TOKENID_1=0x7618Ce5062b153306284B7267E66526Bf8DBB497
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
PROJECT_X_TOKENBOUND_ACCOUNT_TOKENID_1=0xC03F52e87f41f8e2907e2410695ab59492f6aDEf
PROJECT_Y_TOKENBOUND_ACCOUNT_TOKENID_1=0xCc2783D651199EE2D8A8Ed3Ebe26F57C4e5BD362
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
