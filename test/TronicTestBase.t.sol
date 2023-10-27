// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TronicMain.sol";
import "../src/interfaces/IERC6551Account.sol";

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
/// - Deploys TronicERC721 and TronicERC1155 implementations
///   - tronicERC721: The Tronic ERC721 token contract
///   - tronicERC1155: The Tronic ERC1155 token contract
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

    TronicMain tronicMainContract;
    TronicMembership tronicERC721;
    TronicToken tronicERC1155;

    TronicMembership membershipXERC721;
    TronicToken membershipXERC1155;
    TronicMembership membershipYERC721;
    TronicToken membershipYERC1155;

    TronicMain.MembershipInfo membershipX;
    TronicMain.MembershipInfo membershipY;

    uint256 membershipIDX;
    uint256 membershipIDY;

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

    address public clone721AddressX;
    address public clone1155AddressX;
    address public clone721AddressY;
    address public clone1155AddressY;

    address public tronicTokenId1TBA;
    address public tronicTokenId2TBA;
    address public tronicTokenId3TBA;
    address public tronicTokenId4TBA;

    uint256 fungibleTypeIdX1;
    uint256 fungibleTypeIdY1;
    uint256 nonFungibleTypeIdX1;
    uint256 nonFungibleTypeIdY1;

    string[] public tiers;
    uint128[] public durations;
    bool[] public isOpens;

    string initialUriX = "http://setup-exampleX.com/token/";
    string initialUriY = "http://setup-exampleY.com/token/";

    function setUp() public {
        //deploy tronic contracts
        vm.startPrank(tronicOwner);
        tronicERC721 = new TronicMembership();
        tronicERC1155 = new TronicToken();

        tronicMainContract =
        new TronicMain(tronicAdmin, address(tronicERC721), address(tronicERC1155), registryAddress, defaultTBAImplementationAddress);

        //initialize Tronic erc1155
        tronicERC1155.initialize(address(tronicMainContract));

        //initialize tronicERC721
        tronicERC721.initialize(
            defaultTBAImplementationAddress,
            registryAddress,
            "Original721",
            "OR721",
            "http://example721.com/",
            10, //max tiers
            10_000, //max supply
            true, //isElastic
            false, //isBound
            tronicAdmin
        );

        vm.stopPrank();

        // deploy membership contracts
        vm.startPrank(tronicAdmin);

        //set admin
        tronicERC721.addAdmin(address(tronicMainContract));

        (membershipIDX, clone721AddressX, clone1155AddressX) = tronicMainContract.deployMembership(
            "XClone721",
            "XCL721",
            "http://Xclone721.com/",
            10_000,
            true, //iselastic
            false,
            tiers,
            durations,
            isOpens
        );

        (membershipIDY, clone721AddressY, clone1155AddressY) = tronicMainContract.deployMembership(
            "YClone721",
            "YCL721",
            "http://Yclone721.com/",
            10_000,
            false, //is not elastic
            false,
            tiers,
            durations,
            isOpens
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

        vm.stopPrank();

        vm.startPrank(address(tronicMainContract));

        //mint TronicMembership nfts to users 1-4 and return their tbas
        (tronicTokenId1TBA,) = tronicERC721.mint(user1);
        (tronicTokenId2TBA,) = tronicERC721.mint(user2);
        (tronicTokenId3TBA,) = tronicERC721.mint(user3);
        (tronicTokenId4TBA,) = tronicERC721.mint(user4);

        //create membership tiers for tronicERC721
        string[] memory tierIds = new string[](2);
        tierIds[0] = "tierX";
        tierIds[1] = "tierY";

        durations = new uint128[](2);
        durations[0] = 30 days;
        durations[1] = 120 days;

        isOpens = new bool[](2);
        isOpens[0] = true;
        isOpens[1] = false;

        tronicERC721.createMembershipTiers(tierIds, durations, isOpens);

        tronicERC721.setTokenMembership(tokenId1, TronicTier1Index);
        tronicERC721.setTokenMembership(tokenId2, TronicTier1Index);
        tronicERC721.setTokenMembership(tokenId3, TronicTier2Index);
        tronicERC721.setTokenMembership(tokenId4, TronicTier2Index);
        vm.stopPrank();

        // get membership x and y details, membership ids: x=0 and y=1
        membershipX = tronicMainContract.getMembershipInfo(membershipIDX);
        membershipY = tronicMainContract.getMembershipInfo(membershipIDY);

        // get membership contracts
        membershipXERC721 = TronicMembership(membershipX.membershipAddress);
        membershipXERC1155 = TronicToken(membershipX.tokenAddress);
        membershipYERC721 = TronicMembership(membershipY.membershipAddress);
        membershipYERC1155 = TronicToken(membershipY.tokenAddress);

        //verify that users have tronic membership nfts
        assertEq(tronicERC721.ownerOf(tokenId1), user1);
        assertEq(tronicERC721.ownerOf(tokenId2), user2);
        assertEq(tronicERC721.ownerOf(tokenId3), user3);
        assertEq(tronicERC721.ownerOf(tokenId4), user4);
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
