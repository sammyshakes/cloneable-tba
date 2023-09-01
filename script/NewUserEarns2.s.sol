// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC1155Cloneable.sol";

contract NewUserEarns2 is Script {
    // Deployments
    ERC1155Cloneable public erc1155CloneX;
    ERC1155Cloneable public erc1155CloneY;

    address payable public tbaAccountX =
        payable(vm.envAddress("PARTNER_X_TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountY =
        payable(vm.envAddress("PARTNER_Y_TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public clonedERC1155AddressX = vm.envAddress("PARTNER_X_CLONED_ERC1155_ADDRESS");
    address public clonedERC1155AddressY = vm.envAddress("PARTNER_Y_CLONED_ERC1155_ADDRESS");

    // this script mints 100 of each level of premium token to the tokenbound project addresses
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        // get project contracts
        erc1155CloneX = ERC1155Cloneable(clonedERC1155AddressX);
        erc1155CloneY = ERC1155Cloneable(clonedERC1155AddressY);

        vm.startBroadcast(deployerPrivateKey);

        //mint 100 level 1 premium tokens to tbaAccountX address
        ERC1155Cloneable(erc1155CloneX).mintFungible(tbaAccountX, 1, 100);

        //mint 50 level 2 premium tokens to tronic address
        ERC1155Cloneable(erc1155CloneX).mintFungible(tbaAccountX, 2, 50);

        //mint 100 level 1 premium tokens to tbaAccountY address
        ERC1155Cloneable(erc1155CloneY).mintFungible(tbaAccountY, 1, 100);

        //mint 50 level 2 premium tokens to tronic address
        ERC1155Cloneable(erc1155CloneY).mintFungible(tbaAccountY, 2, 50);

        vm.stopBroadcast();
    }
}
