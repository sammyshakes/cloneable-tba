# Tronic Membership Contract Repository

## Installation

- Install [Foundry CLI](https://book.getfoundry.sh/getting-started/installation)
- Clone this repository and cd into project root:
  ```bash
  git clone https://github.com/tronicapp/tronic-platform-contracts
  cd tronic-platform-contracts
  ```
- Install dependencies:

  ```bash
  forge install
  ```

## Running Tests

### Required .env variables for testing

````r
# etherscan api key
ETHERSCAN_API_KEY=

# rpc address
MUMBAI_RPC_URL=

# tokenbound.org defaults - v0.3.1 implementation
ERC6551_REGISTRY_ADDRESS=0x000000006551c19487814612e58FE06813775758
TOKENBOUND_ACCOUNT_PROXY_IMPLEMENTATION_ADDRESS=0x55266d75D1a14E4572138116aF39863Ed6596E7F
TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS=0x41C8f39463A868d3A88af00cd0fe7102F30E44eC


### To run all tests:

```bash
# without traces
forge test --rpc-url mumbai

# with traces
forge test --rpc-url mumbai --vvvv

# specific test
forge test --match-test testInitialSetup --rpc-url mumbai

# get test coverage
forge coverage --rpc-url mumbai
````

## Tronic Membership Contract Deployment Scenario

### Scripts executed in this order:

- `01_DeployTronic.s.sol`
- `02_InitializeTronic.s.sol` - deprecated
- `03_DeployBrand.s.sol`
- `04_DeployMembership.s.sol`
- `05_CreateFungibleTypes.s.sol`
- `06_MintBrandLoyality.s.sol`
- `07_MintMembership.s.sol`

---

### `01_DeployTronic.s.sol` - Deploy Initial Contracts and proxy contract

### Deploys:

- `TronicBrandLoyalty.sol` - Tronic Brand Loyalty Contract (Cloneable ERC721)
- `TronicMembership.sol` - Tronic Membership Contract (Cloneable ERC721)
- `TronicToken.sol` - Tronic Token Contract (Cloneable ERC1155)
- `TronicMain.sol` - Tronic Main Contract
- `ERC1967Proxy.sol` - Upgradable Proxy for Tronic Main Contract

Verifies all contracts on etherscan

```bash
forge script script/01_DeployTronic.s.sol:DeployTronic -vvvv --rpc-url mumbai --broadcast --verify
```

> NOTE: Record deployed address to .env file from output

````r

```r

# deployed testnet contract implementation addresses (mumbai)
TRONIC_BRAND_LOYALTY_ADDRESS=0x3c8c27d8BE483c6350a57d595C62baf763bC1399
TRONIC_MEMBERSHIP_ERC721_ADDRESS=0x426Ba3aaA065674582098a3206bCc692D331f8A3
TRONIC_TOKEN_ERC1155_ADDRESS=0xDEb98Fc5d4747855f3Ad7a2F28e4a30A6B0AcbA3
TRONIC_MAIN_CONTRACT_ADDRESS=0xd03Bcc7B01adE09Fa1cC8e0C247301b956a81769

# deployed testnet proxy addresses (mumbai)
TRONIC_MAIN_PROXY_ADDRESS=0x4D626fDccC01aE0D7139A04362acDf7ce329E050

````

> NOTE: If verification does not succeed, you can individually verify with `forge verify-contract`:

```bash
forge verify-contract <TRONIC_TOKEN_ADDRESS> src/TronicToken.sol:TronicToken --watch --chain 80001
```

### `03_DeployBrand.s.sol` - Deploys Brand Loyalty and Token Contracts for Brands X and Y and returns their addresses and ids

- Deploys Brand X Loyalty (Clones Tronic Brand Loyalty ERC721)
- Deploys Brand X Token (Clones Tronic Brand Token ERC1155)
- Deploys Brand Y Loyalty (Clones Tronic Brand Loyalty ERC721)
- Deploys Brand Y Token (Clones Tronic Brand Token ERC1155)

- Returns:
  - Brand X Loyalty Address
  - Brand X Token Address
  - Brand X ID
  - Brand Y Loyalty Address
  - Brand Y Token Address
  - Brand Y ID

```bash
forge script script/03_DeployBrand.s.sol:DeployBrand -vvvv --rpc-url mumbai --broadcast
```

> NOTE: Record ids and deployed addresses to .env file from output

```r
# Brand x contracts
BRAND_X_ID=1
BRAND_X_LOYALTY_ADDRESS=0x31446900525E9D979Be8cB33D6E285f3935979AD
BRAND_X_TOKEN_ADDRESS=0x914B11ffB329579598004D1bc820a23806948571

# Brand y contracts
BRAND_Y_ID=2
BRAND_Y_LOYALTY_ADDRESS=0xaD380bca534b35f7E2a1e0cdFb0F148AFb7e3105
BRAND_Y_TOKEN_ADDRESS=0x8B86820b13cC2381B1931190a83f2c9385583f66
```

---

### `04_DeployMembership.s.sol` - Deploys New Memberships (Memberships X and Y) and returns their addresses and ids

- Deploys Membership X (Clones Membership ERC721 and Token ERC1155)
- Deploys Membership Y (Clones Membership ERC721 and Token ERC1155)
- Initializes both memberships

- Returns:
  - Membership X ID
  - Membership X Address
  - Membership Y ID
  - Membership Y Address

```bash
forge script script/04_DeployMembership.s.sol:DeployMembership -vvvv --rpc-url mumbai --broadcast
```

> NOTE: Record ids and deployed addresses to .env file from output

```r
# Deployed MEMBERSHIP contract addresses (example)
MEMBERSHIP_X_ID=1
BRAND_X_MEMBERSHIP_ADDRESS=0xb6D0a9c9F155d70f2919BF66991235924327e981
MEMBERSHIP_Y_ID=2
BRAND_Y_MEMBERSHIP_ADDRESS=0x7125B0f9cEC264495E636D8Ae11bbBb5201FB82B


```

### `05_CreateFungibleTypes.s.sol` - Creates Fungible Types for Memberships X and Y

- Creates three fungible reward tokens for both Memberships

```bash
forge script script/05_CreateFungibleTypes.s.sol:CreateFungibleTypes -vvvv --rpc-url mumbai --broadcast
```

### `06_MintBrandLoyalty.s.sol` - A New User connectsw with a brand and is mintes a Brand Loyalty NFT

- Mints a new Brand Loyalty NFT to user
- Creates a Tokenbound Account for this NFT
- Mints 100 Tronic A Loyalty Tokens to user

```bash
forge script script/06_MintBrandLoyalty.s.sol:MintBrandLoyalty -vvvv --rpc-url mumbai --broadcast
```

```r
# Tokenbound Account
TOKENBOUND_ACCOUNT_TOKENID_1=0x0710520D32c20D709A8B9a2982755400F62AEB5f
```

### `07_MintMembership.s.sol` - New User Earns (PART 1) - Subscribes to Memberships X and Y

- User receives NFT from Membership X
- User receives NFT from Membership Y

NOTE: This will create tokenbound accounts for each membership nft

```bash
forge script script/07_MintMembership.s.sol:MintMembership -vvvv --rpc-url mumbai --broadcast
```

---

# Gas Estimates

---

## Deployments for Gas Estimates

```r
# deployed testnet contract addresses (mumbai)
TRONIC_MEMBERSHIP_ERC721_ADDRESS=0x36cC4336bfAE65BFa628f99cB599499E41331600
TRONIC_TOKEN_ERC1155_ADDRESS=0xA0170915d747738D7dA22c153aD555A4F018F7CB
TRONIC_MAIN_CONTRACT_ADDRESS=0xFF71EC5D8a847FB8fa02375a8eB882021A09297D

# MEMBERSHIP x contracts
MEMBERSHIP_X_ERC721_ADDRESS=0x8Fae95Da9413697d78489e6Be9DCb2d587575311
MEMBERSHIP_X_ERC1155_ADDRESS=0x55257573dcAC41187fDC4Ea5660C6D1790348363

# MEMBERSHIP y contracts
MEMBERSHIP_Y_ERC721_ADDRESS=0x602569759DaA0A5Fa2591cF1330A667F765D45fB
MEMBERSHIP_Y_ERC1155_ADDRESS=0x4686B9bef4Cb70c6235daB64152353f9C6b9dfFc
```

### Run script `GasEstimatesMemberships.s.sol`:

[Polygon Gas Price Tracker](https://polygonscan.com/gastracker)

```bash
forge script script/GasEstimatesMemberships.s.sol:GasEstimatesMemberships -vvvv --rpc-url mumbai --broadcast
```

```r
# Gas Estimates for Memberships when minted individually
average gas used per mint:  209,313
baseline gas price:  100.0 Gwei

# Current MATIC Price: $0.69
average gas cost per mint: 0.0209313 MATIC ($0.0144)
gas cost per 1000 mints: 20.9313 MATIC ($14.40)
gas cost per 1,000,000 mints: 20,931.3 MATIC ($14,400.00)

# with MATIC at $2.00
average gas cost per mint: 0.0209313 MATIC ($0.042)

# with MATIC at $3.00 and gas price at 200 Gwei
average gas cost per mint: 0.0418626 MATIC ($0.1256)

```

> NOTE: Gas can be cut by 50% if Tokenbound was not utilized

> NOTE: Gas prices can vary between 50-200 Gwei

> NOTE: MATIC prices will vary with the market
