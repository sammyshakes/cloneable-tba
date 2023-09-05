// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract DeployChannel is TronicTestBase {
    function testInitialSetup() public {
        // get channel x and y details, channel ids: x=0 and y=1
        // TronicAdmin.ChannelInfo memory channelX = tronicAdminContract.getChannelInfo(channelIDX);
        // TronicAdmin.ChannelInfo memory channelY = tronicAdminContract.getChannelInfo(channelIDY);

        // // get channel contracts
        // ERC721CloneableTBA channelXERC721 = ERC721CloneableTBA(channelX.erc721Address);
        // ERC1155Cloneable channelXERC1155 = ERC1155Cloneable(channelX.erc1155Address);
        // ERC721CloneableTBA channelYERC721 = ERC721CloneableTBA(channelY.erc721Address);
        // ERC1155Cloneable channelYERC1155 = ERC1155Cloneable(channelY.erc1155Address);

        //assert that tronicAdmin is the owner of channel erc721 and erc1155 token contracts
        assertEq(tronicAdmin, channelXERC721.owner());
        assertEq(tronicAdmin, channelXERC1155.owner());
        assertEq(tronicAdmin, channelYERC721.owner());
        assertEq(tronicAdmin, channelYERC1155.owner());

        // check if tronicAdminContract isAdmin
        assertEq(channelXERC721.isAdmin(address(tronicAdminContract)), true);
        assertEq(tronicAdminContract.isAdmin(tronicAdmin), true);

        //get name and symbol
        console.log("channelXERC721 name: ", channelXERC721.name());
        console.log("channelXERC721 symbol: ", channelXERC721.symbol());

        vm.startPrank(tronicAdmin);
        // set membership tier
        channelXERC721.setMembershipTier(1, "tier1111");

        // get membership tier
        console.log("channelXERC721 membership tier: ", channelXERC721.getMembershipTier(1));

        address user1TBAchannelX = tronicAdminContract.mintERC721(user1TBA, channelIDX);
        // get tba account address
        address tbaAccount = channelXERC721.getTBAccount(1);
        console.log("tbaAccount: ", tbaAccount);
        assertEq(tbaAccount, user1TBAchannelX);

        // verify that user1TBA owns token
        assertEq(channelXERC721.ownerOf(1), user1TBA);

        // Channel Y onboards a new user
        address user2TBAchannelY = tronicAdminContract.mintERC721(user2TBA, channelIDY);

        // get tba account address
        address tbaAccountY = channelYERC721.getTBAccount(1);
        console.log("tbaAccountY: ", tbaAccountY);
        assert(tbaAccountY == user2TBAchannelY);

        // verify that user2TBA owns token
        assertEq(channelYERC721.ownerOf(1), user2TBA);

        // mint fungible tokens id=0 to user1TBAchannelX and user2TBAchannelY
        channelXERC1155.mintFungible(user1TBAchannelX, 0, 100);
        channelYERC1155.mintFungible(user2TBAchannelY, 0, 100);

        //verify that user1TBAchannelX and user2TBAchannelY have 100 tokens
        assertEq(channelXERC1155.balanceOf(user1TBAchannelX, 0), 100);
        assertEq(channelYERC1155.balanceOf(user2TBAchannelY, 0), 100);

        vm.stopPrank();
    }

    function testCreateTypesFromFromAdmin() public {
        vm.startPrank(tronicAdmin);
        // create fungible token type for channelx
        uint256 typeId = tronicAdminContract.createFungibleTokenType(
            1000, "http://example.com/token/", channelIDX
        );

        // get fungible token type from channelx
        ERC1155Cloneable.FungibleTokenInfo memory tokenType =
            channelXERC1155.getFungibleTokenInfo(typeId);

        // create non fungible token type
        typeId = tronicAdminContract.createNonFungibleTokenType(
            "http://example.com/token/", 10_000, channelIDX
        );

        // get non fungible token type from channelx
        ERC1155Cloneable.NFTTokenInfo memory nonFungibleTokenType =
            channelXERC1155.getNFTTokenInfo(typeId);

        // create fungible token type for channely
    }

    function testBatchProcess() public {
        // instantiate BatchMintOrder array
        BatchMintOrder[] memory orders = new BatchMintOrder[](2);

        vm.startPrank(tronicAdmin);

        // For order1
        address[] memory _recipients = new address[](2);
        _recipients[0] = user1;
        _recipients[1] = user2;

        uint256[][][] memory _tokenIds = new uint256[][][](2);
        _tokenIds[0] = new uint256[][](1);
        _tokenIds[0][0] = new uint256[](1);
        _tokenIds[0][0][0] = 1; // tokenId for user1 irrelevant when calling erc721 contract

        _tokenIds[1] = new uint256[][](1);
        _tokenIds[1][0] = new uint256[](1);
        _tokenIds[1][0][0] = 2; // tokenId for user2 irrelevant when calling erc721 contract

        uint256[][][] memory _amounts = new uint256[][][](2);
        _amounts[0] = new uint256[][](1);
        _amounts[0][0] = new uint256[](1);
        _amounts[0][0][0] = 1; // amount for user1's tokenId
        _amounts[1] = new uint256[][](1);
        _amounts[1][0] = new uint256[](1);
        _amounts[1][0][0] = 1; // amount for user2's tokenId

        TronicAdmin.TokenType[][] memory _tokenTypes = new TronicAdmin.TokenType[][](2);
        _tokenTypes[0] = new TronicAdmin.TokenType[](1);
        _tokenTypes[0][0] = TronicAdmin.TokenType.ERC721;
        _tokenTypes[1] = new TronicAdmin.TokenType[](1);
        _tokenTypes[1][0] = TronicAdmin.TokenType.ERC721;

        BatchMintOrder memory order1 = createBatchMintOrder(
            channelIDX, // channelIdX
            _recipients,
            _tokenIds,
            _amounts,
            _tokenTypes
        );

        // For order2
        _recipients = new address[](1);
        _recipients[0] = user3;

        _tokenIds = new uint256[][][](1);
        _tokenIds[0] = new uint256[][](1);
        _tokenIds[0][0] = new uint256[](2);

        _tokenIds[0][0][0] = tronicAdminContract.createFungibleTokenType(
            1000, "http://example.com/token/", channelIDY
        ); // first tokenId for user3

        _tokenIds[0][0][1] = tronicAdminContract.createFungibleTokenType(
            5000, "http://example.com/token/", channelIDY
        ); // second tokenId for user3

        _amounts = new uint256[][][](1);
        _amounts[0] = new uint256[][](1);
        _amounts[0][0] = new uint256[](2);
        _amounts[0][0][0] = 10; // amount for user3's first tokenId
        _amounts[0][0][1] = 20; // amount for user3's second tokenId

        _tokenTypes = new TronicAdmin.TokenType[][](1);
        _tokenTypes[0] = new TronicAdmin.TokenType[](1);
        _tokenTypes[0][0] = TronicAdmin.TokenType.ERC1155; // type for user3's first and second tokenId

        BatchMintOrder memory order2 = createBatchMintOrder(
            channelIDY, // channelIdY
            _recipients,
            _tokenIds,
            _amounts,
            _tokenTypes
        );

        //populate orders array
        orders[0] = order1;
        orders[1] = order2;

        // Prepare data for batchProcess using the helper function
        (
            uint256[] memory channelIds,
            address[][] memory recipients,
            uint256[][][][] memory tokenIds,
            uint256[][][][] memory amounts,
            TronicAdmin.TokenType[][][] memory tokenTypes
        ) = prepareBatchProcessData(orders);

        // Execute the batchProcess function
        tronicAdminContract.batchProcess(channelIds, recipients, tokenIds, amounts, tokenTypes);

        vm.stopPrank();

        // Assertions
        // For channel 1, ERC721
        assertEq(ERC721(clone721AddressX).ownerOf(1), user1);
        assertEq(ERC721(clone721AddressX).ownerOf(2), user2);

        // For channel 2, ERC1155
        assertEq(ERC1155(clone1155AddressY).balanceOf(user3, _tokenIds[0][0][0]), 10);
        assertEq(ERC1155(clone1155AddressY).balanceOf(user3, _tokenIds[0][0][1]), 20);
    }

    function prepareBatchProcessData(BatchMintOrder[] memory orders)
        internal
        returns (
            uint256[] memory channelIds,
            address[][] memory recipients,
            uint256[][][][] memory tokenIds,
            uint256[][][][] memory amounts,
            TronicAdmin.TokenType[][][] memory tokenTypes
        )
    {
        uint256 orderCount = orders.length;

        // Initialize the arrays
        channelIds = new uint256[](orderCount);
        recipients = new address[][](orderCount);
        tokenIds = new uint256[][][][](orderCount);
        amounts = new uint256[][][][](orderCount);
        tokenTypes = new TronicAdmin.TokenType[][][](orderCount);

        // Populate the arrays based on the input orders
        for (uint256 i = 0; i < orderCount; i++) {
            channelIds[i] = orders[i].channelId;
            recipients[i] = orders[i].recipients;
            tokenIds[i] = orders[i].tokenIds;
            amounts[i] = orders[i].amounts;
            tokenTypes[i] = orders[i].tokenTypes;
        }

        return (channelIds, recipients, tokenIds, amounts, tokenTypes);
    }
}
