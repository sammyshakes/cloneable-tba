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

    //write test function for this function on TronicMain
    //  function transferTokensFromBrandLoyaltyTBA(
    // address _brandLoyaltyTbaAddress,
    //     address _to,
    //     uint256 _transferTokenId,
    //     uint256 _amount
    // ) external
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
        tronicMainContract.mintFungibleToken(brandIDX, brandTBAddress, fungibleTypeIdX1, 100);

        //get the token balance of the token bound account
        uint256 balance = brandXToken.balanceOf(brandTBAddress, fungibleTypeIdX1);

        //check that the balance is correct
        assertEq(balance, 100);

        //set permission for brand loyalty tba to transfer tokens
        bool[] memory approved = new bool[](1);
        approved[0] = true;
        address[] memory approvedAddresses = new address[](1);
        approvedAddresses[0] = address(tronicMainContract);

        vm.prank(user1);
        brandTBA.setPermissions(approvedAddresses, approved);

        //transfer tokens from brand loyalty tba to user1
        vm.startPrank(user1);
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            payable(brandTBAddress), recipient, fungibleTypeIdX1, amount
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
        vm.expectRevert("Token does not exist");
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(brandTBAddress, recipient, 100, amount);

        //attempt to transfer tokens from brand loyalty tba to user1 with invalid amount
        vm.expectRevert("Insufficient balance");
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            brandTBAddress, recipient, brandLoyaltyTokenId, 101
        );

        //attempt to transfer tokens from brand loyalty tba to user1 with invalid brandLoyaltyAddress
        vm.expectRevert("Brand loyalty does not exist");
        tronicMainContract.transferTokensFromBrandLoyaltyTBA(
            address(0xdeadbeef), recipient, brandLoyaltyTokenId, amount
        );
    }
}
