// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TronicAdmin.sol";
import "../src/interfaces/IERC6551Account.sol";

/// @dev Sets up the initial state for testing the TronicAdmin system
/// @notice Deploys the core TronicAdmin, ERC721, and ERC1155 contracts
/// @notice Creates user accounts, default channels, and initial token types
/// @notice Should be called automatically by any contract inheriting TronicTestBase
///
/// Details:
///
/// - Deploys TronicAdmin and assigns roles
///   - tronicAdminContract: The main TronicAdmin contract
///   - tronicOwner: Owner account for TronicAdmin
///   - tronicAdmin: Admin account for TronicAdmin
///
/// - Deploys TronicERC721 and TronicERC1155 implementations
///   - tronicERC721: The Tronic ERC721 token contract
///   - tronicERC1155: The Tronic ERC1155 token contract
///
/// - Initializes Tronic contracts and assigns admin
///
/// - Deploys mock TokenBoundAccount implementation
///   - tbaAddress: Address of mock TBA implementation
///   - tbaCloneable: Interface to mock TBA
///
/// - Creates user accounts
///   - user1, user2, user3: Sample user accounts
///   - unauthorizedUser: Unauthorized user account
///
/// - Deploys 2 sample channels
///   - channelX: Channel 0
///   - channelY: Channel 1
///
/// - Mints initial sample tokens
///
/// This provides a complete base environment for writing tests. Any contract
/// inheriting this base will have access to the initialized contracts, accounts,
/// and sample data to test against.
contract TronicTestBase is Test {
    struct BatchMintOrder {
        uint256 channelId;
        address[] recipients;
        uint256[][][] tokenIds;
        uint256[][][] amounts;
        TronicAdmin.TokenType[][] tokenTypes;
    }

    TronicAdmin tronicAdminContract;
    ERC721CloneableTBA tronicERC721;
    ERC1155Cloneable tronicERC1155;
    IERC6551Account tbaCloneable;

    ERC721CloneableTBA channelXERC721;
    ERC1155Cloneable channelXERC1155;
    ERC721CloneableTBA channelYERC721;
    ERC1155Cloneable channelYERC1155;

    TronicAdmin.ChannelInfo channelX;
    TronicAdmin.ChannelInfo channelY;

    uint256 channelIDX = 0;
    uint256 channelIDY = 1;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    address public user4 = address(0x4);
    // new address for an unauthorized user
    address public unauthorizedUser = address(0x666);

    address public tronicOwner = address(0x5);

    //tronicAdmin will be some privatekey stored on backend
    address public tronicAdmin = address(0x6);

    address public channelAdmin = address(0x7);

    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");

    address public clone721AddressX;
    address public clone1155AddressX;
    address public clone721AddressY;
    address public clone1155AddressY;

    address public user1TBA;
    address public user2TBA;
    address public user3TBA;
    address public user4TBA;

    function setUp() public {
        tbaCloneable = IERC6551Account(tbaAddress);

        //deploy tronic contracts
        vm.startPrank(tronicOwner);
        tronicERC721 = new ERC721CloneableTBA();
        tronicERC1155 = new ERC1155Cloneable();

        tronicAdminContract =
        new TronicAdmin(tronicAdmin, address(tronicERC721), address(tronicERC1155), registryAddress, tbaAddress);

        //initialize Tronic erc1155
        tronicERC1155.initialize(
            "http://example1155.com/", address(tronicAdminContract), "Original1155", "OR1155"
        );

        //initialize tronicERC721
        tronicERC721.initialize(
            tbaAddress,
            registryAddress,
            "Original721",
            "OR721",
            "http://example721.com/",
            10_000,
            tronicAdmin
        );

        vm.stopPrank();

        // deploy channel contracts
        vm.startPrank(tronicAdmin);

        //set admin
        tronicERC721.addAdmin(address(tronicAdminContract));

        (clone721AddressX, clone1155AddressX) = tronicAdminContract.deployChannel(
            "XClone721",
            "XCL721",
            "http://Xclone721.com/",
            10_000,
            "XClone1155",
            "XCL1155",
            "http://Xclone1155.com/",
            "SetupChannelX"
        );

        (clone721AddressY, clone1155AddressY) = tronicAdminContract.deployChannel(
            "YClone721",
            "YCL721",
            "http://Yclone721.com/",
            10_000,
            "YClone1155",
            "YCL1155",
            "http://Yclone1155.com/",
            "SetupChannelY"
        );

        // Set up initial state
        uint64 initialMaxSupply = 1000;
        string memory initialUriX = "http://setup-exampleX.com/token/";
        string memory initialUriY = "http://setup-exampleY.com/token/";

        tronicAdminContract.createFungibleTokenType(initialMaxSupply, initialUriX, channelIDX);

        tronicAdminContract.createFungibleTokenType(initialMaxSupply, initialUriY, channelIDY);

        tronicAdminContract.createNonFungibleTokenType(initialUriX, 10_000, channelIDX);

        tronicAdminContract.createNonFungibleTokenType(initialUriY, 25_000, channelIDY);

        vm.stopPrank();

        //setup some initial users
        //vars for tokenids
        uint256 tokenId1 = 1;
        uint256 tokenId2 = 2;
        uint256 tokenId3 = 3;
        uint256 tokenId4 = 4;

        vm.startPrank(address(tronicAdminContract));

        //mint tronic erc721cloneabletba membership nfts to users 1-4
        user1TBA = tronicERC721.mint(user1);
        user2TBA = tronicERC721.mint(user2);
        user3TBA = tronicERC721.mint(user3);
        user4TBA = tronicERC721.mint(user4);

        //set tronic Membership tiers based on some external factores
        //here token ids 1 and 2 are tier1, and ids 3 and 4 are tier2
        tronicERC721.setMembershipTier(tokenId1, "tier1");
        tronicERC721.setMembershipTier(tokenId2, "tier1");
        tronicERC721.setMembershipTier(tokenId3, "tier2");
        tronicERC721.setMembershipTier(tokenId4, "tier2");

        vm.stopPrank();

        // get channel x and y details, channel ids: x=0 and y=1
        channelX = tronicAdminContract.getChannelInfo(channelIDX);
        channelY = tronicAdminContract.getChannelInfo(channelIDY);

        // get channel contracts
        channelXERC721 = ERC721CloneableTBA(channelX.erc721Address);
        channelXERC1155 = ERC1155Cloneable(channelX.erc1155Address);
        channelYERC721 = ERC721CloneableTBA(channelY.erc721Address);
        channelYERC1155 = ERC1155Cloneable(channelY.erc1155Address);
    }

    // Implement the helper function to create instances of BatchMintOrder
    function createBatchMintOrder(
        uint256 _channelId,
        address[] memory _recipients,
        uint256[][][] memory _tokenIds,
        uint256[][][] memory _amounts,
        TronicAdmin.TokenType[][] memory _tokenTypes
    ) public pure returns (BatchMintOrder memory order) {
        order = BatchMintOrder({
            channelId: _channelId,
            recipients: _recipients,
            tokenIds: _tokenIds,
            amounts: _amounts,
            tokenTypes: _tokenTypes
        });
    }
}
