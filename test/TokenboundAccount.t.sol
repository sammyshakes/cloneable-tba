// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("MockERC721", "M721") {}

    function mint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }
}

contract TokenboundAccountTest is TronicTestBase {
    MockERC721 nft = new MockERC721();

    function testBasicTBA() public {
        console.log("SETUP - tokenbound account address: ", tbaAddress);
        console.log("SETUP - Tronic erc721 token address: ", address(tronicERC721));
        console.log("SETUP - Tronic erc1155 token address: ", address(tronicERC1155));
        console.log("SETUP - registry address: ", registryAddress);

        // Mint test token
        vm.prank(address(tronicAdminContract));
        //tokenid 1 was already minted in the setup function
        uint256 tokenId = 2;
        assertEq(tronicERC721.ownerOf(tokenId), user2);

        // get tba address for token from tronicERC721 contract
        address tba = tronicERC721.getTBAccount(tokenId);
        console.log("tokenbound account created: ", tba);
        //deployed tba
        IERC6551Account tbaAccount = IERC6551Account(payable(address(tba)));

        // user2 should own tokenbound account
        assertEq(tbaAccount.owner(), user2);

        console.log("token owner: ", tronicERC721.ownerOf(tokenId));
        console.log("tbaAccount owner: ", tbaAccount.owner());

        //transfer token to another user
        vm.prank(user2);
        tronicERC721.transferFrom(user2, user3, tokenId);

        //user3 should own token and therefore control tba
        assertEq(tronicERC721.ownerOf(tokenId), user3);
        assertEq(tbaAccount.owner(), user3);

        //get totalSupply
        console.log("total supply: ", tronicERC721.totalSupply());

        //burn token
        vm.prank(tronicAdmin);
        tronicERC721.burn(tokenId);

        //get totalSupply
        console.log("total supply: ", tronicERC721.totalSupply());

        //get maxSupply
        console.log("max supply: ", tronicERC721.maxSupply());
    }
}
