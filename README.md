# Tronic Membership Contract Scenario

## Deploy Initial Contracts

### Deploys:

- Main Tronic Membership Contract (Cloneable ERC721)
- Main Tronic Loyalty Contract (Cloneable ERC1155)
- Main Tronic Admin Contract `TronicMain.sol`

Verifies all contracts on etherscan

```bash
forge script script/DeployTronic.s.sol:DeployTronic -vvvv --rpc-url sepolia --broadcast --verify
```

```bash
# tokenbound default contract addresses
TOKENBOUND_DEFAULT_ACCOUNT_ADDRESS=0x2d25602551487c3f3354dd80d76d54383a243358
ERC6551_REGISTRY_ADDRESS=0x02101dfB77FDE026414827Fdc604ddAF224F0921

# deployed testnet contract addresses (sepolia)
TRONIC_MEMBER_ERC721_ADDRESS=0xC1CB9608d159112c6A95e6a4d896B2Ba9f966705
TRONIC_REWARDS_ERC1155_ADDRESS=0xEAB7a1e6244Ca96A537823be249B3b7bEfF4117F
TRONIC_ADMIN_CONTRACT_ADDRESS=0x94a98A6E2027976f6BAdD05ae6fA933Da5fa6C49

```

## Initialize Tronic ERC721 and ERC1155

- Initializes Tronic Member Nft Contract
- Initializes Tronic Loyalty ERC1155 Contract
- Creates 4 Fungible Reward Tokens for Tronic

```bash
forge script script/Initialize.s.sol:Initialize -vvvv --rpc-url sepolia --broadcast
```

## Deploy New Project/Partner/Brand (Project X)

- Clones ERC721 and ERC1155 to Partner X
- Clones ERC721 and ERC1155 to Partner Y
- Initializes both projects
- creates fungible reward tokens for both projects

```bash
forge script script/NewProjectEntry.s.sol:NewProjectEntry -vvvv --rpc-url sepolia --broadcast
```

```bash
# PARTNER x cloned contracts
PARTNER_X_CLONED_ERC721_ADDRESS=0x952aA94B09ed02f3ae86b0EfD5427CE8B311B2cA
PARTNER_X_CLONED_ERC1155_ADDRESS=0x88CDb8f97854F4a389F3482667d57f2B8a223812

# PARTNER y cloned contracts
PARTNER_Y_CLONED_ERC721_ADDRESS=0xD06b9E6fa7234dF521d3ecC6E5987AD0449bfeb5
PARTNER_Y_CLONED_ERC1155_ADDRESS=0x7c7f0b8dF108DC8C867016C3b203037d44409C30
```

## Create Fungible Types for Partners X and Y

- Creates three fungible reward tokens for both projects

```bash
forge script script/NewProjectConfig.s.sol:NewProjectConfig -vvvv --rpc-url sepolia --broadcast
```

## New User Entry

- Mints a new Tronic MemberNFT to user
- Creates a Tokenbound Account for this NFT
- Mints 100 Tronic A Tokens to user

```bash
forge script script/NewUserEntry.s.sol:NewUserEntry -vvvv --rpc-url sepolia --broadcast
```

```bash
# Tokenbound Account
TOKENBOUND_ACCOUNT_TOKENID_1=0x23aec166d19e8a11390445479267D7e07D550A66
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
PARTNER_X_TOKENBOUND_ACCOUNT_TOKENID_1=0x03B00190d8E2603B08dA94d8A6E0C8844842499F
PARTNER_Y_TOKENBOUND_ACCOUNT_TOKENID_1=0x7261a238427d054c6Ec6f6b9b62618002a3225D3
```

## New User Earns (PART 2) Loyalty Rewards from Project X and Project Y

- User receives 100 Project X Loyalty A Tokens
- User receives 50 Project X Loyalty B Tokens
- User receives 100 Project Y Loyalty A Tokens
- User receives 50 Project Y Loyalty B Tokens

```bash
forge script script/NewUserEarns2.s.sol:NewUserEarns2 -vvvv --rpc-url sepolia --broadcast
```

## New User Earns (PART 3) Loyalty Rewards from Project X and TRONIC

- User receives 25 Project X Loyalty C Tokens
- User receives 10 TRONIC Loyalty B Tokens

```bash
forge script script/NewUserEarns3.s.sol:NewUserEarns3 -vvvv --rpc-url sepolia --broadcast
```
