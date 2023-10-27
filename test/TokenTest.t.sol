// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract TokenTest is TronicTestBase {
    //function to test tronicToken nftminting capabilities
    function testCreateNFTType() public {
        // prank as main contract and createNFTType on tronicToken ERC1155
        //test base uri
        string memory baseURI = "https://example.com/token/";
        uint64 maxSupply = 1000;

        vm.startPrank(address(tronicMainContract));
        uint256 typeId = tronicERC1155.createNFTType(baseURI, maxSupply);

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
        assertEq(tronicERC1155.getNFTokenInfo(typeId2).startingTokenId, 100_000 + maxSupply);

        //create another type and verify starting tokenid
        uint256 typeId3 = tronicERC1155.createNFTType(baseURI, 100_000 + 10_000 + maxSupply);
        tronicERC1155.mintNFT(typeId3, user1);

        tokenIds = tronicERC1155.getNftIdsForOwner(user1);

        // TODO: test transferring singles and batches and ensure all owners have correct nfts
    }
}
