// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract DeployChannel is TronicTestBase {
    function testInitialSetup() public {
        // get channel x and y details, channel ids: x=0 and y=1
        TronicAdmin.ChannelInfo memory channelX = tronicAdminContract.getChannelInfo(channelIDX);
        TronicAdmin.ChannelInfo memory channelY = tronicAdminContract.getChannelInfo(channelIDY);

        // get channel contracts
        ERC721CloneableTBA channelXERC721 = ERC721CloneableTBA(channelX.erc721Address);
        ERC1155Cloneable channelXERC1155 = ERC1155Cloneable(channelX.erc1155Address);
        ERC721CloneableTBA channelYERC721 = ERC721CloneableTBA(channelY.erc721Address);
        ERC1155Cloneable channelYERC1155 = ERC1155Cloneable(channelY.erc1155Address);

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
}
