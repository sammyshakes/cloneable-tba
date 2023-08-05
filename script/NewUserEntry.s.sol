// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";

contract NewUserEntry is Script {
    // Deployments
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public erc1155Clone;

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public erc721Address = vm.envAddress("ERC721_CLONEABLE_ADDRESS");

    // this script mints an erc721 token to the tronic address and mints 100 of each level of premium token to the tronic address
    function run() external {
        erc721 = ERC721CloneableTBA(erc721Address);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        //mint erc721 to tronic address (tronic will also be our first user for demo purposes)
        erc721.mint(tronicAddress, 1);

        vm.stopBroadcast();
    }
}
