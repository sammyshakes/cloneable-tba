// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";

contract NewUserEntry is Script {
    // Deployments
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public tronicERC1155;

    address public erc721Address = vm.envAddress("ERC721_CLONEABLE_ADDRESS");
    address public erc1155Address = vm.envAddress("ERC1155_CLONEABLE_ADDRESS");

    address public userAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    // address public userAddress = vm.envAddress("SAMPLE_USER_ADDRESS");

    // increment this for each new token
    uint256 public tokenId = 1;

    // this script mints an erc721 token to the tronic address
    function run() external {
        erc721 = ERC721CloneableTBA(erc721Address);
        tronicERC1155 = ERC1155Cloneable(erc1155Address);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        vm.startBroadcast(deployerPrivateKey);

        //mint erc721 to userAddress
        address tba = erc721.mint(userAddress, tokenId);

        // do we also mint some initial tronic tokens to the new tba?
        tronicERC1155.mintFungible(tba, 1, 1000);

        vm.stopBroadcast();
    }
}
