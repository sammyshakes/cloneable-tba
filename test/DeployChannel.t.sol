// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract DeployChannel is TronicTestBase {
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

        // get channel x and y details, channel ids: x=0 and y=1
        TronicAdmin.ChannelInfo memory channelX = tronicAdminContract.getChannelInfo(channelIDX);
        TronicAdmin.ChannelInfo memory channelY = tronicAdminContract.getChannelInfo(channelIDY);

        // get channel contracts
        ERC721CloneableTBA channelXERC721 = ERC721CloneableTBA(channelX.erc721Address);
        ERC1155Cloneable channelXERC1155 = ERC1155Cloneable(channelX.erc1155Address);
        ERC721CloneableTBA channelYERC721 = ERC721CloneableTBA(channelY.erc721Address);
        ERC1155Cloneable channelYERC1155 = ERC1155Cloneable(channelY.erc1155Address);

        // check that the channel details are correctly set
        assertEq(channelX.erc721Address, clone721AddressX);
        assertEq(channelX.erc1155Address, clone1155AddressX);
        assertEq(channelX.channelName, "SetupChannelX");
        assertEq(channelY.erc721Address, clone721AddressY);
        assertEq(channelY.erc1155Address, clone1155AddressY);
        assertEq(channelY.channelName, "SetupChannelY");

        //assert that tronicAdmin is the owner of channel erc721 and erc1155 token contracts
        assertEq(tronicAdmin, channelXERC721.owner());
        assertEq(tronicAdmin, channelXERC1155.owner());
        assertEq(tronicAdmin, channelYERC721.owner());
        assertEq(tronicAdmin, channelYERC1155.owner());

        // check id tronicAdminContract isAdmin
        assertEq(channelXERC721.isAdmin(address(tronicAdminContract)), true);
        assertEq(channelXERC721.isAdmin(tronicAdmin), true);
        assertEq(tronicAdminContract.isAdmin(tronicAdmin), true);

        //get name and symbol
        console.log("channelXERC721 name: ", channelXERC721.name());
        console.log("channelXERC721 symbol: ", channelXERC721.symbol());

        IERC6551Registry channelXERC721Registry = channelXERC721.registry();

        //get registry address
        console.log("channelXERC721 registry address: ", address(channelXERC721Registry));

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

        vm.stopPrank();
    }
}
