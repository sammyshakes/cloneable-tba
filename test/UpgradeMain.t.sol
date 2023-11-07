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
        TronicMainV2 tronicV2 = TronicMainV2(payable(address(proxy)));

        // check contract storage is same as v1
        assertEq(tronicV2.tronicAdmin(), tronicAdmin);
        assertEq(address(tronicV2.registry()), registryAddress);

        //call new string version
        assertEq(tronicV2.VERSION(), "v0.2.0");
    }
}
