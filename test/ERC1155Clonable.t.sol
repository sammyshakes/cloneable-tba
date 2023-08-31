// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// imports
import "./TronicTestBase.sol";

contract ERC1155CloneTest is TronicTestBase {
// TODO: Refactor tests for new contract structure
// function testCreateClone() public {
//     vm.prank(tronicAdmin);
//     (, address erc1155CloneAddress) =
//         factory.deployPartner(admin1, "", "", "", "Clone1155", "CL1155", "http://example.com1/");

//     console.log("clone address: ", erc1155CloneAddress);

//     assertEq(ERC1155Cloneable(erc1155CloneAddress).uri(1), "http://example.com1/");
//     assertEq(ERC1155Cloneable(erc1155CloneAddress).balanceOf(user1, 1), 0);
// }

// function testMintClone() public {
//     vm.prank(tronicAdmin);
//     (, address erc1155CloneAddress) =
//         factory.deployPartner(admin1, "", "", "", "Clone1155", "CL1155", "http://example.com2/");

//     ERC1155Cloneable clone = ERC1155Cloneable(erc1155CloneAddress);

//     vm.startPrank(admin1);

//     //create token types
//     clone.createFungibleType(1, "http://example.com2/1");
//     clone.createFungibleType(2, "http://example.com2/2");
//     clone.createFungibleType(3, "http://example.com2/3");

//     //mint tokens
//     clone.mintFungible(user1, 1, 1);

//     assertEq(clone.uri(1), "http://example.com2/1");
//     assertEq(clone.balanceOf(user1, 1), 1);

//     clone.mintFungible(user1, 2, 10);
//     clone.mintFungible(user1, 3, 5);

//     assertEq(clone.balanceOf(user1, 2), 10);
//     assertEq(clone.balanceOf(user1, 3), 5);

//     clone.mintFungible(user2, 1, 10);
//     clone.mintFungible(user2, 2, 5);

//     assertEq(clone.balanceOf(user2, 1), 10);
//     assertEq(clone.balanceOf(user2, 2), 5);
//     vm.stopPrank();

//     // transfer tokens from user1 to user2
//     vm.prank(user1);
//     clone.safeTransferFrom(user1, user2, 1, 1, "");
// }

// // Test new token types
// function testCreateTokenType() public {
//     vm.prank(tronicAdmin);
//     (, address erc1155CloneAddress) = factory.deployPartner(admin1, "", "", "", "", "", "");

//     vm.prank(admin1);
//     ERC1155Cloneable(erc1155CloneAddress).createFungibleType(4, "http://example.com");

//     // assertEq(ERC1155Cloneable(clone).uri(4), "http://example.com");
// }

// // Test setting fungible URI
// function testSetFungibleURI() public {
//     vm.prank(tronicAdmin);
//     (, address erc1155CloneAddress) = factory.deployPartner(admin1, "", "", "", "", "", "");

//     //create token type
//     vm.startPrank(admin1);
//     ERC1155Cloneable(erc1155CloneAddress).createFungibleType(1, "http://example.com");
//     ERC1155Cloneable(erc1155CloneAddress).setFungibleURI(1, "http://fungible.com");
//     vm.stopPrank();

//     assertEq(ERC1155Cloneable(erc1155CloneAddress).uri(1), "http://fungible.com");
// }

// // Test safe transfer
// function testSafeTransfer() public {
//     vm.prank(tronicAdmin);
//     (, address erc1155CloneAddress) = factory.deployPartner(admin1, "", "", "", "", "", "");

//     ERC1155Cloneable clonedERC1155 = ERC1155Cloneable(erc1155CloneAddress);

//     vm.startPrank(admin1);
//     // create token type
//     clonedERC1155.createFungibleType(1, "http://example.com");

//     clonedERC1155.mintFungible(user1, 1, 10);
//     vm.stopPrank();

//     // Approve transferFrom
//     vm.prank(user1);
//     clonedERC1155.safeTransferFrom(user1, user2, 1, 5, "");

//     assertEq(clonedERC1155.balanceOf(user1, 1), 5);
//     assertEq(clonedERC1155.balanceOf(user2, 1), 5);
// }

// // Clone ERC721 token
// function testCloneERC721() public {
//     string memory name = "MyToken";
//     string memory symbol = "MTK";

//     vm.prank(tronicAdmin);
//     (address erc721CloneAddress,) = factory.deployPartner(admin1, name, symbol, "", "", "", "");

//     ERC721CloneableTBA token = ERC721CloneableTBA(erc721CloneAddress);

//     assertEq(token.name(), name);
//     assertEq(token.symbol(), symbol);
// }

// function testCloneERC1155() public {
//     //get number of clones
//     uint256 numClones = factory.getNumERC1155Clones();

//     vm.prank(tronicAdmin);
//     (, address clone1155Address) =
//         factory.deployPartner(user1, "", "", "", "Clone1155", "CL1155", "http://clone1155.com/");

//     // clone should exist
//     assertNotEq(clone1155Address, address(0));

//     // Check the clone has correct uri and admin
//     ERC1155Cloneable clone1155 = ERC1155Cloneable(clone1155Address);
//     assertEq(clone1155.uri(1), "http://clone1155.com/");
//     assertEq(clone1155.isAdmin(user1), true);

//     // Check the clone can be retrieved using getERC1155Clone function
//     assertEq(factory.getERC1155Clone(numClones), clone1155Address);

//     //create token types
//     vm.startPrank(user1);
//     clone1155.createFungibleType(1, "http://clone1155.com/");

//     // mint token to user1
//     clone1155.mintFungible(user1, 1, 1);

//     // transfer token to user2
//     clone1155.safeTransferFrom(user1, user2, 1, 1, "");
//     vm.stopPrank();
// }
}
