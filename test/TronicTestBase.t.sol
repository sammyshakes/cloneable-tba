// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TronicMain.sol";
import "../src/interfaces/IERC6551Account.sol";
import "../src/TronicMembership.sol";
import "../src/TronicToken.sol";
import "../src/TronicBrandLoyalty.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @dev Sets up the initial state for testing the TronicMain system
/// @notice Deploys the core TronicMain, ERC721, and ERC1155 contracts
/// @notice Creates user accounts, default memberships, and initial token types
/// @notice Should be called automatically by any contract inheriting TronicTestBase
///
/// Details:
///
/// - Deploys TronicMain and assigns roles
///   - tronicMainContract: The main TronicMain contract
///   - tronicOwner: Owner account for TronicMain
///   - tronicAdmin: Admin account for TronicMain
///
/// - Deploys TronicMembership and TronicERC1155 implementations
///   - tronicMembership: The Tronic ERC721 token contract
///   - tronicToken: The Tronic ERC1155 token contract
///
/// - Initializes Tronic contracts and assigns admin
///
/// - Deploys mock TokenBoundAccount implementation
///   - defaultTBAImplementationAddress: Address of default TBA implementation
///
/// - Creates user accounts
///   - user1, user2, user3: Sample user accounts
///   - unauthorizedUser: Unauthorized user account
///
/// - Deploys 2 sample memberships
///   - membershipX: Membership 0
///   - membershipY: Membership 1
///
/// - Mints initial sample tokens
///
/// This provides a complete base environment for writing tests. Any contract
/// inheriting this base will have access to the initialized contracts, accounts,
/// and sample data to test against.
contract TronicTestBase is Test {
    struct BatchMintOrder {
        uint256 membershipId;
        address[] recipients;
        uint256[][][] tokenIds;
        uint256[][][] amounts;
        TronicMain.TokenType[][] tokenTypes;
    }

    //vars for tokenids
    uint256 public constant tokenId1 = 1;
    uint256 public constant tokenId2 = 2;
    uint256 public constant tokenId3 = 3;
    uint256 public constant tokenId4 = 4;

    uint8 public constant TronicTier1Index = 1;
    uint8 public constant TronicTier2Index = 2;

    ERC1967Proxy public tronicMainProxy;

    TronicMain tronicMainContract;

    TronicMain tronicMainContractImplementation;
    TronicMembership tronicMembership;
    TronicToken tronicToken;
    TronicBrandLoyalty tronicBrandLoyaltyImplementation;

    //brand membership X
    TronicMembership brandXMembership;
    TronicToken brandXToken;
    TronicBrandLoyalty brandLoyaltyX;

    //brand membership Y
    TronicMembership brandYMembership;
    TronicToken brandYToken;
    TronicBrandLoyalty brandLoyaltyY;

    TronicMain.MembershipInfo membershipX;
    TronicMain.MembershipInfo membershipY;

    uint256 membershipIDX;
    uint256 membershipIDY;

    uint256 brandIDX;
    uint256 brandIDY;

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

    address payable public defaultTBAImplementationAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");

    address public brandLoyaltyAddressX;
    address public membershipAddressX;
    address public tokenAddressX;

    address public brandLoyaltyAddressY;
    address public membershipAddressY;
    address public tokenAddressY;

    address public tronicTokenId1TBA;
    address public tronicTokenId2TBA;
    address public tronicTokenId3TBA;
    address public tronicTokenId4TBA;

    uint256 fungibleTypeIdX1;
    uint256 fungibleTypeIdY1;
    uint256 nonFungibleTypeIdX1;
    uint256 nonFungibleTypeIdY1;

    TronicMembership.MembershipTier[] public membershipTiers;

    string initialUriX = "http://setup-exampleX.com/token/";
    string initialUriY = "http://setup-exampleY.com/token/";

    function setUp() public {
        //deploy tronic contracts
        vm.startPrank(tronicOwner);

        tronicMembership = new TronicMembership();
        tronicToken = new TronicToken();
        tronicBrandLoyaltyImplementation = new TronicBrandLoyalty();
        tronicMainContractImplementation = new TronicMain();

        //tronicMainContract is a proxy contract
        tronicMainProxy =
        new ERC1967Proxy(address(tronicMainContractImplementation), abi.encodeWithSignature(
            "initialize(address,address,address,address,address,address,uint8)",
            tronicAdmin,
            address(tronicBrandLoyaltyImplementation),
            address(tronicMembership),
            address(tronicToken),
            registryAddress,
            defaultTBAImplementationAddress,
            10 //maxtiers
        ));

        tronicMainContract = TronicMain(address(tronicMainProxy));

        assertEq(tronicMainContract.maxTiersPerMembership(), 10);

        //initialize Tronic Token by adding tronicMainProxy address as admin
        tronicToken.initialize(tronicAdmin);

        //initialize Tronic Member1155 by adding tronicMainProxy address as admin
        tronicBrandLoyaltyImplementation.initialize(
            defaultTBAImplementationAddress,
            registryAddress,
            "Brand Tronic",
            "TRONIC",
            "http://BrandTronicExample.com/",
            false, // isBound,
            tronicAdmin
        );

        //initialize tronicMembership
        tronicMembership.initialize(
            "TronicMembership",
            "TRONIC",
            "http://TronicMembership.com/",
            10_000, // maxMintable,
            true, // isElastic,
            10,
            tronicAdmin
        ); //10 - max tiers

        vm.stopPrank();

        // deploy membership contracts
        vm.startPrank(tronicAdmin);

        //set admin
        tronicMembership.addAdmin(address(tronicMainProxy));
        tronicToken.addAdmin(address(tronicMainProxy));
        tronicBrandLoyaltyImplementation.addAdmin(address(tronicMainProxy));

        //deploy brand loyalty contracts
        (brandIDX, brandLoyaltyAddressX, tokenAddressX) =
            tronicMainContract.deployBrand("Brand X", "XXX", "http://BrandX.com/", false);

        (brandIDY, brandLoyaltyAddressY, tokenAddressY) =
            tronicMainContract.deployBrand("Brand Y", "YYY", "http://BrandY.com/", false);

        //create membership tiers
        //create membership tiers for tronicMembership
        TronicMembership.MembershipTier[] memory tiers = new TronicMembership.MembershipTier[](2);
        tiers[0] = ITronicMembership.MembershipTier({
            tierId: "tierX",
            duration: 30 days,
            isOpen: true,
            tierURI: "http://tierX.com/"
        });

        tiers[1] = ITronicMembership.MembershipTier({
            tierId: "tierY",
            duration: 120 days,
            isOpen: false,
            tierURI: "http://tierY.com/"
        });

        tronicMembership.createMembershipTiers(tiers);

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
            true, //iselastic
            tiers
        );

        // Set up initial state
        uint64 initialMaxSupply = 100_000;

        fungibleTypeIdX1 =
            tronicMainContract.createFungibleTokenType(initialMaxSupply, initialUriX, membershipIDX);

        fungibleTypeIdY1 =
            tronicMainContract.createFungibleTokenType(initialMaxSupply, initialUriY, membershipIDY);

        nonFungibleTypeIdX1 =
            tronicMainContract.createNonFungibleTokenType(initialUriX, 1_000_000, membershipIDX);

        nonFungibleTypeIdY1 =
            tronicMainContract.createNonFungibleTokenType(initialUriY, 25_000, membershipIDY);

        ///mint brand loyalty nfts

        (tronicTokenId1TBA,) = tronicMainContract.mintBrandLoyaltyToken(user1, brandIDX);
        (tronicTokenId2TBA,) = tronicMainContract.mintBrandLoyaltyToken(user2, brandIDX);
        (tronicTokenId3TBA,) = tronicMainContract.mintBrandLoyaltyToken(user3, brandIDY);
        (tronicTokenId4TBA,) = tronicMainContract.mintBrandLoyaltyToken(user4, brandIDY);

        //mint Tronic Brand Loyalty nfts from TronicMain to users 1-4 and return their tbas
        tronicMainContract.mintMembership(user1, membershipIDX, 1);
        tronicMainContract.mintMembership(user2, membershipIDX, 1);
        tronicMainContract.mintMembership(user3, membershipIDY, 1);
        tronicMainContract.mintMembership(user4, membershipIDY, 1);

        // tronicMembership.setMembershipToken(tokenId1, TronicTier1Index);
        // tronicMembership.setMembershipToken(tokenId2, TronicTier1Index);
        // tronicMembership.setMembershipToken(tokenId3, TronicTier2Index);
        // tronicMembership.setMembershipToken(tokenId4, TronicTier2Index);
        vm.stopPrank();

        // get membership x and y details, membership ids: x=0 and y=1
        membershipX = tronicMainContract.getMembershipInfo(membershipIDX);
        membershipY = tronicMainContract.getMembershipInfo(membershipIDY);

        //get brand loyalty contracts
        address brandXTokenAddress = tronicMainContract.getBrandInfo(brandIDX).tokenAddress;
        address brandYTokenAddress = tronicMainContract.getBrandInfo(brandIDY).tokenAddress;

        // get membership contracts
        brandXMembership = TronicMembership(membershipX.membershipAddress);
        brandXToken = TronicToken(brandXTokenAddress);
        brandYMembership = TronicMembership(membershipY.membershipAddress);
        brandYToken = TronicToken(brandYTokenAddress);

        brandLoyaltyX = TronicBrandLoyalty(brandLoyaltyAddressX);
        brandLoyaltyY = TronicBrandLoyalty(brandLoyaltyAddressY);

        //verify that users have tronic membership nfts
        assertEq(brandLoyaltyX.ownerOf(tokenId1), user1);
        assertEq(brandLoyaltyX.ownerOf(tokenId2), user2);
        assertEq(brandLoyaltyY.ownerOf(tokenId1), user3);
        assertEq(brandLoyaltyY.ownerOf(tokenId2), user4);
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
    function prepareBatchProcessData(BatchMintOrder[] memory orders)
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
