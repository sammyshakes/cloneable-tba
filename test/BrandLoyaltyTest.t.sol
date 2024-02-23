// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract BrandLoyaltyTest is TronicTestBase {
    function testMintingBrandLoyalty() public {
        console.log("SETUP - tokenbound account address: ", defaultTBAImplementationAddress);
        console.log(
            "SETUP - Tronic Brand Loyalty address: ", address(tronicBrandLoyaltyImplementation)
        );
        console.log("SETUP - registry address: ", registryAddress);

        // Mint test token
        vm.startPrank(tronicAdmin);
        //attempt to first mint a brand loyalty token from an unregistered brand
        vm.expectRevert();
        tronicMainContract.mintBrandLoyaltyToken(user1, 100);

        (, uint256 brandXTokenId) = tronicMainContract.mintBrandLoyaltyToken(user4, brandIDX);

        vm.stopPrank();

        //  brandIDX, brandLoyaltyAddressX, tokenAddressX
        // check that user4 owns token
        // get brand loyalty contract
        TronicBrandLoyalty tronicBrandLoyalty = TronicBrandLoyalty(brandLoyaltyAddressX);
        assertEq(tronicBrandLoyalty.ownerOf(brandXTokenId), user4);

        // get tba address for token from tronicBrandLoyalty contract
        address tba = tronicBrandLoyalty.getTBAccount(brandXTokenId);
        console.log("brand x tokenbound account created: ", tba);

        //deployed tba
        IERC6551Account tbaAccount = IERC6551Account(payable(address(tba)));

        // user1 should own tokenbound account
        assertEq(tbaAccount.owner(), user4);

        console.log("token owner: ", tronicBrandLoyalty.ownerOf(brandXTokenId));
        console.log("tbaAccount owner: ", tbaAccount.owner());

        //transfer token to another user
        vm.prank(user4);
        tronicBrandLoyalty.transferFrom(user4, user3, brandXTokenId);

        //user1 should own token and therefore control tba
        assertEq(tronicBrandLoyalty.ownerOf(brandXTokenId), user3);
        assertEq(tbaAccount.owner(), user3);
    }

    // test admin functions
    function testAdminBrandLoyalty() public {
        // console brandLoyaltyX owner
        console.log("brandLoyaltyX owner: ", brandLoyaltyX.owner());

        // add admin
        vm.startPrank(tronicAdmin);
        brandLoyaltyX.addAdmin(user1);
        assertEq(brandLoyaltyX.isAdmin(user1), true);

        // remove admin
        brandLoyaltyX.removeAdmin(user1);
        assertEq(brandLoyaltyX.isAdmin(user1), false);

        // transfer ownership
        brandLoyaltyX.transferOwnership(user1);
        assertEq(brandLoyaltyX.owner(), user1);
        vm.stopPrank();

        // transfer ownership back
        vm.prank(user1);
        brandLoyaltyX.transferOwnership(tronicAdmin);
        assertEq(brandLoyaltyX.owner(), tronicAdmin);
    }

    //test getBrandInfo
    function testGetBrandInfo() public {
        TronicMain.BrandInfo memory brandInfo = tronicMainContract.getBrandInfo(brandIDX);

        assertEq(brandInfo.achievementAddress, tokenAddressX);
        assertEq(brandInfo.brandLoyaltyAddress, brandLoyaltyAddressX);
    }

    function testMembershipTiers() public {}

    //teset setBaseURI
    function testSetBaseURI() public {
        //set base uri
        vm.startPrank(tronicAdmin);
        brandLoyaltyX.setBaseURI("https://www.tronic.com/");
        vm.stopPrank();

        //get uri of token id 1
        string memory uri = brandLoyaltyX.tokenURI(1);
        console.log("uri: ", uri);
    }

    //test supports interface
    function testSupportsInterface() public {
        //check that supports interface returns true for erc721
        assertEq(brandLoyaltyX.supportsInterface(type(IERC721).interfaceId), true);
    }

    //test safe transfer brand loyalty token between users
    function testSafeTransferBrandLoyaltyToken() public {
        //check owner of brand loyalty token is user1
        assertEq(brandLoyaltyX.ownerOf(1), user1);

        //transfer token from user1 to user2
        vm.startPrank(user1);
        brandLoyaltyX.safeTransferFrom(user1, user2, 1);
        vm.stopPrank();

        //check owner of brand loyalty token is user2
        assertEq(brandLoyaltyX.ownerOf(1), user2);
    }

    //test safe transfer brand loyalty token from bound account
    function testSafeTransferBrandLoyaltyTokenFromBoundAccount() public {
        //deploy new brand z with bound loyalty token
        vm.startPrank(tronicAdmin);
        //deploy brnda from tronicmain
        (uint256 brandZDX, address brandLoyaltyZAddress,,) =
            tronicMainContract.deployBrand("brandZ", "BRNDZ", "https://www.brandz.com/", true);

        // mint brand loyalty token
        (address brandZTBA, uint256 brandZTokenId) =
            tronicMainContract.mintBrandLoyaltyToken(user4, brandZDX);

        console.log("brandZTBA: ", brandZTBA);

        // get brand loyalty contract
        TronicBrandLoyalty brandLoyaltyZ = TronicBrandLoyalty(brandLoyaltyZAddress);

        // assert that user4 owns token
        assertEq(brandLoyaltyZ.ownerOf(brandZTokenId), user4);

        //attempt to transfer token from user4 to user3
        vm.startPrank(user4);
        vm.expectRevert("Token is bound");
        brandLoyaltyZ.safeTransferFrom(user4, user3, brandZTokenId);

        // call overloaded safeTransferFrom
        vm.startPrank(user4);
        vm.expectRevert("Token is bound");
        brandLoyaltyZ.safeTransferFrom(user4, user3, brandZTokenId, "");

        //also try transferFrom
        vm.expectRevert("Token is bound");
        brandLoyaltyZ.transferFrom(user4, user3, brandZTokenId);
        vm.stopPrank();

        //check that user4 still owns token
        assertEq(brandLoyaltyZ.ownerOf(brandZTokenId), user4);

        //attempt to make the transfer from admin
        //approve admin to transfer token
        vm.startPrank(user4);
        brandLoyaltyZ.approve(tronicAdmin, brandZTokenId);
        vm.stopPrank();

        vm.startPrank(tronicAdmin);
        brandLoyaltyZ.safeTransferFrom(user4, user3, brandZTokenId);
        vm.stopPrank();

        //check that user3 now owns token
        assertEq(brandLoyaltyZ.ownerOf(brandZTokenId), user3);

        //ueser3 can now attempt transfer back to user4
        vm.startPrank(user3);
        vm.expectRevert("Token is bound");
        brandLoyaltyZ.transferFrom(user3, user4, brandZTokenId);
        vm.stopPrank();

        //approve admin to transfer token
        vm.startPrank(user3);
        brandLoyaltyZ.approve(tronicAdmin, brandZTokenId);
        vm.stopPrank();

        //try to transfer back to user4 from admin
        vm.startPrank(tronicAdmin);
        brandLoyaltyZ.transferFrom(user3, user4, brandZTokenId);
        vm.stopPrank();

        //check that user4 now owns token
        assertEq(brandLoyaltyZ.ownerOf(brandZTokenId), user4);
    }

    function testSymbol() public {
        //check that symbol is correct
        assertEq(brandLoyaltyX.symbol(), "XXX");
    }
}
