# Tronic Membership Contract Scenario

## Deploy Initial Contracts

### Deploys:

- Main Tronic Member Nft Contract (cloneable ERC721)
- Cloneable ERC1155 Contract Template

```js
forge script script/Deploy.s.sol:Deploy -vvvv --rpc-url sepolia --broadcast
```

```bash
# testnet contract addresses
TOKENBOUND_DEFAULT_ACCOUNT_ADDRESS=0x1a0E97Dae78590b7E967E725a5c848eD034f5510
ERC721_CLONEABLE_ADDRESS=0x381BE1c4765AEe02Fc3cC86c700Ab1c4a30fc7c9
ERC1155_CLONEABLE_ADDRESS=0xCa9F4A29Fc0076A9Fd643B549Fc760995b47E6f8
ERC6551_REGISTRY_ADDRESS=0x02101dfB77FDE026414827Fdc604ddAF224F0921

```

## Verify Contracts

### Verfiy ERC721

```js
forge verify-contract --chain-id 11155111 --watch 0x381BE1c4765AEe02Fc3cC86c700Ab1c4a30fc7c9 --etherscan-api-key goerli src/ERC721CloneableTBA.sol:ERC721CloneableTBA
```

### Verfiy ERC1155

```js
forge verify-contract --chain-id 11155111 --watch 0xCa9F4A29Fc0076A9Fd643B549Fc760995b47E6f8 --etherscan-api-key goerli src/ERC1155Cloneable.sol:ERC1155Cloneable
```

## Deploy and verify CloneFactory.sol and initialize Tronic ERC721

- Deploys `CloneFactory.sol`
- Initializes Tronic Member Nft Contract

```js
forge script script/DeployCloneFactory.s.sol:DeployCloneFactory -vvvv --rpc-url goerli --broadcast --verify
```

```bash
# deployed clone factory address
CLONE_FACTORY_ADDRESS=0xfFc708e5eE0e1c5643c131906f187f3A49f67976
```

### Verify CloneFactory (only if verification fails in previous step)

```js
forge verify-contract --chain-id 11155111 --watch 0xfFc708e5eE0e1c5643c131906f187f3A49f67976 --constructor-args $(cast abi-encode "constructor(address,address,address,address,address)" 0x42C7eF198f8aC9888E2B1b73e5B71f1D4535194A 0xe931e45265b58a77328B0c0bABcb6Af417c18154 0x1AEaFDcfb6b7E0322023FC58cf91B34D3076B21d 0xb6F028F59c95F09331776069ccd2bEf85b0C2b1E 0xCB732ebe48daaf08E9F7C3d14968a5F1E72A045A) --etherscan-api-key goerli src/CloneFactory.sol:CloneFactory
```

## Deploy New Project/Partner/Brand (Project X)

- Clones a partner ERC1155 to Project X

```bash
forge script script/NewProjectEntry.s.sol:NewProjectEntry -vvvv --rpc-url sepolia --broadcast
```

```bash
# project x cloned contracts
PROJECT_X_CLONED_ERC721_ADDRESS=0x4ade2b208E780D5a8C60B3D5A4F9D8Bfa2760FB5
PROJECT_X_CLONED_ERC1155_ADDRESS=0x119B25FCF4E418F4B11210bB89300B2bd4e750cb

# project y cloned contracts
PROJECT_Y_CLONED_ERC721_ADDRESS=0x6D3aEC6195fc0106322e1d959ebAD8eaEc86122b
PROJECT_Y_CLONED_ERC1155_ADDRESS=0xDc41aF1F0368f34dB6e07C2Ea76d8519E5e3004d
```

## New User Entry

- Mints a new Tronic MemberNFT to user
- Creates a Tokenbound Account for this NFT

```bash
forge script script/NewUserEntry.s.sol:NewUserEntry -vvvv --rpc-url sepolia --broadcast
```

```bash
# Tokenbound Account
TOKENBOUND_ACCOUNT_TOKENID_1=0x9BD63Cb55B822785Cdc6aF5704f20425255C0c60
```

## New User Earns Rewards from Project X

- User receives 100 Project X Loyalty Tokens Level 1
- User receives 100 Project X Loyalty Tokens Level 2

```bash
forge script script/NewUserEarns.s.sol:NewUserEarns -vvvv --rpc-url goerli --broadcast
```
