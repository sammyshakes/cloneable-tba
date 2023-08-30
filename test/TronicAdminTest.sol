// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TronicAdmin.sol";
import "../src/interfaces/IERC6551Account.sol";

contract TronicAdminTest is Test {
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
    address public tronicAdmin = address(0x6);

    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");

    address public clone721AddressX;
    address public clone1155AddressX;
    address public clone721AddressY;
    address public clone1155AddressY;

    function setUp() public {
        tbaCloneable = IERC6551Account(tbaAddress);
        tronicERC721 = new ERC721CloneableTBA();
        tronicERC1155 = new ERC1155Cloneable();

        tronicAdminContract =
        new TronicAdmin(tronicAdmin, address(tronicERC721), address(tronicERC1155), address(tbaCloneable), tbaAddress);

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

        partnerXERC721 = ERC721CloneableTBA(clone721AddressX);
        partnerXERC1155 = ERC1155Cloneable(clone1155AddressX);
        partnerYERC721 = ERC721CloneableTBA(clone721AddressY);
        partnerYERC1155 = ERC1155Cloneable(clone1155AddressY);

        partnerX = tronicAdminContract.getPartnerInfo(partnerIDX);
        partnerY = tronicAdminContract.getPartnerInfo(partnerIDY);
    }

    function testInitialSetup() public {
        assertEq(tronicAdminContract.owner(), address(this));
        assertEq(tronicAdminContract.partnerCounter(), 2);
        console.log("tronicAdminContract address: ", address(tronicAdminContract));
        console.log("tronicERC721 address: ", address(tronicERC721));
        console.log("tronicERC1155 address: ", address(tronicERC1155));
        console.log("tbaAddress: ", tbaAddress);
        console.log("registryAddress: ", registryAddress);
        console.log("clone721AddressX: ", clone721AddressX);
        console.log("clone1155AddressX: ", clone1155AddressX);
        console.log("clone721AddressY: ", clone721AddressY);
        console.log("clone1155AddressY: ", clone1155AddressY);

        // check that the partner details are correctly set
        assertEq(partnerX.erc721Address, clone721AddressX);
        assertEq(partnerX.erc1155Address, clone1155AddressX);
        assertEq(partnerX.partnerName, "SetupPartnerX");
        assertEq(partnerY.erc721Address, clone721AddressY);
        assertEq(partnerY.erc1155Address, clone1155AddressY);
        assertEq(partnerY.partnerName, "SetupPartnerY");
    }

    function testCreateFungibleType() public {
        // Set up initial state
        uint64 initialMaxSupply = 1000;
        string memory initialUriX = "http://exampleX.com/token/";
        string memory initialUriY = "http://exampleY.com/token/";

        // Admin creates a fungible token type for partnerX and partnerY
        vm.startPrank(tronicAdmin);
        uint256 fungibleIDX =
            tronicAdminContract.createFungibleTokenType(initialMaxSupply, initialUriX, partnerIDX);

        //create a new fungible token type for partnerY
        uint256 fungibleIDY =
            tronicAdminContract.createFungibleTokenType(initialMaxSupply, initialUriY, partnerIDY);

        vm.stopPrank();

        // Verify that the new token type has the correct attributes
        ERC1155Cloneable.FungibleTokenInfo memory tokenInfo =
            partnerXERC1155.getFungibleTokenInfo(fungibleIDX);

        assertEq(tokenInfo.maxSupply, initialMaxSupply, "Incorrect maxSupply");
        assertEq(tokenInfo.uri, initialUriX, "Incorrect URI");
        assertEq(tokenInfo.totalMinted, 0, "Incorrect totalMinted");
        assertEq(tokenInfo.totalBurned, 0, "Incorrect totalBurned");

        // Verify that the new token type has the correct attributes
        ERC1155Cloneable.FungibleTokenInfo memory tokenInfoY =
            partnerYERC1155.getFungibleTokenInfo(fungibleIDY);

        assertEq(tokenInfoY.maxSupply, initialMaxSupply, "Incorrect maxSupply");
        assertEq(tokenInfoY.uri, initialUriY, "Incorrect URI");
        assertEq(tokenInfoY.totalMinted, 0, "Incorrect totalMinted");
        assertEq(tokenInfoY.totalBurned, 0, "Incorrect totalBurned");

        // mint 100 tokens to user1
        vm.prank(tronicAdmin);
        tronicAdminContract.mintFungibleERC1155(user1, fungibleIDX, 100, partnerIDX);

        assertEq(partnerXERC1155.balanceOf(user1, fungibleIDX), 100);
    }

    function testCreateNonFungibleType() public {
        // Set up initial state
        string memory initialUriX = "http://exampleNFTX.com/token";
        string memory initialUriY = "http://exampleNFTY.com/token";
        uint256 maxMintable = 1000;
        uint256 startingId = 10_000;

        // Admin creates a non-fungible token type for partnerX and partnerY
        vm.startPrank(tronicAdmin);
        uint256 nonFungibleIDX = tronicAdminContract.createNonFungibleTokenType(
            initialUriX, maxMintable, startingId, partnerIDX
        );

        //create a new non-fungible token type for partnerY
        uint256 nonFungibleIDY = tronicAdminContract.createNonFungibleTokenType(
            initialUriY, maxMintable, startingId, partnerIDY
        );

        vm.stopPrank();

        // Verify that the new token type has the correct attributes
        ERC1155Cloneable.NFTTokenInfo memory tokenInfo =
            partnerXERC1155.getNFTTokenInfo(nonFungibleIDX);

        assertEq(tokenInfo.baseURI, initialUriX, "Incorrect URI");
        assertEq(tokenInfo.maxMintable, maxMintable, "Incorrect maxMintable");
        assertEq(tokenInfo.nextIdToMint, startingId, "Incorrect nextIdToMint");

        // Verify that the new token type has the correct attributes
        ERC1155Cloneable.NFTTokenInfo memory tokenInfoY =
            partnerYERC1155.getNFTTokenInfo(nonFungibleIDY);

        assertEq(tokenInfoY.baseURI, initialUriY, "Incorrect URI");
        assertEq(tokenInfoY.maxMintable, maxMintable, "Incorrect maxMintable");
        assertEq(tokenInfoY.nextIdToMint, startingId, "Incorrect nextIdToMint");

        uint256 userBalanceBefore = partnerXERC1155.balanceOf(user1, startingId);

        // mint a non-fungible token to user1
        vm.prank(tronicAdmin);
        tronicAdminContract.mintNonFungibleERC1155(user1, nonFungibleIDX, partnerIDX);

        assertEq(partnerXERC1155.balanceOf(user1, startingId), userBalanceBefore + 1);
    }

    function testDeployAndAddPartner() public {
        // get partner count
        uint256 partnerCount = tronicAdminContract.partnerCounter();

        // Define partner details
        string memory name721 = "TestClone721";
        string memory symbol721 = "TCL721";
        string memory uri721 = "http://testclone721.com/";
        string memory name1155 = "TestClone1155";
        string memory symbol1155 = "TCL1155";
        string memory uri1155 = "http://testclone1155.com/";
        string memory partnerName = "TestPartner";

        // Simulate as admin
        vm.prank(tronicAdmin);

        // Call the deployAndAddPartner function
        (address testClone721Address, address testClone1155AddressY) = tronicAdminContract
            .deployPartner(name721, symbol721, uri721, name1155, symbol1155, uri1155, partnerName);

        // Retrieve the added partner's details
        TronicAdmin.PartnerInfo memory partner = tronicAdminContract.getPartnerInfo(partnerCount);

        // Assert that the partner's details are correctly set
        assertEq(partner.erc721Address, testClone721Address);
        assertEq(partner.erc1155Address, testClone1155AddressY);
        assertEq(partner.partnerName, partnerName);

        // TODO: check that PartnerAdded event was emitted
    }

    // function testBatchProcess() public {
    //     // Define recipients, partners, tokenIds, amounts, and tokenTypes
    //     address[] memory recipients = [user1, user2];
    //     uint256[][] memory partnerIds = [[partnerIDX, partnerIDY], [partnerIDX]];
    //     uint256[][][] memory tokenIds = [[[1, 2], [1, 2]], [[1]]];
    //     uint256[][][] memory amounts = [[[10, 20], [50, 50]], [[5]]];
    //     TronicAdmin.TokenType[][][] memory tokenTypes = [
    //         [TokenType.ERC1155, TokenType.ERC1155],
    //         [TokenType.ERC1155, TokenType.ERC1155],
    //         [TokenType.ERC1155]
    //     ];

    //     // Action: Call batchProcess
    //     tronicAdminContract.batchProcess(recipients, partnerIds, tokenIds, amounts, tokenTypes);

    //     // Assertions (for simplicity, we'll just draft the assertions. The actual implementation might need to call other functions to get balances)
    //     // For Alice
    //     assertEq(tronicERC1155.balanceOf(alice, token1), 10, "Incorrect balance for Alice's token1");
    //     assertEq(tronicERC1155.balanceOf(alice, token2), 20, "Incorrect balance for Alice's token2");
    //     assert(tronicERC721.ownerOf(token3) == alice, "Alice does not own the minted ERC721 token");

    //     // For Bob
    //     assertEq(tronicERC1155.balanceOf(bob, token4), 5, "Incorrect balance for Bob's token4");
    // }
}
