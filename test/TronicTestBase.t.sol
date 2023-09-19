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
///   - tronicAdminContract: The main TronicMain contract
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

    TronicMain tronicAdminContract;
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

    function setUp() public {
        //deploy tronic contracts
        vm.startPrank(tronicOwner);
        tronicERC721 = new TronicMembership();
        tronicERC1155 = new TronicToken();

        tronicAdminContract =
        new TronicMain(tronicAdmin, address(tronicERC721), address(tronicERC1155), registryAddress, defaultTBAImplementationAddress);

        //initialize Tronic erc1155
        tronicERC1155.initialize(address(tronicAdminContract));

        //initialize tronicERC721
        tronicERC721.initialize(
            defaultTBAImplementationAddress,
            registryAddress,
            "Original721",
            "OR721",
            "http://example721.com/",
            10,
            10_000,
            tronicAdmin
        );

        vm.stopPrank();

        // deploy membership contracts
        vm.startPrank(tronicAdmin);

        //set admin
        tronicERC721.addAdmin(address(tronicAdminContract));

        (membershipIDX, clone721AddressX, clone1155AddressX) = tronicAdminContract.deployMembership(
            "XClone721", "XCL721", "http://Xclone721.com/", 10_000
        );

        (membershipIDY, clone721AddressY, clone1155AddressY) = tronicAdminContract.deployMembership(
            "YClone721", "YCL721", "http://Yclone721.com/", 10_000
        );

        // Set up initial state
        uint64 initialMaxSupply = 100_000;
        string memory initialUriX = "http://setup-exampleX.com/token/";
        string memory initialUriY = "http://setup-exampleY.com/token/";

        fungibleTypeIdX1 = tronicAdminContract.createFungibleTokenType(
            initialMaxSupply, initialUriX, membershipIDX
        );

        fungibleTypeIdY1 = tronicAdminContract.createFungibleTokenType(
            initialMaxSupply, initialUriY, membershipIDY
        );

        nonFungibleTypeIdX1 =
            tronicAdminContract.createNonFungibleTokenType(initialUriX, 1_000_000, membershipIDX);

        nonFungibleTypeIdY1 =
            tronicAdminContract.createNonFungibleTokenType(initialUriY, 25_000, membershipIDY);

        vm.stopPrank();

        //setup some initial users
        //vars for tokenids
        uint256 tokenId1 = 1;
        uint256 tokenId2 = 2;
        uint256 tokenId3 = 3;
        uint256 tokenId4 = 4;

        vm.startPrank(address(tronicAdminContract));

        //mint TronicMembership nfts to users 1-4
        tronicTokenId1TBA = tronicERC721.mint(user1);
        tronicTokenId2TBA = tronicERC721.mint(user2);
        tronicTokenId3TBA = tronicERC721.mint(user3);
        tronicTokenId4TBA = tronicERC721.mint(user4);

        //set tronic Membership tiers based on some external factores
        //here token ids 1 and 2 are tier1, and ids 3 and 4 are tier2
        // tronicERC721.setMembershipTier(tokenId1, 0);
        // tronicERC721.setMembershipTier(tokenId2, 0);
        // tronicERC721.setMembershipTier(tokenId3, 0);
        // tronicERC721.setMembershipTier(tokenId4, 0);

        vm.stopPrank();

        // get membership x and y details, membership ids: x=0 and y=1
        membershipX = tronicAdminContract.getMembershipInfo(membershipIDX);
        membershipY = tronicAdminContract.getMembershipInfo(membershipIDY);

        // get membership contracts
        membershipXERC721 = TronicMembership(membershipX.membershipAddress);
        membershipXERC1155 = TronicToken(membershipX.tokenAddress);
        membershipYERC721 = TronicMembership(membershipY.membershipAddress);
        membershipYERC1155 = TronicToken(membershipY.tokenAddress);
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
