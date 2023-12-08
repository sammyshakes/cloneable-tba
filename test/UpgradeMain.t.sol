// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "./TronicTestBase.t.sol";
import "../src/TronicMainV2.sol";

contract UpgradeMainTest is TronicTestBase {
    // test upgrade main contract
    function testUpgradeMain() public {
        address currentMainContractAddress = address(tronicMainContract);
        console.log("current main contract address: ", currentMainContractAddress);
        // deploy new main contract
        vm.startPrank(tronicOwner);
        TronicMainV2 tronicV2Implementation = new TronicMainV2();
        // upgrade main contract
        tronicMainContract.upgradeToAndCall(address(tronicV2Implementation), "");

        vm.stopPrank();

        // assign new main contract abi to proxy address
        TronicMainV2 tronicV2 = TronicMainV2(payable(address(tronicMainProxy)));

        // check contract storage is same as v1
        assertEq(tronicV2.tronicAdmin(), tronicAdmin);
        assertEq(address(tronicV2.registry()), registryAddress);

        //call new string version
        assertEq(tronicV2.VERSION(), "v0.2.0");

        // check to make sure old membership X is still there
        TronicMainV2.MembershipInfo memory memberInfo = tronicV2.getMembershipInfo(membershipIDX);

        console.log("membership name: ", memberInfo.membershipName);
        // assert clone721AddressX, clone1155AddressX are still there
        assertEq(memberInfo.membershipName, "Membership_X1");
        assertEq(memberInfo.membershipAddress, membershipAddressX);

        //get brand loyalty info
        TronicMainV2.BrandInfo memory brandLoyaltyInfo = tronicV2.getBrandInfo(brandIDX);

        assertEq(brandLoyaltyInfo.tokenAddress, tokenAddressX);
    }
}
