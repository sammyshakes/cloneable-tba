// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicToken.sol";

contract NewUserEarns2 is Script {
    // Deployments
    TronicToken public tokenX;
    TronicToken public tokenY;

    address payable public tbaAccountX =
        payable(vm.envAddress("MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountY =
        payable(vm.envAddress("MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public tokenAddressX = vm.envAddress("MEMBERSHIP_X_ERC1155_ADDRESS");
    address public tokenAddressY = vm.envAddress("MEMBERSHIP_Y_ERC1155_ADDRESS");

    // this script mints 100 of each level of premium token to the tokenbound project addresses
    function run() external {
        uint256 adminPrivateKey = vm.envUint("TRONIC_ADMIN_PRIVATE_KEY");

        // get project contracts
        tokenX = TronicToken(tokenAddressX);
        tokenY = TronicToken(tokenAddressY);

        vm.startBroadcast(adminPrivateKey);

        //mint 100 typeId 1 premium tokens to tbaAccountX address
        tokenX.mintFungible(tbaAccountX, 1, 100);

        //mint 50 typeId 2 premium tokens to tbaAccountX address
        tokenX.mintFungible(tbaAccountX, 2, 50);

        //mint 100 typeId 1 premium tokens to tbaAccountY address
        tokenY.mintFungible(tbaAccountY, 1, 100);

        //mint 50 typeId 2 premium tokens to tbaAccountY address
        tokenY.mintFungible(tbaAccountY, 2, 50);

        vm.stopBroadcast();
    }
}
