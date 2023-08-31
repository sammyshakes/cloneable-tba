// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "./TronicTestBase.sol";

contract TokenboundAccountTest is TronicTestBase {
    function testMintingToken() public {
        console.log("SETUP - tokenbound account address: ", tbaAddress);
        console.log("SETUP - Tronic erc721 token address: ", address(tronicERC721));
        console.log("SETUP - Tronic erc1155 token address: ", address(tronicERC1155));
        console.log("SETUP - registry address: ", registryAddress);

        // Mint test token
        vm.prank(address(tronicAdminContract));
        //tokenid 1 was already minted in the setup function
        uint256 tokenId = 2;
        address tba = tronicERC721.mint(user1, tokenId);
        console.log("tokenbound account created: ", tba);
        assertEq(tronicERC721.ownerOf(tokenId), user1);
        //deployed tba
        IERC6551Account tbaAccount = IERC6551Account(payable(address(tba)));

        // user1 should own tokenbound account
        assertEq(tbaAccount.owner(), user1);

        console.log("token owner: ", tronicERC721.ownerOf(tokenId));
        console.log("tbaAccount owner: ", tbaAccount.owner());

        //transfer token to another user
        vm.prank(user1);
        tronicERC721.transferFrom(user1, user2, tokenId);

        //user1 should own token and therefore control tba
        assertEq(tronicERC721.ownerOf(tokenId), user2);
        assertEq(tbaAccount.owner(), user2);
    }

    // function testProjectEntry() public {
    //clone a brandErc1155
    //     ERC1155Cloneable project = ERC1155Cloneable(Clones.clone(address(brandERC1155)));
    //     console.log("project address: ", address(project));

    //     //initialize project
    //     project.initialize("http://project1.com/", address(this), address(this));
    // }

    // function testGetAssets() public {
    //     // Mint test token and grant tba to user1
    //     address tba = token.mint(user1, 1);
    //     TokenboundAccount tbaAccount = TokenboundAccount(payable(address(tba)));

    //     // Mint brand erc1155 tokens to tba
    //     brandERC1155.mint(address(tbaAccount), 1, 1000);

    //     // Use getAssets function to fetch assets
    //     (
    //         IERC20[] memory erc20s,
    //         uint256[] memory erc20BalancesAmounts,
    //         IERC721[] memory erc721s,
    //         uint256[] memory erc721TokenIds,
    //         IERC1155[] memory erc1155s,
    //         uint256[][] memory erc1155Ids,
    //         uint256[][] memory erc1155Amounts
    //     ) = tbaAccount.getAssets();

    //     // There should be 1 ERC721 token (the one we minted)
    //     assertEq(erc721s.length, 1);
    //     // The balance of the ERC721 token should be 1
    //     assertEq(erc721TokenIds[0], 1);

    //     // There should be 1 ERC1155 token (the one we minted)
    //     assertEq(erc1155s.length, 1);
    //     // The ERC1155 token should have the ID 1 and the amount 1000
    //     assertEq(erc1155Ids[0][0], 1);
    //     assertEq(erc1155Amounts[0][0], 1000);

    //     // There should be no ERC20 tokens
    //     assertEq(erc20s.length, 0);
    // }

    // function testERC721Integration() public {
    //     vm.startPrank(user1);
    //     token.mint(address(this), 1);
    //     token.approve(address(account), 1);
    //     token.safeTransferFrom(address(this), address(account), 1);

    //     (,, IERC1155[] memory erc1155Tokens) = account.getAssets();
    //     assertEq(erc1155Tokens.length, 0);

    //     (, IERC721[] memory erc721Tokens,) = account.getAssets();
    //     assertEq(erc721Tokens.length, 1);
    //     console.log("erc721Tokens[0]: ", erc721Tokens[0]);
    //     // assertEq(erc721Tokens[0], token);

    //     vm.stopPrank();
    // }

    // function testERC1155Integration() public {
    //     vm.startPrank(user1);

    //     brandERC1155.mint(address(this), 1, 10);
    //     brandERC1155.setApprovalForAll(address(account), true);
    //     brandERC1155.safeTransferFrom(address(this), address(account), 1, 5, "");

    //     (,, IERC1155[] memory erc1155Tokens) = account.getAssets();
    //     assertEq(erc1155Tokens.length, 1);
    //     assertEq(erc1155Tokens[0], brandERC1155);

    //     vm.stopPrank();
    // }

    // function testReceiveTokens(address tokenContract) public {
    //     // Send tokens
    //     IERC20(tokenContract).transfer(address(account), 100);

    //     // Account should receive tokens
    // }

    // function testTransferToken() public {
    //     // Approve account
    //     vm.prank(address(this));
    //     token.approve(address(account), 1);

    //     // Transfer token out
    //     account.transferToken(address(token), 1, 1);

    //     // Token should be transferred back
    // }
}
