// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC721CloneableTBA.sol";

contract NewUserEntry is Script {
    // Deployments
    ERC721CloneableTBA public erc721;
    address public erc721Address = vm.envAddress("ERC721_CLONEABLE_ADDRESS");

    address public userAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    // address public userAddress = vm.envAddress("SAMPLE_USER_ADDRESS");

    // increment this for each new token
    uint256 public tokenId = 1;

    // this script mints an erc721 token to the tronic address
    function run() external {
        erc721 = ERC721CloneableTBA(erc721Address);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        //mint erc721 to userAddress
        erc721.mint(userAddress, tokenId);

        vm.stopBroadcast();
    }
}
