// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicToken.sol";

contract NewUserEarns2 is Script {
    // Deployments
    TronicToken public erc1155CloneX;
    TronicToken public erc1155CloneY;

    address payable public tbaAccountX =
        payable(vm.envAddress("MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountY =
        payable(vm.envAddress("MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public clonedERC1155AddressX = vm.envAddress("MEMBERSHIP_X_ERC1155_ADDRESS");
    address public clonedERC1155AddressY = vm.envAddress("MEMBERSHIP_Y_ERC1155_ADDRESS");

    // this script mints 100 of each level of premium token to the tokenbound project addresses
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        // get project contracts
        erc1155CloneX = TronicToken(clonedERC1155AddressX);
        erc1155CloneY = TronicToken(clonedERC1155AddressY);

        vm.startBroadcast(deployerPrivateKey);

        //mint 100 level 1 premium tokens to tbaAccountX address
        TronicToken(erc1155CloneX).mintFungible(tbaAccountX, 1, 100);

        //mint 50 level 2 premium tokens to tronic address
        TronicToken(erc1155CloneX).mintFungible(tbaAccountX, 2, 50);

        //mint 100 level 1 premium tokens to tbaAccountY address
        TronicToken(erc1155CloneY).mintFungible(tbaAccountY, 1, 100);

        //mint 50 level 2 premium tokens to tronic address
        TronicToken(erc1155CloneY).mintFungible(tbaAccountY, 2, 50);

        vm.stopBroadcast();
    }
}
