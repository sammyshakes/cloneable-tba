// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract TokenTest is TronicTestBase {
    //function to test tronicToken nftminting capabilities
    function testCreateNFTType() public {
        // prank as main contract and createNFTType on tronicToken ERC1155
        //test base uri
        string memory baseURI = "https://example.com/token/";
        uint64 maxMintable = 1000;

        vm.startPrank(address(tronicMainContract));

        // test some invalid cases
        // max mintable of 0
        vm.expectRevert();
        tronicERC1155.createNFTType(baseURI, 0);

        uint256 typeId = tronicERC1155.createNFTType(baseURI, maxMintable);

        //attempt to mint for invalid typeId
        vm.expectRevert();
        tronicERC1155.mintNFT(1000, user1);

        //mint tokennft type
        tronicERC1155.mintNFT(typeId, user1);

        //verify that user1 owns token
        uint256[] memory tokenIds = tronicERC1155.getNftIdsForOwner(user1);

        //get user address form nftOwners mapping on tronicERC1155
        address owner = tronicERC1155.nftOwners(tokenIds[0]);

        //verify that user1 owns token
        assertEq(owner, user1);

        //create another type and verify starting tokenid
        uint256 typeId2 = tronicERC1155.createNFTType(baseURI, 10_000);
        tronicERC1155.mintNFT(typeId2, user1);

        //get tokeninfo to ensure starting tokenid is correct
        assertEq(tronicERC1155.getNFTokenInfo(typeId2).startingTokenId, 100_000 + maxMintable);

        //create another type and verify starting tokenid
        uint256 typeId3 = tronicERC1155.createNFTType(baseURI, 100_000 + 10_000 + maxMintable);
        tronicERC1155.mintNFT(typeId3, user1);

        tokenIds = tronicERC1155.getNftIdsForOwner(user1);

        //attempt to mint more than maxMintable
        // create NFTtype with lower maxMintable
        uint256 typeId4 = tronicERC1155.createNFTType(baseURI, 2);

        tronicERC1155.mintNFT(typeId4, user1);
        tronicERC1155.mintNFT(typeId4, user1);

        //attempt to mint more than maxMintable
        vm.expectRevert();
        tronicERC1155.mintNFT(typeId4, user1);

        tokenIds = tronicERC1155.getNftIdsForOwner(user1);

        //mint using mintNFTs function
        tronicERC1155.mintNFTs(typeId, user3, 100);

        //verify that user1 owns token
        tokenIds = tronicERC1155.getNftIdsForOwner(user3);
        assertEq(tokenIds.length, 100);

        // attempt to mint more than maxMintable using mintNFTs function
        vm.expectRevert();
        tronicERC1155.mintNFTs(typeId, user3, 1000);

        //burn nft type token
        tronicERC1155.burn(user3, tokenIds[50], 1);

        vm.stopPrank();
    }

    //test isFungible
    function testIsFungible() public {
        // create an nft type
        string memory baseURI = "https://example.com/token/";
        uint64 maxMintable = 1000;

        vm.startPrank(address(tronicMainContract));
        uint256 typeId = tronicERC1155.createNFTType(baseURI, maxMintable);

        //mint token
        tronicERC1155.mintNFT(typeId, user1);
        uint256[] memory tokenIds = tronicERC1155.getNftIdsForOwner(user1);
        uint256 tokenId = tokenIds[0];

        //verify that token is not fungible
        assertEq(tronicERC1155.isFungible(tokenId), false);

        vm.stopPrank();
    }

    //test setLevel and getLevel on tronic token
    function testSetLevel() public {
        // create an nft type
        string memory baseURI = "https://example.com/token/";
        uint64 maxMintable = 1000;

        vm.startPrank(address(tronicMainContract));
        uint256 typeId = tronicERC1155.createNFTType(baseURI, maxMintable);

        //mint token
        tronicERC1155.mintNFT(typeId, user1);
        uint256[] memory tokenIds = tronicERC1155.getNftIdsForOwner(user1);
        uint256 tokenId = tokenIds[0];
        uint256 level = 100;

        //set level
        tronicERC1155.setLevel(tokenId, level);
        assertEq(tronicERC1155.getLevel(tokenId), level);

        vm.stopPrank();
    }

    //test uri function
    function testUri() public {
        // create an nft type
        string memory baseURI = "https://example.com/token";
        uint64 maxMintable = 1000;

        vm.startPrank(address(tronicMainContract));
        uint256 typeId = tronicERC1155.createNFTType(baseURI, maxMintable);

        //mint token
        tronicERC1155.mintNFT(typeId, user1);
        uint256[] memory tokenIds = tronicERC1155.getNftIdsForOwner(user1);
        uint256 tokenId = tokenIds[0];

        //verify uri
        assertEq(tronicERC1155.uri(tokenId), "https://example.com/token/100001");

        //try to get uri from invalid tokenid
        assertEq(tronicERC1155.uri(50_000), "");

        vm.stopPrank();
    }

    //test burn function
    function testBurn() public {
        //create testuser
        address testUser = address(0x123);

        // create an nft type
        string memory baseURI = "https://example.com/token/";
        uint64 maxMintable = 1000;

        vm.startPrank(address(tronicMainContract));
        uint256 typeId = tronicERC1155.createNFTType(baseURI, maxMintable);

        //mint token
        tronicERC1155.mintNFT(typeId, testUser);
        uint256[] memory tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        uint256 tokenId = tokenIds[0];

        //burn token
        tronicERC1155.burn(testUser, tokenId, 1);

        //verify that testUser no longer owns token
        tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        assertEq(tokenIds.length, 0);

        //attempt to create fungible type with maxSupply of 0
        vm.expectRevert();
        tronicERC1155.createFungibleType(0, baseURI);

        //create fungible token
        uint256 fungibleTypeId = tronicERC1155.createFungibleType(maxMintable, baseURI);

        //mint fungible token
        tronicERC1155.mintFungible(testUser, fungibleTypeId, maxMintable);

        //burn fungible token
        tronicERC1155.burn(testUser, fungibleTypeId, maxMintable);

        //verify that testUser no longer owns token
        assertEq(tronicERC1155.balanceOf(testUser, fungibleTypeId), 0);

        vm.stopPrank();
    }

    //test admin functionality
    function testAdmin() public {
        //create testuser
        address testUser = address(0x123);

        // set testUser as admin
        vm.startPrank(address(tronicMainContract));
        tronicERC1155.addAdmin(testUser);

        //verify that testUser is admin
        assertEq(tronicERC1155.isAdmin(testUser), true);

        //revoke admin
        tronicERC1155.removeAdmin(testUser);

        //verify that testUser is not admin
        assertEq(tronicERC1155.isAdmin(testUser), false);

        vm.stopPrank();
    }

    //test supportsInterface
    function testSupportsInterface() public {
        // call supportsInterface
        assertEq(tronicERC1155.supportsInterface(type(IERC165).interfaceId), true);
    }

    //test safeBatchTransferFrom function on TronicToken.sol
    function testSafeBatchTransferFrom() public {
        //create testuser
        address testUser = address(0x123);

        // create an nft type
        string memory baseURI = "https://example.com/token/";
        uint64 maxMintable = 1000;

        vm.startPrank(address(tronicMainContract));
        uint256 typeId = tronicERC1155.createNFTType(baseURI, maxMintable);

        //mint token
        tronicERC1155.mintNFT(typeId, testUser);

        //verify that testUser owns token
        uint256[] memory tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        assertEq(tokenIds.length, 1);

        //create another nft type
        uint256 typeId2 = tronicERC1155.createNFTType(baseURI, maxMintable);

        //mint token
        tronicERC1155.mintNFT(typeId2, testUser);

        vm.stopPrank();

        //verify that testUser owns token
        tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        assertEq(tokenIds.length, 2);

        //create amounts array
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1;
        amounts[1] = 1;

        // try to transfer tokens to another user
        vm.prank(testUser);
        tronicERC1155.safeBatchTransferFrom(testUser, user1, tokenIds, amounts, "");

        //verify that testUser no longer owns token
        tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        assertEq(tokenIds.length, 0);

        //verify that user1 owns token
        tokenIds = tronicERC1155.getNftIdsForOwner(user1);
        assertEq(tokenIds.length, 2);
    }

    //testSafeTransferFrom function on TronicToken.sol
    function testSafeTransferFrom() public {
        //create testuser
        address testUser = address(0x123);

        // create an nft type
        string memory baseURI = "https://example.com/token/";
        uint64 maxMintable = 1000;

        vm.startPrank(address(tronicMainContract));
        uint256 typeId = tronicERC1155.createNFTType(baseURI, maxMintable);

        //mint token
        tronicERC1155.mintNFT(typeId, testUser);
        vm.stopPrank();

        //verify that testUser owns token
        uint256[] memory tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        assertEq(tokenIds.length, 1);

        //test safeTransferFrom
        vm.prank(testUser);
        tronicERC1155.safeTransferFrom(testUser, user1, tokenIds[0], 1, "");

        //verify that testUser no longer owns token
        tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        assertEq(tokenIds.length, 0);

        //verify that user1 owns token
        tokenIds = tronicERC1155.getNftIdsForOwner(user1);
        assertEq(tokenIds.length, 1);

        vm.startPrank(address(tronicMainContract));

        //create a fungible type
        uint256 fungibleTypeId = tronicERC1155.createFungibleType(maxMintable, baseURI);

        //mint fungible token
        tronicERC1155.mintFungible(testUser, fungibleTypeId, maxMintable);

        vm.stopPrank();

        //verify that testUser owns token
        assertEq(tronicERC1155.balanceOf(testUser, fungibleTypeId), maxMintable);

        //test safeTransferFrom
        vm.prank(testUser);
        tronicERC1155.safeTransferFrom(testUser, user1, fungibleTypeId, maxMintable, "");

        //verify that testUser no longer owns token
        assertEq(tronicERC1155.balanceOf(testUser, fungibleTypeId), 0);

        //verify that user1 owns token
        assertEq(tronicERC1155.balanceOf(user1, fungibleTypeId), maxMintable);
    }

    //test mintFungible function on TronicToken.sol
    function testMintFungible() public {
        //create testuser
        address testUser = address(0x123);
        uint256 fungibleTypeId = 1;
        uint64 maxMintable = 1000;

        string memory baseURI = "https://example.com/token/";

        vm.startPrank(address(tronicMainContract));

        //create fungible type
        fungibleTypeId = tronicERC1155.createFungibleType(maxMintable, baseURI);

        //attempt to mint fungible token for invalid tokentype
        vm.expectRevert();
        tronicERC1155.mintFungible(testUser, 1000, maxMintable);

        //mint fungible token
        tronicERC1155.mintFungible(testUser, fungibleTypeId, maxMintable);

        //verify that testUser owns token
        assertEq(tronicERC1155.balanceOf(testUser, fungibleTypeId), maxMintable);

        //attempt to mint more fungible tokens than maxMintable
        vm.expectRevert();
        tronicERC1155.mintFungible(testUser, fungibleTypeId, 1);
    }

    // test mintBatch function on TronicToken.sol
    function testMintBatch() public {
        //create testuser
        address testUser = address(0x123);

        uint64 maxMintable = 1000;

        string memory baseURI = "https://example.com/token/";

        vm.startPrank(address(tronicMainContract));

        //create fungible types
        uint256 fungibleTypeId = tronicERC1155.createFungibleType(maxMintable, baseURI);
        uint256 fungibleTypeId2 = tronicERC1155.createFungibleType(maxMintable, baseURI);

        //create nft types
        uint256 nftTypeId = tronicERC1155.createNFTType(baseURI, maxMintable);
        uint256 nftTypeId2 = tronicERC1155.createNFTType(baseURI, maxMintable);

        uint256[] memory tokenIds = new uint256[](4);
        tokenIds[0] = fungibleTypeId;
        tokenIds[1] = fungibleTypeId2;
        tokenIds[2] = nftTypeId;
        tokenIds[3] = nftTypeId2;

        uint256[] memory amounts = new uint256[](4);
        amounts[0] = 10;
        amounts[1] = 10;
        amounts[2] = 10;
        amounts[3] = 10;

        //mint tokens
        tronicERC1155.mintBatch(testUser, tokenIds, amounts, "");

        //Expect reverts
        //attempt to mint to zero address
        vm.expectRevert();
        tronicERC1155.mintBatch(address(0), tokenIds, amounts, "");

        //attempt with wrong sized arrays
        uint256[] memory tokenIds2 = new uint256[](3);
        tokenIds2[0] = fungibleTypeId;
        tokenIds2[1] = fungibleTypeId2;
        tokenIds2[2] = nftTypeId;

        vm.expectRevert();
        tronicERC1155.mintBatch(testUser, tokenIds2, amounts, "");

        //attempt to mint fungibles with invalid token type
        uint256[] memory tokenIds3 = new uint256[](4);
        tokenIds3[0] = 1000;
        tokenIds3[1] = 1001;
        tokenIds3[2] = nftTypeId;
        tokenIds3[3] = nftTypeId2;

        vm.expectRevert();
        tronicERC1155.mintBatch(testUser, tokenIds3, amounts, "");

        //attempt to mint nfttypes with invalid token type
        uint256[] memory tokenIds4 = new uint256[](4);
        tokenIds4[0] = fungibleTypeId;
        tokenIds4[1] = fungibleTypeId2;
        tokenIds4[2] = 1000;
        tokenIds4[3] = 1001;

        vm.expectRevert();
        tronicERC1155.mintBatch(testUser, tokenIds4, amounts, "");

        //attempt to mint more than maxMintable fungible
        uint256[] memory amounts2 = new uint256[](4);
        amounts2[0] = 1001;
        amounts2[1] = 1001;
        amounts2[2] = 1;
        amounts2[3] = 1;

        vm.expectRevert();
        tronicERC1155.mintBatch(testUser, tokenIds, amounts2, "");

        //attempt to mint more than maxMintable non fungible
        amounts2[0] = 1;
        amounts2[1] = 1;
        amounts2[2] = 1001;
        amounts2[3] = 1001;

        vm.expectRevert();
        tronicERC1155.mintBatch(testUser, tokenIds, amounts2, "");

        vm.stopPrank();

        //attempt to mint from non-admin
        vm.prank(testUser);
        vm.expectRevert();
        tronicERC1155.mintBatch(testUser, tokenIds, amounts, "");

        uint256[] memory _tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        assertEq(_tokenIds.length, 20);

        tokenIds[2] = _tokenIds[15];
        tokenIds[3] = _tokenIds[16];

        amounts[2] = 1;
        amounts[3] = 1;

        //test safeBatchTransferFrom
        vm.prank(testUser);
        tronicERC1155.safeBatchTransferFrom(testUser, user1, tokenIds, amounts, "");

        //verify that testUser no longer owns token
        tokenIds = tronicERC1155.getNftIdsForOwner(testUser);
        assertEq(tokenIds.length, 18);
    }
}
