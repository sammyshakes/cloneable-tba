// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract TronicAdminTest is TronicTestBase {
    function testInitialSetup() public {
        assertEq(tronicAdminContract.owner(), tronicOwner);
        assertEq(tronicAdminContract.channelCounter(), 2);
        console.log("tronicAdminContract address: ", address(tronicAdminContract));
        console.log("tronicERC721 address: ", address(tronicERC721));
        console.log("tronicERC1155 address: ", address(tronicERC1155));
        console.log("tbaAddress: ", tbaAddress);
        console.log("registryAddress: ", registryAddress);
        console.log("clone721AddressX: ", clone721AddressX);
        console.log("clone1155AddressX: ", clone1155AddressX);
        console.log("clone721AddressY: ", clone721AddressY);
        console.log("clone1155AddressY: ", clone1155AddressY);

        // check that the channel details are correctly set
        assertEq(channelX.erc721Address, clone721AddressX);
        assertEq(channelX.erc1155Address, clone1155AddressX);
        assertEq(channelX.channelName, "SetupChannelX");
        assertEq(channelY.erc721Address, clone721AddressY);
        assertEq(channelY.erc1155Address, clone1155AddressY);
        assertEq(channelY.channelName, "SetupChannelY");

        //assert that TronicAdmin Contract is the owner of channel erc721 and erc1155 token contracts
        assertEq(tronicAdmin, channelXERC721.owner());
        assertEq(tronicAdmin, channelXERC1155.owner());
        assertEq(tronicAdmin, channelYERC721.owner());
        assertEq(tronicAdmin, channelYERC1155.owner());

        // get owner of tokenid 0
        address owner = tronicERC721.ownerOf(1);
        console.log("owner of tokenid 1: ", owner);
    }

    function testCreateFungibleType() public {
        // Set up initial state
        uint64 initialMaxSupply = 1000;
        string memory initialUriX = "http://exampleX.com/token/";
        string memory initialUriY = "http://exampleY.com/token/";

        // Admin creates a fungible token type for channelX and channelY
        vm.startPrank(tronicAdmin);
        uint256 fungibleIDX =
            tronicAdminContract.createFungibleTokenType(initialMaxSupply, initialUriX, channelIDX);

        //create a new fungible token type for channelY
        uint256 fungibleIDY =
            tronicAdminContract.createFungibleTokenType(initialMaxSupply, initialUriY, channelIDY);

        vm.stopPrank();

        // Verify that the new token type has the correct attributes
        ERC1155Cloneable.FungibleTokenInfo memory tokenInfo =
            channelXERC1155.getFungibleTokenInfo(fungibleIDX);

        assertEq(tokenInfo.maxSupply, initialMaxSupply, "Incorrect maxSupply");
        assertEq(tokenInfo.uri, initialUriX, "Incorrect URI");
        assertEq(tokenInfo.totalMinted, 0, "Incorrect totalMinted");
        assertEq(tokenInfo.totalBurned, 0, "Incorrect totalBurned");

        // Verify that the new token type has the correct attributes
        ERC1155Cloneable.FungibleTokenInfo memory tokenInfoY =
            channelYERC1155.getFungibleTokenInfo(fungibleIDY);

        assertEq(tokenInfoY.maxSupply, initialMaxSupply, "Incorrect maxSupply");
        assertEq(tokenInfoY.uri, initialUriY, "Incorrect URI");
        assertEq(tokenInfoY.totalMinted, 0, "Incorrect totalMinted");
        assertEq(tokenInfoY.totalBurned, 0, "Incorrect totalBurned");

        // mint 100 tokens to user1's tba
        vm.prank(tronicAdmin);
        tronicAdminContract.mintFungibleERC1155(channelIDX, user1TBA, fungibleIDX, 100);

        assertEq(channelXERC1155.balanceOf(user1TBA, fungibleIDX), 100);
    }

    function testCreateNonFungibleType() public {
        // Set up initial state
        string memory initialUriX = "http://exampleNFTX.com/token";
        string memory initialUriY = "http://exampleNFTY.com/token";
        uint64 maxMintable = 1000;

        // Admin creates a non-fungible token type for channelX and channelY
        vm.startPrank(tronicAdmin);
        uint256 nonFungibleIDX =
            tronicAdminContract.createNonFungibleTokenType(initialUriX, maxMintable, channelIDX);

        //create a new non-fungible token type for channelY
        uint256 nonFungibleIDY =
            tronicAdminContract.createNonFungibleTokenType(initialUriY, maxMintable, channelIDY);

        vm.stopPrank();

        // Verify that the new token type has the correct attributes
        ERC1155Cloneable.NFTTokenInfo memory tokenInfo =
            channelXERC1155.getNFTTokenInfo(nonFungibleIDX);

        assertEq(tokenInfo.baseURI, initialUriX, "Incorrect URI");
        assertEq(tokenInfo.maxMintable, maxMintable, "Incorrect maxMintable");
        assertEq(tokenInfo.totalMinted, 0, "Incorrect totalMinted");

        // Verify that the new token type has the correct attributes
        ERC1155Cloneable.NFTTokenInfo memory tokenInfoY =
            channelYERC1155.getNFTTokenInfo(nonFungibleIDY);

        assertEq(tokenInfoY.baseURI, initialUriY, "Incorrect URI");
        assertEq(tokenInfoY.maxMintable, maxMintable, "Incorrect maxMintable");
        assertEq(tokenInfoY.totalMinted, 0, "Incorrect totalMinted");

        uint256 userBalanceBefore = channelXERC1155.balanceOf(user1, nonFungibleIDX);

        // mint a non-fungible token to user1
        // vm.prank(tronicAdmin);
        // tronicAdminContract.mintNonFungibleERC1155(channelIDX, user1, nonFungibleIDX, 1);

        // assertEq(channelXERC1155.balanceOf(user1, nonFungibleIDX), userBalanceBefore + 1);
    }

    function testDeployAndAddChannel() public {
        // get channel count
        uint256 channelCount = tronicAdminContract.channelCounter();

        // Define channel details
        string memory name721 = "TestClone721";
        string memory symbol721 = "TCL721";
        string memory uri721 = "http://testclone721.com/";
        string memory name1155 = "TestClone1155";
        string memory symbol1155 = "TCL1155";
        string memory uri1155 = "http://testclone1155.com/";
        string memory channelName = "TestChannel";

        // maxsupply for channel erc721
        uint64 maxSupply = 10_000;

        // Simulate as admin
        vm.prank(tronicAdmin);

        // Call the deployAndAddChannel function
        (address testClone721Address, address testClone1155AddressY) = tronicAdminContract
            .deployChannel(
            name721, symbol721, uri721, maxSupply, name1155, symbol1155, uri1155, channelName
        );

        // Retrieve the added channel's details
        TronicAdmin.ChannelInfo memory channel = tronicAdminContract.getChannelInfo(channelCount);

        // Assert that the channel's details are correctly set
        assertEq(channel.erc721Address, testClone721Address);
        assertEq(channel.erc1155Address, testClone1155AddressY);
        assertEq(channel.channelName, channelName);

        // TODO: check that ChannelAdded event was emitted
    }

    // test getAccount function from ERC721CloneableTBA
    function testGetAccount() public {
        // get the token bound account
        address account = tronicERC721.getTBAccount(1);

        console.log("tokenbound account address: ", account);

        // check that the account is correct
        assertEq(account, user1TBA);
    }

    // function testBatchProcessMinting() public {

    //     uint256[] memory channelIds = new uint256[](2);
    //     channelIds[0] = channelIDX;
    //     channelIds[1] = channelIDY;

    //     // Set up recipients
    //     address[] memory recipients1 = new address[](2);
    //     recipients1[0] = user1;
    //     recipients1[1] = user2;
    //     address[] memory recipients2 = new address[](2);
    //     recipients2[0] = user2;
    //     recipients2[1] = user3;
    //     address[][] memory recipients = new address[][](2);
    //     recipients[0] = recipients1;
    //     recipients[1] = recipients2;
    //     uint256[][][] memory tokenIds1 = new uint256[][][](2);
    //     uint256[][][] memory tokenIds2 = new uint256[][][](2);

    //     uint256[] memory erc721TokenIdsForUser1 = new uint256[](1);
    //     erc721TokenIdsForUser1[0] = 1;
    //     uint256[] memory erc721TokenIdsForUser2 = new uint256[](1);
    //     erc721TokenIdsForUser2[0] = 2;
    //     uint256[] memory erc1155TokenIdsForUser1 = new uint256[](2);
    //     erc1155TokenIdsForUser1[0] = 3;
    //     erc1155TokenIdsForUser1[1] = 4;
    //     uint256[] memory erc1155TokenIdsForUser2 = new uint256[](2);
    //     erc1155TokenIdsForUser2[0] = 5;
    //     erc1155TokenIdsForUser2[1] = 6;

    //     tokenIds1[0] = [erc721TokenIdsForUser1, erc1155TokenIdsForUser1];
    //     tokenIds1[1] = [erc721TokenIdsForUser2, erc1155TokenIdsForUser2];

    //     tokenIds2[0] = [erc721TokenIdsForUser2, erc1155TokenIdsForUser2];
    //     tokenIds2[1] = [erc721TokenIdsForUser1, erc1155TokenIdsForUser1];

    //     uint256[][][][] memory tokenIds = new uint256[][][][](2);
    //     tokenIds[0] = tokenIds1;
    //     tokenIds[1] = tokenIds2;

    //     // Similar structure for amounts
    //     uint256[][][] memory amounts1 = new uint256[][][](2);
    //     uint256[][][] memory amounts2 = new uint256[][][](2);

    //     uint256[] memory erc721AmountsForUser1 = new uint256[](1);
    //     erc721AmountsForUser1[0] = 1;
    //     uint256[] memory erc721AmountsForUser2 = new uint256[](1);
    //     erc721AmountsForUser2[0] = 1;
    //     uint256[] memory erc1155AmountsForUser1 = new uint256[](2);
    //     erc1155AmountsForUser1[0] = 1;
    //     erc1155AmountsForUser1[1] = 2;
    //     uint256[] memory erc1155AmountsForUser2 = new uint256[](2);
    //     erc1155AmountsForUser2[0] = 2;
    //     erc1155AmountsForUser2[1] = 3;

    //     amounts1[0] = [erc721AmountsForUser1, erc1155AmountsForUser1];
    //     amounts1[1] = [erc721AmountsForUser2, erc1155AmountsForUser2];

    //     amounts2[0] = [erc721AmountsForUser2, erc1155AmountsForUser2];
    //     amounts2[1] = [erc721AmountsForUser1, erc1155AmountsForUser1];

    //     uint256[][][][] memory amounts = new uint256[][][][](2);
    //     amounts[0] = amounts1;
    //     amounts[1] = amounts2;

    //     // For tokenTypes
    //     TronicAdmin.TokenType[][] memory tokenTypes1 = new TronicAdmin.TokenType[][](2);
    //     TronicAdmin.TokenType[][] memory tokenTypes2 = new TronicAdmin.TokenType[][](2);

    //     tokenTypes1[0][0] = [TronicAdmin.TokenType.ERC721, TronicAdmin.TokenType.ERC1155];
    //     tokenTypes1[1] = [TronicAdmin.TokenType.ERC721, TronicAdmin.TokenType.ERC1155];

    //     tokenTypes2[0] = [TronicAdmin.TokenType.ERC721, TronicAdmin.TokenType.ERC1155];
    //     tokenTypes2[1] = [TronicAdmin.TokenType.ERC721, TronicAdmin.TokenType.ERC1155];

    //     TronicAdmin.TokenType[][][] memory tokenTypes = new TronicAdmin.TokenType[][][](2);
    //     tokenTypes[0] = tokenTypes1;
    //     tokenTypes[1] = tokenTypes2;

    //     tronicAdminContract.batchProcess(channelIds, recipients, tokenIds, amounts, tokenTypes);

    //     // Assertions to validate correct minting
    //     assertEq(channelXERC721.ownerOf(1), user1);
    //     assertEq(channelXERC1155.balanceOf(user2, 3), 1);
    //     assertEq(channelXERC1155.balanceOf(user2, 4), 2);
    //     assertEq(channelYERC721.ownerOf(7), user2);
    //     assertEq(channelYERC1155.balanceOf(user3, 9), 2);
    //     // ... Add more assertions as needed
    // }

    // struct BatchMintOrder {
    //     uint256 channelId;
    //     address[] recipients;
    //     uint256[][] tokenIds;
    //     uint256[][] amounts;
    //     TronicAdmin.TokenType[] tokenTypes;
    // }

    // function convertBatchMintOrdersToParameters(BatchMintOrder[] memory orders)
    //     public
    //     pure
    //     returns (
    //         uint256[] memory channelIds,
    //         address[][] memory recipients,
    //         uint256[][][][] memory tokenIds,
    //         uint256[][][][] memory amounts,
    //         TronicAdmin.TokenType[][][] memory tokenTypes
    //     )
    // {
    //     channelIds = new uint256[](orders.length);
    //     recipients = new address[][](orders.length);
    //     tokenIds = new uint256[][][][](orders.length);
    //     amounts = new uint256[][][][](orders.length);
    //     tokenTypes = new TronicAdmin.TokenType[][][](orders.length);

    //     for (uint256 i = 0; i < orders.length; i++) {
    //         channelIds[i] = orders[i].channelId;

    //         recipients[i] = orders[i].recipients;

    //         // Adjusting for the 3D structure
    //         tokenIds[i] = new uint256[][][](orders[i].recipients.length);
    //         for (uint256 j = 0; j < orders[i].recipients.length; j++) {
    //             tokenIds[i][j] = [orders[i].tokenIds[j]];
    //         }

    //         amounts[i] = new uint256[][][](orders[i].recipients.length);
    //         for (uint256 j = 0; j < orders[i].recipients.length; j++) {
    //             amounts[i][j] = [orders[i].amounts[j]];
    //         }

    //         tokenTypes[i] = new TronicAdmin.TokenType[][](orders[i].recipients.length);
    //         for (uint256 j = 0; j < orders[i].recipients.length; j++) {
    //             tokenTypes[i][j] = [orders[i].tokenTypes[j]];
    //         }
    //     }

    //     return (channelIds, recipients, tokenIds, amounts, tokenTypes);
    // }
}
