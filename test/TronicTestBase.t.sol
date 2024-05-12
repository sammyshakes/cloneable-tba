// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TronicMain.sol";
import "../src/TronicBeacon.sol";
import "../src/TronicBrandLoyalty.sol";
import "../src/TronicMembership.sol";
import "../src/TronicToken.sol";
import "../src/TronicRewards.sol";
import "../src/interfaces/IERC6551Account.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @dev Sets up the initial state for testing the TronicMain system
/// @notice Deploys the core Tronic contracts
/// @notice Creates user accounts, default memberships, and initial token types
contract TronicTestBase is Test {
    struct BatchMintOrder {
        uint256 membershipId;
        address[] recipients;
        uint256[][][] tokenIds;
        uint256[][][] amounts;
        TronicMain.TokenType[][] tokenTypes;
    }

    ERC1967Proxy public tronicMainProxy;

    // Implementation Deployments
    TronicMain public tronicMainContractImplementation;
    TronicMembership public tronicMembership;
    TronicToken public tronicToken;
    TronicBrandLoyalty public tronicBrandLoyaltyImplementation;
    TronicRewards public tronicRewardsImplementation;
    TronicBeacon public tronicBeacon;

    // this variable represents TronicMain via proxy
    TronicMain public tronicMainContract;

    //beacon proxies
    TronicBeacon public brandLoyaltyBeacon;
    TronicBeacon public membershipBeacon;
    TronicBeacon public achievementBeacon;
    TronicBeacon public rewardsBeacon;

    //brand membership X
    TronicBrandLoyalty public brandLoyaltyX;
    TronicMembership public brandXMembership;
    TronicToken public brandXToken;
    TronicRewards public brandXRewards;

    //brand membership Y
    TronicBrandLoyalty public brandLoyaltyY;
    TronicMembership public brandYMembership;
    TronicToken public brandYToken;
    TronicRewards public brandYRewards;

    TronicMain.MembershipInfo public membershipX;
    TronicMain.MembershipInfo public membershipY;

    uint256 public membershipIDX;
    uint256 public membershipIDY;

    uint256 public brandIDX;
    uint256 public brandIDY;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    address public user4 = address(0x4);
    address public user5 = address(0x5);
    // new address for an unauthorized user
    address public unauthorizedUser = address(0x666);

    address public tronicOwner = address(0x6);

    //tronicAdmin will be some privatekey stored on backend
    address public tronicAdmin = address(0x7);

    address public membershipAdmin = address(0x8);

    address public defaultTBAImplementationAddress =
        vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS");

    address payable public tbaProxyImplementationAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_PROXY_IMPLEMENTATION_ADDRESS"));

    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");

    address public brandLoyaltyAddressX;
    address public membershipAddressX;
    address public tokenAddressX;
    address public rewardsAddressX;

    address public brandLoyaltyAddressY;
    address public membershipAddressY;
    address public tokenAddressY;
    address public rewardsAddressY;

    address public tronicTokenId1TBA;
    address public tronicTokenId2TBA;
    address public tronicTokenId3TBA;
    address public tronicTokenId4TBA;

    //brandloyalty token tbas
    address public brandLoyaltyXTokenId1TBA;
    address public brandLoyaltyXTokenId2TBA;
    address public brandLoyaltyYTokenId1TBA;
    address public brandLoyaltyYTokenId2TBA;

    // achievement types
    uint256 public fungibleTypeIdX1;
    uint256 public fungibleTypeIdY1;
    uint256 public nonFungibleTypeIdX1;
    uint256 public nonFungibleTypeIdY1;

    TronicMembership.MembershipTier[] public membershipTiers;

    string public initialUriX = "http://setup-exampleX.com/token/";
    string public initialUriY = "http://setup-exampleY.com/token/";

    //create tier uris
    string public tier1XURI = "tier1XURI";
    string public tier2XURI = "tier2XURI";
    string public tier1YURI = "tier1YURI";
    string public tier2YURI = "tier2YURI";

    uint64 public nftStartId = 100_000;

    function setUp() public {
        //deploy tronic contracts
        vm.startPrank(tronicOwner);

        tronicMembership = new TronicMembership();
        tronicToken = new TronicToken();
        tronicBrandLoyaltyImplementation = new TronicBrandLoyalty();
        tronicMainContractImplementation = new TronicMain();
        tronicRewardsImplementation = new TronicRewards();

        // Deploy separate beacons for each contract type
        brandLoyaltyBeacon = new TronicBeacon(address(tronicBrandLoyaltyImplementation));
        membershipBeacon = new TronicBeacon(address(tronicMembership));
        achievementBeacon = new TronicBeacon(address(tronicToken));
        rewardsBeacon = new TronicBeacon(address(tronicRewardsImplementation));

        //deploy tronicMainContract via proxy
        tronicMainProxy = new ERC1967Proxy(
            address(tronicMainContractImplementation),
            abi.encodeWithSignature(
                "initialize(address,address,address,address,address,address,address,address)",
                tronicAdmin,
                address(brandLoyaltyBeacon),
                address(membershipBeacon),
                address(achievementBeacon),
                address(rewardsBeacon),
                registryAddress,
                defaultTBAImplementationAddress,
                tbaProxyImplementationAddress
            )
        );

        tronicMainContract = TronicMain(address(tronicMainProxy));

        assertEq(tronicMainContract.MAX_TIERS_PER_MEMBERSHIP(), 10);

        vm.stopPrank();

        // deploy membership contracts
        vm.startPrank(tronicAdmin);

        //deploy brand loyalty contracts
        (brandIDX, brandLoyaltyAddressX, tokenAddressX, rewardsAddressX) =
            tronicMainContract.deployBrand("Brand X", "XXX", "http://BrandX.com/", false);

        (brandIDY, brandLoyaltyAddressY, tokenAddressY, rewardsAddressY) =
            tronicMainContract.deployBrand("Brand Y", "YYY", "http://BrandY.com/", false);

        //create membership tiers
        //create membership tiers for tronicMembership
        TronicMembership.MembershipTier[] memory tiers = new TronicMembership.MembershipTier[](2);
        tiers[0] = ITronicMembership.MembershipTier({
            tierId: "tier1",
            duration: 30 days,
            isOpen: true,
            tierURI: tier1XURI
        });

        tiers[1] = ITronicMembership.MembershipTier({
            tierId: "tier2",
            duration: 120 days,
            isOpen: false,
            tierURI: tier2XURI
        });

        (membershipIDX, membershipAddressX) = tronicMainContract.deployMembership(
            brandIDX,
            "Membership_X1",
            "X1",
            "http://MembershipX.com/",
            10_000,
            true, //iselastic
            tiers
        );

        (membershipIDY, membershipAddressY) = tronicMainContract.deployMembership(
            brandIDY,
            "Membership_Y1",
            "Y1",
            "http://MembershipY.com/",
            10_000,
            false, //iselastic
            tiers
        );

        // Set up initial state
        uint64 initialMaxSupply = 100_000;

        bool isReward = false;

        fungibleTypeIdX1 = tronicMainContract.createFungibleTokenType(
            brandIDX, initialMaxSupply, initialUriX, isReward
        );

        fungibleTypeIdY1 = tronicMainContract.createFungibleTokenType(
            brandIDY, initialMaxSupply, initialUriY, isReward
        );

        nonFungibleTypeIdX1 = tronicMainContract.createNonFungibleTokenType(
            brandIDX, initialUriX, 1_000_000, isReward
        );

        nonFungibleTypeIdY1 =
            tronicMainContract.createNonFungibleTokenType(brandIDY, initialUriY, 25_000, isReward);

        ///mint brand loyalty nfts

        (brandLoyaltyXTokenId1TBA,) = tronicMainContract.mintBrandLoyaltyToken(user1, brandIDX);
        (brandLoyaltyXTokenId2TBA,) = tronicMainContract.mintBrandLoyaltyToken(user2, brandIDX);
        (brandLoyaltyYTokenId1TBA,) = tronicMainContract.mintBrandLoyaltyToken(user3, brandIDY);
        (brandLoyaltyYTokenId2TBA,) = tronicMainContract.mintBrandLoyaltyToken(user4, brandIDY);

        //mint Tronic Brand Loyalty nfts from TronicMain to users 1-4 and return their tbas
        tronicMainContract.mintMembership(user1, membershipIDX, 1);
        tronicMainContract.mintMembership(user2, membershipIDX, 1);
        tronicMainContract.mintMembership(user3, membershipIDY, 1);
        tronicMainContract.mintMembership(user4, membershipIDY, 1);

        vm.stopPrank();

        // get membership x and y details, membership ids: x=0 and y=1
        membershipX = tronicMainContract.getMembershipInfo(membershipIDX);
        membershipY = tronicMainContract.getMembershipInfo(membershipIDY);

        //get brand loyalty contracts
        address brandXTokenAddress = tronicMainContract.getBrandInfo(brandIDX).achievementAddress;
        address brandYTokenAddress = tronicMainContract.getBrandInfo(brandIDY).achievementAddress;

        // get membership contracts
        brandXMembership = TronicMembership(membershipX.membershipAddress);
        brandXToken = TronicToken(brandXTokenAddress);
        brandXRewards = TronicRewards(rewardsAddressX);
        brandYMembership = TronicMembership(membershipY.membershipAddress);
        brandYToken = TronicToken(brandYTokenAddress);
        brandYRewards = TronicRewards(rewardsAddressY);

        brandLoyaltyX = TronicBrandLoyalty(brandLoyaltyAddressX);
        brandLoyaltyY = TronicBrandLoyalty(brandLoyaltyAddressY);

        //verify that users have tronic membership nfts
        assertEq(brandLoyaltyX.ownerOf(1), user1);
        assertEq(brandLoyaltyX.ownerOf(2), user2);
        assertEq(brandLoyaltyY.ownerOf(1), user3);
        assertEq(brandLoyaltyY.ownerOf(2), user4);
    }

    // helper function to create instances of BatchMintOrder
    function createBatchMintOrder(
        uint256 _membershipId,
        address[] memory _recipients,
        uint256[][][] memory _tokenIds,
        uint256[][][] memory _amounts,
        TronicMain.TokenType[][] memory _tokenTypes
    ) public pure returns (BatchMintOrder memory order) {
        order = BatchMintOrder({
            membershipId: _membershipId,
            recipients: _recipients,
            tokenIds: _tokenIds,
            amounts: _amounts,
            tokenTypes: _tokenTypes
        });
    }

    // helper function to prepare data for batch minting
    function _prepareBatchProcessData(BatchMintOrder[] memory orders)
        internal
        pure
        returns (
            uint256[] memory membershipIds,
            address[][] memory recipients,
            uint256[][][][] memory tokenIds,
            uint256[][][][] memory amounts,
            TronicMain.TokenType[][][] memory tokenTypes
        )
    {
        uint256 orderCount = orders.length;

        // Initialize the arrays
        membershipIds = new uint256[](orderCount);
        recipients = new address[][](orderCount);
        tokenIds = new uint256[][][][](orderCount);
        amounts = new uint256[][][][](orderCount);
        tokenTypes = new TronicMain.TokenType[][][](orderCount);

        // Populate the arrays based on the input orders
        for (uint256 i = 0; i < orderCount; i++) {
            membershipIds[i] = orders[i].membershipId;
            recipients[i] = orders[i].recipients;
            tokenIds[i] = orders[i].tokenIds;
            amounts[i] = orders[i].amounts;
            tokenTypes[i] = orders[i].tokenTypes;
        }

        return (membershipIds, recipients, tokenIds, amounts, tokenTypes);
    }
}
