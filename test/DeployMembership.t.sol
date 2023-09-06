// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract DeployMembership is TronicTestBase {
    function testInitialSetup() public {
        //assert that tronicAdmin is the owner of membership erc721 and erc1155 token contracts
        assertEq(tronicAdmin, membershipXERC721.owner());
        assertEq(tronicAdmin, membershipXERC1155.owner());
        assertEq(tronicAdmin, membershipYERC721.owner());
        assertEq(tronicAdmin, membershipYERC1155.owner());

        // check if tronicAdminContract isAdmin
        assertEq(membershipXERC721.isAdmin(address(tronicAdminContract)), true);
        assertEq(tronicAdminContract.isAdmin(tronicAdmin), true);

        //get name and symbol
        console.log("membershipXERC721 name: ", membershipXERC721.name());
        console.log("membershipXERC721 symbol: ", membershipXERC721.symbol());

        vm.startPrank(tronicAdmin);
        // set membership tier
        membershipXERC721.setMembershipTier(1, "tier1111");

        // get membership tier
        console.log("membershipXERC721 membership tier: ", membershipXERC721.getMembershipTier(1));

        address user1TBAmembershipX = tronicAdminContract.mintERC721(user1TBA, membershipIDX);
        // get tba account address
        address tbaAccount = membershipXERC721.getTBAccount(1);
        console.log("tbaAccount: ", tbaAccount);
        assertEq(tbaAccount, user1TBAmembershipX);

        // verify that user1TBA owns token
        assertEq(membershipXERC721.ownerOf(1), user1TBA);

        // Membership Y onboards a new user
        address user2TBAmembershipY = tronicAdminContract.mintERC721(user2TBA, membershipIDY);

        // get tba account address
        address tbaAccountY = membershipYERC721.getTBAccount(1);
        console.log("tbaAccountY: ", tbaAccountY);
        assert(tbaAccountY == user2TBAmembershipY);

        // verify that user2TBA owns token
        assertEq(membershipYERC721.ownerOf(1), user2TBA);

        // mint fungible tokens id=0 to user1TBAmembershipX and user2TBAmembershipY
        membershipXERC1155.mintFungible(user1TBAmembershipX, 0, 100);
        membershipYERC1155.mintFungible(user2TBAmembershipY, 0, 100);

        //verify that user1TBAmembershipX and user2TBAmembershipY have 100 tokens
        assertEq(membershipXERC1155.balanceOf(user1TBAmembershipX, 0), 100);
        assertEq(membershipYERC1155.balanceOf(user2TBAmembershipY, 0), 100);

        vm.stopPrank();
    }

    function testCreateTypesFromFromAdmin() public {
        vm.startPrank(tronicAdmin);
        // create fungible token type for membershipx
        uint256 typeId = tronicAdminContract.createFungibleTokenType(
            1000, "http://example.com/token/", membershipIDX
        );

        // get fungible token type from membershipx
        TronicToken.FungibleTokenInfo memory tokenType =
            membershipXERC1155.getFungibleTokenInfo(typeId);

        console.log("tokenType.uri: ", tokenType.uri);
        console.log("tokenType.maxSupply: ", tokenType.maxSupply);
        console.log("tokenType.totalMinted: ", tokenType.totalMinted);
        console.log("tokenType.totalBurned: ", tokenType.totalBurned);

        // create non fungible token type
        typeId = tronicAdminContract.createNonFungibleTokenType(
            "http://example.com/token/", 10_000, membershipIDX
        );

        // get non fungible token type from membershipx
        TronicToken.NFTokenInfo memory nonFungibleTokenType =
            membershipXERC1155.getNFTokenInfo(typeId);

        console.log("nonFungibleTokenType.startingTokenId: ", nonFungibleTokenType.startingTokenId);
        console.log("nonFungibleTokenType.maxMintable: ", nonFungibleTokenType.maxMintable);
        console.log("nonFungibleTokenType.totalMinted: ", nonFungibleTokenType.totalMinted);
        console.log("nonFungibleTokenType.baseURI: ", nonFungibleTokenType.baseURI);
    }

    // test deployMembership function
    // function testDeployMembership() public {
    //     // deploy membership
    //     address membershipAddress = tronicAdminContract.deployMembership(
    //         "membershipX", "CHX", "http://example.com/token/", "SetupMembershipX"
    //     );

    //     // get membership info
    //     TronicAdmin.MembershipInfo memory membershipInfo = tronicAdminContract.getMembershipInfo(membershipIDX);

    //     // get membership contracts
    //     membershipXERC721 = ERC721CloneableTBA(membershipInfo.erc721Address);
    //     membershipXERC1155 = ERC1155Cloneable(membershipInfo.erc1155Address);

    //     // assert that tronicAdmin is the owner of membership erc721 and erc1155 token contracts
    //     assertEq(tronicAdmin, membershipXERC721.owner());
    //     assertEq(tronicAdmin, membershipXERC1155.owner());

    //     // get name and symbol
    //     console.log("membershipXERC721 name: ", membershipXERC721.name());
    //     console.log("membershipXERC721 symbol: ", membershipXERC721.symbol());

    //     // set membership tier
    //     membershipXERC721.setMembershipTier(1, "tier1111");

    //     // get membership tier
    //     console.log("membershipXERC721 membership tier: ", membershipXERC721.getMembershipTier(1));

    //     // mint fungible tokens id=0 to user1TBAmembershipX and user2TBAmembershipY
    //     membershipXERC1155.mintFungible(user1TBAmembershipX, 0, 100);
    //     membershipYERC1155.mintFungible(user2TBAmembershipY, 0, 100);

    //     //verify that user1TBAmembershipX and user2TBAmembershipY have 100 tokens
    //     assertEq(membershipXERC1155.balanceOf(user1TBAmembershipX, 0), 100);
    //     assertEq(membershipYERC1155.balanceOf(user2TBAmembershipY, 0), 100);
    // }
}
