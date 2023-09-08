// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMembership.sol";
import "../src/TronicToken.sol";

contract NewUserEntry is Script {
    // Deployments
    TronicMembership public erc721;
    TronicToken public tronicERC1155;

    address public erc721Address = vm.envAddress("TRONIC_MEMBERSHIP_ERC721_ADDRESS");
    address public erc1155Address = vm.envAddress("TRONIC_TOKEN_ERC1155_ADDRESS");

    address public userAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    // address public userAddress = vm.envAddress("SAMPLE_USER_ADDRESS");

    // increment this for each new token
    uint256 public tokenId = 1;

    // this script mints an erc721 token to the user address
    function run() external {
        erc721 = TronicMembership(erc721Address);
        tronicERC1155 = TronicToken(erc1155Address);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        //mint erc721 to userAddress
        address tba = erc721.mint(userAddress);

        // do we also mint some initial tronic tokens to the new tba?
        tronicERC1155.mintFungible(tba, 1, 1000);

        vm.stopBroadcast();
    }
}
