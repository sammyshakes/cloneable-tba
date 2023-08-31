// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TronicAdmin.sol";
import "../src/interfaces/IERC6551Account.sol";

/// @dev Sets up the initial state for testing the TronicAdmin system
/// @notice Deploys the core TronicAdmin, ERC721, and ERC1155 contracts
/// @notice Creates user accounts, default partners, and initial token types
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
/// - Deploys 2 sample partners
///   - partnerX: Partner 0
///   - partnerY: Partner 1
///
/// - Mints initial sample tokens
///
/// This provides a complete base environment for writing tests. Any contract
/// inheriting this base will have access to the initialized contracts, accounts,
/// and sample data to test against.
contract TronicTestBase is Test {
    struct BatchMintOrder {
        uint256 partnerId;
        address[] recipients;
        uint256[][] tokenIds;
        uint256[][] amounts;
        TronicAdmin.TokenType[] tokenTypes;
    }

    TronicAdmin tronicAdminContract;
    ERC721CloneableTBA tronicERC721;
    ERC1155Cloneable tronicERC1155;
    IERC6551Account tbaCloneable;

    ERC721CloneableTBA partnerXERC721;
    ERC1155Cloneable partnerXERC1155;
    ERC721CloneableTBA partnerYERC721;
    ERC1155Cloneable partnerYERC1155;

    TronicAdmin.PartnerInfo partnerX;
    TronicAdmin.PartnerInfo partnerY;

    uint256 partnerIDX = 0;
    uint256 partnerIDY = 1;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    // new address for an unauthorized user
    address public unauthorizedUser = address(0x4);

    address public tronicOwner = address(0x5);

    //tronicAdmin will be some privatekey stored on backend
    address public tronicAdmin = address(0x6);

    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");

    address public clone721AddressX;
    address public clone1155AddressX;
    address public clone721AddressY;
    address public clone1155AddressY;
    address public user1TBA;

    function setUp() public {
        tbaCloneable = IERC6551Account(tbaAddress);

        //deploy tronic contracts
        vm.startPrank(tronicOwner);
        tronicERC721 = new ERC721CloneableTBA();
        tronicERC1155 = new ERC1155Cloneable();

        tronicAdminContract =
        new TronicAdmin(tronicAdmin, address(tronicERC721), address(tronicERC1155), tbaAddress, tbaAddress);

        //initialize Tronic erc1155
        tronicERC1155.initialize(
            "http://example1155.com/", address(tronicAdminContract), "Original1155", "OR1155"
        );

        vm.stopPrank();

        //initialize tronicERC721
        tronicERC721.initialize(
            tbaAddress,
            registryAddress,
            "Original721",
            "OR721",
            "http://example721.com/",
            address(tronicAdminContract)
        );

        // deploy partner contracts
        vm.startPrank(tronicAdmin);
        (clone721AddressX, clone1155AddressX) = tronicAdminContract.deployPartner(
            "XClone721",
            "XCL721",
            "http://Xclone721.com/",
            "XClone1155",
            "XCL1155",
            "http://Xclone1155.com/",
            "SetupPartnerX"
        );

        (clone721AddressY, clone1155AddressY) = tronicAdminContract.deployPartner(
            "YClone721",
            "YCL721",
            "http://Yclone721.com/",
            "YClone1155",
            "YCL1155",
            "http://Yclone1155.com/",
            "SetupPartnerY"
        );

        // Set up initial state
        uint64 initialMaxSupply = 1000;
        string memory initialUriX = "http://setup-exampleX.com/token/";
        string memory initialUriY = "http://setup-exampleY.com/token/";

        tronicAdminContract.createFungibleTokenType(initialMaxSupply, initialUriX, partnerIDX);
        tronicAdminContract.createFungibleTokenType(initialMaxSupply, initialUriY, partnerIDY);

        vm.stopPrank();

        vm.prank(address(tronicAdminContract));
        //mint tronic erc721cloneabletba membership nft to user1
        user1TBA = tronicERC721.mint(user1, 1);

        partnerXERC721 = ERC721CloneableTBA(clone721AddressX);
        partnerXERC1155 = ERC1155Cloneable(clone1155AddressX);
        partnerYERC721 = ERC721CloneableTBA(clone721AddressY);
        partnerYERC1155 = ERC1155Cloneable(clone1155AddressY);

        partnerX = tronicAdminContract.getPartnerInfo(partnerIDX);
        partnerY = tronicAdminContract.getPartnerInfo(partnerIDY);
    }
}
