// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicLoyalty.sol";

contract NewUserEarns2 is Script {
    // Deployments
    TronicLoyalty public erc1155CloneX;
    TronicLoyalty public erc1155CloneY;

    address payable public tbaAccountX =
        payable(vm.envAddress("MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountY =
        payable(vm.envAddress("MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public clonedERC1155AddressX = vm.envAddress("MEMBERSHIP_X_CLONED_ERC1155_ADDRESS");
    address public clonedERC1155AddressY = vm.envAddress("MEMBERSHIP_Y_CLONED_ERC1155_ADDRESS");

    // this script mints 100 of each level of premium token to the tokenbound project addresses
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        // get project contracts
        erc1155CloneX = TronicLoyalty(clonedERC1155AddressX);
        erc1155CloneY = TronicLoyalty(clonedERC1155AddressY);

        vm.startBroadcast(deployerPrivateKey);

        //mint 100 level 1 premium tokens to tbaAccountX address
        TronicLoyalty(erc1155CloneX).mintFungible(tbaAccountX, 1, 100);

        //mint 50 level 2 premium tokens to tronic address
        TronicLoyalty(erc1155CloneX).mintFungible(tbaAccountX, 2, 50);

        //mint 100 level 1 premium tokens to tbaAccountY address
        TronicLoyalty(erc1155CloneY).mintFungible(tbaAccountY, 1, 100);

        //mint 50 level 2 premium tokens to tronic address
        TronicLoyalty(erc1155CloneY).mintFungible(tbaAccountY, 2, 50);

        vm.stopBroadcast();
    }
}
