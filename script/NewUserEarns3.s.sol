// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC1155Cloneable.sol";

contract NewUserEarns3 is Script {
    // Deployments
    ERC1155Cloneable public tronicERC1155;
    ERC1155Cloneable public erc1155CloneX;
    ERC1155Cloneable public erc1155CloneY;

    address payable public tbaAccount = payable(vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountX =
        payable(vm.envAddress("PROJECT_X_TOKENBOUND_ACCOUNT_TOKENID_1"));
    address payable public tbaAccountY =
        payable(vm.envAddress("PROJECT_Y_TOKENBOUND_ACCOUNT_TOKENID_1"));

    address public erc1155Address = vm.envAddress("ERC1155_CLONEABLE_ADDRESS");
    address public clonedERC1155AddressX = vm.envAddress("PROJECT_X_CLONED_ERC1155_ADDRESS");
    address public clonedERC1155AddressY = vm.envAddress("PROJECT_Y_CLONED_ERC1155_ADDRESS");

    // this script mints 25 premium tokens with id=3 to the tokenbound project x address
    // and 10 premium tronic tokens to the tronic tbaAccount address
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        // get project contracts
        tronicERC1155 = ERC1155Cloneable(erc1155Address);
        erc1155CloneX = ERC1155Cloneable(clonedERC1155AddressX);
        erc1155CloneY = ERC1155Cloneable(clonedERC1155AddressY);

        vm.startBroadcast(deployerPrivateKey);

        //mint 25 level 3 premium tokens from project x to tbaAccountX address
        erc1155CloneX.mintFungible(tbaAccountX, 3, 25);

        //mint 10 premium tronic tokens to tronic tbaAccount address
        tronicERC1155.mintFungible(tbaAccount, 1, 10);

        vm.stopBroadcast();
    }
}
