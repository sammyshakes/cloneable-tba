// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";

contract TransferTokensMainTest is TronicTestBase {
    function testInitialSetup() public {
        assertEq(tronicMainContract.owner(), tronicOwner);
        assertEq(tronicMainContract.membershipCounter(), 2);
        console.log("tronicMainContract address: ", address(tronicMainContract));
        console.log("tronicMembership address: ", address(tronicMembership));
        console.log("tronicBrandLoyalty address: ", address(tronicBrandLoyaltyImplementation));
        console.log("defaultTBAImplementationAddress: ", defaultTBAImplementationAddress);
        console.log("registryAddress: ", registryAddress);
        console.log("brandLoyaltyAddressX: ", brandLoyaltyAddressX);
        console.log("brandXMembershipAddress: ", address(brandXMembership));
        console.log("brandXTokenAddress: ", address(brandXToken));
        console.log("brandLoyaltyAddressY: ", brandLoyaltyAddressY);
        console.log("brandYMembershipAddress: ", address(brandYMembership));
        console.log("brandYTokenAddress: ", address(brandYToken));

        // check that the membership details are correctly set
        assertEq(membershipX.membershipAddress, address(brandXMembership));
        assertEq(membershipY.membershipAddress, address(brandYMembership));

        //assert that TronicAdmin Contract is the owner of membership erc721 and erc1155 token contracts
        assertEq(tronicAdmin, brandLoyaltyX.owner());
        assertEq(tronicAdmin, brandXToken.owner());
        assertEq(tronicAdmin, brandLoyaltyY.owner());
        assertEq(tronicAdmin, brandYToken.owner());

        // get owner of tokenid 1
        address owner = brandLoyaltyX.ownerOf(1);
        console.log("owner of tokenid 1: ", owner);
    }

    function testTransferTokensFromBrandLoyaltyTBA() public {
        //set up recipient, transferTokenId, and amount
        address recipient = user2;
        uint256 brandLoyaltyTokenId = 1;
        uint256 amount = 1;

        //check owner of brand loyalty token is user1
        assertEq(brandLoyaltyX.ownerOf(brandLoyaltyTokenId), user1);

        //get the token bound account address (from tokenId) and verify that it is correct
        address brandTBAddress = brandLoyaltyX.getTBAccount(brandLoyaltyTokenId);
        assertEq(brandTBAddress, brandLoyaltyXTokenId1TBA);

        //get the token bound account (from address) and verify that owner is the owner of the loyalty token (user1)
        IERC6551Account brandTBA = IERC6551Account(payable(address(brandTBAddress)));
        assertEq(brandTBA.owner(), user1);

        //mint tokens to brand loyalty tba from tronicMainContract
        vm.prank(tronicAdmin);
        bool isReward = false;
        tronicMainContract.mintFungibleToken(
            brandIDX, brandTBAddress, fungibleTypeIdX1, 100, isReward
        );

        //get the token balance of the token bound account
        uint256 balance = brandXToken.balanceOf(brandTBAddress, fungibleTypeIdX1);

        //check that the balance is correct
        assertEq(balance, 100);

        //set permission for brand loyalty tba to transfer tokens
        bool[] memory approved = new bool[](1);
        approved[0] = true;
        address[] memory approvedAddresses = new address[](1);
        approvedAddresses[0] = address(tronicMainContract);

        //attempt to transfer using unauthorized address
        vm.expectRevert();
        vm.prank(address(0x666));
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandIDX, brandTBAddress, fungibleTypeIdX1, recipient, amount, isReward
        );

        vm.startPrank(user1);
        brandTBA.setPermissions(approvedAddresses, approved);

        //attempt to transfer using invalid brand id
        vm.expectRevert();
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            100, brandTBAddress, fungibleTypeIdX1, recipient, amount, isReward
        );

        //transfer tokens from brand loyalty tba to user1
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandIDX, brandTBAddress, fungibleTypeIdX1, recipient, amount, isReward
        );

        //get the token balance of the token bound account
        balance = brandXToken.balanceOf(brandLoyaltyXTokenId1TBA, fungibleTypeIdX1);

        //check that the balance is correct
        assertEq(balance, 99);

        //get the token balance of user1
        balance = brandXToken.balanceOf(recipient, fungibleTypeIdX1);

        //check that the balance is correct
        assertEq(balance, 1);

        //attempt to transfer tokens from brand loyalty tba to user1 with invalid brandLoyaltyTokenId
        vm.expectRevert();
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandIDX, brandTBAddress, 100, recipient, amount, isReward
        );

        //attempt to transfer tokens from brand loyalty tba to user1 with invalid amount
        vm.expectRevert();
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandIDX, brandTBAddress, fungibleTypeIdX1, recipient, 101, isReward
        );

        //attempt to transfer tokens from brand loyalty tba to user1 with invalid brandLoyaltyAddress
        vm.expectRevert();
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandIDX, address(0xdeadbeef), fungibleTypeIdX1, recipient, amount, isReward
        );

        vm.stopPrank();
    }

    function testTransferMembershipFromBrandLoyaltyTBA() public {
        //set up recipient, transferTokenId, and amount
        address recipient = address(0x555);
        uint256 brandLoyaltyTokenId = 1;
        uint256 membershipId = 1;

        //check owner of brand loyalty token is user1
        assertEq(brandLoyaltyX.ownerOf(brandLoyaltyTokenId), user1);

        //get the token bound account address (from tokenId) and verify that it is correct
        address brandTBAddress = brandLoyaltyX.getTBAccount(brandLoyaltyTokenId);
        assertEq(brandTBAddress, brandLoyaltyXTokenId1TBA);

        //get the token bound account (from address) and verify that owner is the owner of the loyalty token (user1)
        IERC6551Account brandTBA = IERC6551Account(payable(brandTBAddress));
        assertEq(brandTBA.owner(), user1);

        //mint a membership token to brand loyalty tba from tronicMainContract
        vm.prank(tronicAdmin);
        uint256 membershipTokenId =
            tronicMainContract.mintMembership(brandTBAddress, membershipId, 1);

        //ensure brandTBAddress owns the membership token
        assertEq(brandXMembership.ownerOf(membershipTokenId), brandTBAddress);

        //set permission for brand loyalty tba to transfer membership
        bool[] memory approved = new bool[](1);
        approved[0] = true;
        address[] memory approvedAddresses = new address[](1);
        approvedAddresses[0] = address(tronicMainContract);

        vm.prank(user1);
        brandTBA.setPermissions(approvedAddresses, approved);

        //transfer tokens from brand loyalty tba to user1
        vm.startPrank(user1);
        tronicMainContract.transferMembershipFromBrandLoyaltyTBA(
            brandTBAddress, membershipId, membershipTokenId, recipient
        );
        vm.stopPrank();

        //ensure recipient owns the membership token
        assertEq(brandXMembership.ownerOf(membershipTokenId), recipient);

        //attempt to transfer membership from brand loyalty tba to user1 with invalid membershipId
        vm.expectRevert();
        tronicMainContract.transferMembershipFromBrandLoyaltyTBA(
            brandTBAddress, 100, membershipTokenId, recipient
        );

        //attempt to transfer membership from brand loyalty tba from unauthorized address
        vm.expectRevert();
        // vm.prank(address(0x666));
        tronicMainContract.transferMembershipFromBrandLoyaltyTBA(
            brandTBAddress, membershipId, membershipTokenId, recipient
        );
    }
}
