// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicAdmin.sol";

contract NewProjectEntry is Script {
    // Deployments
    TronicAdmin public tronicAdminContract;

    // max Supply for channel x and y's erc721 tokens
    uint256 public maxSupply = 10_000;

    string public nameX = "Channel X Clone ERC1155";
    string public symbolX = "PX1155";

    string public nameY = "Channel Y Clone ERC1155";
    string public symbolY = "PY1155";

    // erc721 token uris
    string public erc721URIX = vm.envString("CHANNEL_X_ERC721_BASE_URI");
    string public erc721URIY = vm.envString("CHANNEL_Y_ERC721_BASE_URI");

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public tronicAdminContractAddress = vm.envAddress("TRONIC_ADMIN_CONTRACT_ADDRESS");
    address public channelAdminAddress = vm.envAddress("SAMPLE_USER_ADDRESS");

    string public erc115BaseURIX = vm.envString("CHANNEL_X_ERC1155_BASE_URI");
    string public erc115BaseURIY = vm.envString("CHANNEL_Y_ERC1155_BASE_URI");

    // this script clones an erc1155 token for a channel x and channel y
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        tronicAdminContract = TronicAdmin(tronicAdminContractAddress);

        vm.startBroadcast(deployerPrivateKey);

        //deploy channel x
        tronicAdminContract.deployChannel(
            "Project X", "PRJX", erc721URIX, maxSupply, nameX, symbolX, erc115BaseURIX, "ChannelX"
        );

        //deploy channel y
        tronicAdminContract.deployChannel(
            "Project Y", "PRJY", erc721URIY, maxSupply, nameY, symbolY, erc115BaseURIY, "ChannelY"
        );

        vm.stopBroadcast();
    }
}
