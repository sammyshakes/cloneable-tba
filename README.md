# Tronic Membership Contract Scenario

### Scripts executed in this order:

1. `DeployTronic.s.sol`
2. `InitializeTronic.s.sol`
3. `DeployMembership.s.sol`
4. `MembershipConfig.s.sol`
5. `NewUserEntry.s.sol`
6. `NewUserEarns1.s.sol`
7. `NewUserEarns2.s.sol`
8. `NewUserEarns3.s.sol`

---

### `DeployTronic.s.sol` - Deploy Initial Contracts

### Deploys:

- `TronicMembership.sol` - Tronic Membership Contract (Cloneable ERC721)
- `TronicToken.sol` - Tronic Token Contract (Cloneable ERC1155)
- `TronicMain.sol` - Tronic Main Contract

Verifies all contracts on etherscan

```bash
forge script script/DeployTronic.s.sol:DeployTronic -vvvv --rpc-url sepolia --broadcast --verify
```

```bash
# tokenbound default contract addresses
ERC6551_REGISTRY_ADDRESS=0x02101dfB77FDE026414827Fdc604ddAF224F0921
TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS=0x2d25602551487c3f3354dd80d76d54383a243358

# deployed testnet contract addresses (sepolia)
TRONIC_MEMBERSHIP_ERC721_ADDRESS=0x4fc90cca78D6971be88E444DF9e58376BcFe9663
TRONIC_TOKEN_ERC1155_ADDRESS=0x99C5A36f52aeD8c554Ff752D5b48ae506F29C6b1
TRONIC_MAIN_CONTRACT_ADDRESS=0x54bcA6bb74D54aa524819BcF1b99cd8DDEc7b650

```

## Initialize Tronic ERC721 and ERC1155

- Initializes Tronic Membership ERC721 Contract
- Initializes Tronic Token ERC1155 Contract
- Creates 4 Fungible Reward Tokens for Tronic

```bash
forge script script/InitializeTronic.s.sol:InitializeTronic -vvvv --rpc-url sepolia --broadcast
```

## Deploy New Project/Partner/Brand (Project X)

- Deploys Membership X (Clones ERC721 and ERC1155)
- Deploys Membership Y (Clones ERC721 and ERC1155)
- Initializes both memberships
- Creates fungible loyalty tokens for both memberships

```bash
forge script script/DeployMembership.s.sol:DeployMembership -vvvv --rpc-url sepolia --broadcast
```

```bash
# MEMBERSHIP x contracts
MEMBERSHIP_X_ERC721_ADDRESS=0xe95784D2C873687f5BC987bEaaa4df93E4EE7F2E
MEMBERSHIP_X_ERC1155_ADDRESS=0x21E92158670054fcace580aFCd18fAC1c4c5472c

# MEMBERSHIP y contracts
MEMBERSHIP_Y_ERC721_ADDRESS=0x82056c913Cfb1C4092EF8d81e6BEF18417f1c3da
MEMBERSHIP_Y_ERC1155_ADDRESS=0x2E0FAAf0b21eedE2Cb96913309e072Fa97113e69
```

## Create Fungible Types for Partners X and Y

- Creates three fungible reward tokens for both projects

```bash
forge script script/MembershipConfig.s.sol:MembershipConfig -vvvv --rpc-url sepolia --broadcast
```

## New User Entry

- Mints a new Tronic Membership NFT to user
- Creates a Tokenbound Account for this NFT
- Mints 100 Tronic A Loyalty Tokens to user

```bash
forge script script/NewUserEntry.s.sol:NewUserEntry -vvvv --rpc-url sepolia --broadcast
```

```bash
# Tokenbound Account
TOKENBOUND_ACCOUNT_TOKENID_1=0x09422CabAcCecf7b9670575Cb0425a519A713A97
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
MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1=0x312a5342d4E1764e2Ca4002Dea30298913fF82eE
MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1=0xA906EE08b03EC0C3065a6bb5339eFFc7EC59655F
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
