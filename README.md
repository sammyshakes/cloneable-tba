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
forge script script/DeployTronic.s.sol:DeployTronic -vvvv --rpc-url mumbai --broadcast --verify
```

```r
# tokenbound default contract addresses
ERC6551_REGISTRY_ADDRESS=0x02101dfB77FDE026414827Fdc604ddAF224F0921
TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS=0x2d25602551487c3f3354dd80d76d54383a243358

# deployed testnet contract addresses (mumbai)
TRONIC_MEMBERSHIP_ERC721_ADDRESS=0xB5c837FD932FBED9Ef38203AaD6F07dc5A35272C
TRONIC_TOKEN_ERC1155_ADDRESS=0xdb02312EF6d6ec9c24Fc77A18d1F91A7Ef796A07
TRONIC_MAIN_CONTRACT_ADDRESS=0xfEfbE525f9Cd75E026B7bfE2d51f861aE82f00cA

```

### `InitializeTronic.s.sol` - Initializes Tronic Membership (ERC721) and Tronic Token (ERC1155)

- Initializes Tronic Membership ERC721 Contract
- Initializes Tronic Token ERC1155 Contract
- Creates 4 Fungible Reward Tokens for Tronic

```bash
forge script script/InitializeTronic.s.sol:InitializeTronic -vvvv --rpc-url mumbai --broadcast
```

### `DeployMembership.s.sol` - Deploys New Memberships (Memberships X and Y)

- Deploys Membership X (Clones Membership ERC721 and Token ERC1155)
- Deploys Membership Y (Clones Membership ERC721 and Token ERC1155)
- Initializes both memberships
- Creates fungible loyalty tokens for both memberships

```bash
forge script script/DeployMembership.s.sol:DeployMembership -vvvv --rpc-url mumbai --broadcast
```

```r
# MEMBERSHIP x contracts
MEMBERSHIP_X_ERC721_ADDRESS=0x1d2aAb95192632674BA7CBf8c0105D8782fb9897
MEMBERSHIP_X_ERC1155_ADDRESS=0x9Eb6A0742c70A0Fc5288fB897eAb8A0aC1B651d4

# MEMBERSHIP y contracts
MEMBERSHIP_Y_ERC721_ADDRESS=0xc5a11d5FF21C987908F95495BF12B404E551F225
MEMBERSHIP_Y_ERC1155_ADDRESS=0x2AF8B8bE90A38E5Fb6c94A5043c942a4ffe3A658
```

### `MembershipConfig.s.sol` - Creates Fungible Types for Memberships X and Y

- Creates three fungible reward tokens for both Memberships

```bash
forge script script/MembershipConfig.s.sol:MembershipConfig -vvvv --rpc-url mumbai --broadcast
```

### `NewUserEntry.s.sol` - A New User subscribes to Tronic Membership

- Mints a new Tronic Membership NFT to user
- Creates a Tokenbound Account for this NFT
- Mints 100 Tronic A Loyalty Tokens to user

```bash
forge script script/NewUserEntry.s.sol:NewUserEntry -vvvv --rpc-url mumbai --broadcast
```

```r
# Tokenbound Account
TOKENBOUND_ACCOUNT_TOKENID_1=0x36a0f8A50A27F08812dD64f975b2C2D71C6F895A
```

### `NewUserEarns1.s.sol` - New User Earns (PART 1) - Subscribes to Memberships X and Y

- User receives NFT from Membership X
- User receives NFT from Membership Y

NOTE: This will create tokenbound accounts for each membership nft

```bash
forge script script/NewUserEarns1.s.sol:NewUserEarns1 -vvvv --rpc-url mumbai --broadcast
```

```r
# tokenbound accounts for project nfts
MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1=0xc733492d9Df311c186592e610395464fF7a5E869
MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1=0xFEea142f892dF67fED359156e0ac57B9488d270A
```

### `NewUserEarns2.s.sol` - New User Earns (PART 2) - Loyalty Tokens from Memberships X and Y

- User receives 100 Membership X Loyalty A Tokens
- User receives 50 Membership X Loyalty B Tokens
- User receives 100 Membership Y Loyalty A Tokens
- User receives 50 Membership Y Loyalty B Tokens

```bash
forge script script/NewUserEarns2.s.sol:NewUserEarns2 -vvvv --rpc-url mumbai --broadcast
```

### `NewUserEarns3.s.sol` - New User Earns (PART 3) - Loyalty Tokens from Membership X and TRONIC

- User receives 25 Membership X Loyalty C Tokens
- User receives 10 TRONIC Loyalty B Tokens

```bash
forge script script/NewUserEarns3.s.sol:NewUserEarns3 -vvvv --rpc-url mumbai --broadcast
```
