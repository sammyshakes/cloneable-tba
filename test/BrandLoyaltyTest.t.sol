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
        vm.prank(tronicAdmin);

        (address brandXTBA, uint256 brandXTokenId) =
            tronicMainContract.mintBrandLoyaltyToken(user4, brandIDX);

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
        // console tronicBrandLoyaltyImplementation owner
        console.log(
            "tronicBrandLoyaltyImplementation owner: ", tronicBrandLoyaltyImplementation.owner()
        );

        // add admin
        vm.prank(tronicAdmin);
        tronicBrandLoyaltyImplementation.addAdmin(user1);
        assertEq(tronicBrandLoyaltyImplementation.isAdmin(user1), true);

        // remove admin
        vm.prank(tronicAdmin);
        tronicBrandLoyaltyImplementation.removeAdmin(user1);
        assertEq(tronicBrandLoyaltyImplementation.isAdmin(user1), false);

        // transfer ownership
        vm.prank(tronicAdmin);
        tronicBrandLoyaltyImplementation.transferOwnership(user1);
        assertEq(tronicBrandLoyaltyImplementation.owner(), user1);

        // transfer ownership back
        vm.prank(user1);
        tronicBrandLoyaltyImplementation.transferOwnership(tronicAdmin);
        assertEq(tronicBrandLoyaltyImplementation.owner(), tronicAdmin);
    }

    //test getBrandInfo
    function testGetBrandInfo() public {
        TronicMain.BrandInfo memory brandInfo = tronicMainContract.getBrandInfo(brandIDX);

        assertEq(brandInfo.tokenAddress, tokenAddressX);
        assertEq(brandInfo.brandLoyaltyAddress, brandLoyaltyAddressX);

        //get membership ids for this brand
        uint256[] memory membershipIds = brandInfo.membershipIds;
    }

    function testMembershipTiers() public {}
}
