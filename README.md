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

TODO:

- User Transfers Tronic Membership and TBA owned Memberships
- User Transfers TBA owned Tronic Tokens and Nested Membership Loyalty Tokens
- Tronic transfers on behalf of Users, Memberships And Tokens

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

```r
# tokenbound default contract addresses
ERC6551_REGISTRY_ADDRESS=0x02101dfB77FDE026414827Fdc604ddAF224F0921
TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS=0x2d25602551487c3f3354dd80d76d54383a243358

# deployed testnet contract addresses (sepolia)
TRONIC_MEMBERSHIP_ERC721_ADDRESS=0xa23161C76f1f5E91607Da899e909A1355C4dAAcb
TRONIC_TOKEN_ERC1155_ADDRESS=0x704Bb35954f1b425B8D1Ca5cD4a8219ac5B1C2E1
TRONIC_MAIN_CONTRACT_ADDRESS=0x10900dA08f0515dC93C589169953B5ef87E33adc

```

### `InitializeTronic.s.sol` - Initializes Tronic Membership (ERC721) and Tronic Token (ERC1155)

- Initializes Tronic Membership ERC721 Contract
- Initializes Tronic Token ERC1155 Contract
- Creates 4 Fungible Reward Tokens for Tronic

```bash
forge script script/InitializeTronic.s.sol:InitializeTronic -vvvv --rpc-url sepolia --broadcast
```

### `DeployMembership.s.sol` - Deploys New Memberships (Memberships X and Y)

- Deploys Membership X (Clones Membership ERC721 and Token ERC1155)
- Deploys Membership Y (Clones Membership ERC721 and Token ERC1155)
- Initializes both memberships
- Creates fungible loyalty tokens for both memberships

```bash
forge script script/DeployMembership.s.sol:DeployMembership -vvvv --rpc-url sepolia --broadcast
```

```r
# MEMBERSHIP x contracts
MEMBERSHIP_X_ERC721_ADDRESS=0x0256fAdb74B480aE49F0930a5913466005118f26
MEMBERSHIP_X_ERC1155_ADDRESS=0xd93937E53d87973435AF7277B8C171CA9BC68769

# MEMBERSHIP y contracts
MEMBERSHIP_Y_ERC721_ADDRESS=0xD01d94073d0aB4Cc5AF318aaF8D67Ee89259f131
MEMBERSHIP_Y_ERC1155_ADDRESS=0xdC4f015d90454600CfB735b8f1f80Bdf1468A900
```

### `MembershipConfig.s.sol` - Creates Fungible Types for Memberships X and Y

- Creates three fungible reward tokens for both Memberships

```bash
forge script script/MembershipConfig.s.sol:MembershipConfig -vvvv --rpc-url sepolia --broadcast
```

### `NewUserEntry.s.sol` - A New User subscribes to Tronic Membership

- Mints a new Tronic Membership NFT to user
- Creates a Tokenbound Account for this NFT
- Mints 100 Tronic A Loyalty Tokens to user

```bash
forge script script/NewUserEntry.s.sol:NewUserEntry -vvvv --rpc-url sepolia --broadcast
```

```r
# Tokenbound Account
TOKENBOUND_ACCOUNT_TOKENID_1=0x5B095fA9f69062Ed7ed78e436075555ad4c4d555
```

### `NewUserEarns1.s.sol` - New User Earns (PART 1) - Subscribes to Memberships X and Y

- User receives NFT from Membership X
- User receives NFT from Membership Y

NOTE: This will create tokenbound accounts for each membership nft

```bash
forge script script/NewUserEarns1.s.sol:NewUserEarns1 -vvvv --rpc-url sepolia --broadcast
```

```r
# tokenbound accounts for project nfts
MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1=0xd0030707C2853261F0829e3915b3b16B94ba6429
MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1=0xBB2d7cf4853358590aF8E3EDB9c5b1740673BA52
```

### `NewUserEarns2.s.sol` - New User Earns (PART 2) - Loyalty Tokens from Memberships X and Y

- User receives 100 Membership X Loyalty A Tokens
- User receives 50 Membership X Loyalty B Tokens
- User receives 100 Membership Y Loyalty A Tokens
- User receives 50 Membership Y Loyalty B Tokens

```bash
forge script script/NewUserEarns2.s.sol:NewUserEarns2 -vvvv --rpc-url sepolia --broadcast
```

### `NewUserEarns3.s.sol` - New User Earns (PART 3) - Loyalty Tokens from Membership X and TRONIC

- User receives 25 Membership X Loyalty C Tokens
- User receives 10 TRONIC Loyalty B Tokens

```bash
forge script script/NewUserEarns3.s.sol:NewUserEarns3 -vvvv --rpc-url sepolia --broadcast
```
