// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicToken.sol";

contract NewUserEarns3 is Script {
    // Deployments
    TronicToken public tronicToken;
    TronicToken public tokenX;
    TronicToken public tokenY;

    address payable public tbaAccount = payable(vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountX =
        payable(vm.envAddress("MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountY =
        payable(vm.envAddress("MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public tronicTokenAddress = vm.envAddress("TRONIC_TOKEN_ERC1155_ADDRESS");
    address public tokenXAddress = vm.envAddress("MEMBERSHIP_X_ERC1155_ADDRESS");
    address public tokenYAddress = vm.envAddress("MEMBERSHIP_Y_ERC1155_ADDRESS");

    // this script mints 25 premium tokens with id=3 to the tokenbound project x address
    // and 10 premium tronic tokens to the tronic tbaAccount address
    function run() external {
        uint256 adminPrivateKey = vm.envUint("TRONIC_ADMIN_PRIVATE_KEY");

        // get project contracts
        tronicToken = TronicToken(tronicTokenAddress);
        tokenX = TronicToken(tokenXAddress);
        tokenY = TronicToken(tokenYAddress);

        vm.startBroadcast(adminPrivateKey);

        //mint 25 level 3 premium tokens from project x to tbaAccountX address
        tokenX.mintFungible(tbaAccountX, 0, 25);

        //mint 50 premium tronic tokens id: 0 to tronic tbaAccount address
        tronicToken.mintFungible(tbaAccount, 0, 50);

        vm.stopBroadcast();
    }
}
