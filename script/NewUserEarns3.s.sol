// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicToken.sol";

contract NewUserEarns3 is Script {
    // Deployments
    TronicToken public tronicERC1155;
    TronicToken public erc1155CloneX;
    TronicToken public erc1155CloneY;

    address payable public tbaAccount = payable(vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountX =
        payable(vm.envAddress("MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountY =
        payable(vm.envAddress("MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public erc1155Address = vm.envAddress("TRONIC_TOKEN_ERC1155_ADDRESS");
    address public clonedERC1155AddressX = vm.envAddress("MEMBERSHIP_X_ERC1155_ADDRESS");
    address public clonedERC1155AddressY = vm.envAddress("MEMBERSHIP_Y_ERC1155_ADDRESS");

    // this script mints 25 premium tokens with id=3 to the tokenbound project x address
    // and 10 premium tronic tokens to the tronic tbaAccount address
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        // get project contracts
        tronicERC1155 = TronicToken(erc1155Address);
        erc1155CloneX = TronicToken(clonedERC1155AddressX);
        erc1155CloneY = TronicToken(clonedERC1155AddressY);

        vm.startBroadcast(deployerPrivateKey);

        //mint 25 level 3 premium tokens from project x to tbaAccountX address
        erc1155CloneX.mintFungible(tbaAccountX, 0, 25);

        //mint 50 premium tronic tokens id: 0 to tronic tbaAccount address
        tronicERC1155.mintFungible(tbaAccount, 0, 50);

        vm.stopBroadcast();
    }
}
