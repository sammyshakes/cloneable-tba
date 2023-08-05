// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";

contract Deploy is Script {
    // Deployments
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public erc1155;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        //Deploy Tronic Master Contracts
        vm.startBroadcast(deployerPrivateKey);

        erc721 = new ERC721CloneableTBA();
        erc1155 = new ERC1155Cloneable();

        vm.stopBroadcast();
    }
}
