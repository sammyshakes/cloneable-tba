// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicAdmin.sol";

contract NewProjectEntry is Script {
    // Deployments
    TronicAdmin public tronicAdminContract;

    // max Supply for partner x and y's erc721 tokens
    uint256 public maxSupply = 10_000;

    string public nameX = "Partner X Clone ERC1155";
    string public symbolX = "PX1155";

    string public nameY = "Partner Y Clone ERC1155";
    string public symbolY = "PY1155";

    // erc721 token uris
    string public erc721URIX = vm.envString("PARTNER_X_ERC721_BASE_URI");
    string public erc721URIY = vm.envString("PARTNER_Y_ERC721_BASE_URI");

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public tronicAdminContractAddress = vm.envAddress("TRONIC_ADMIN_CONTRACT_ADDRESS");
    address public partnerAdminAddress = vm.envAddress("SAMPLE_USER_ADDRESS");

    string public erc115BaseURIX = vm.envString("PARTNER_X_ERC1155_BASE_URI");
    string public erc115BaseURIY = vm.envString("PARTNER_Y_ERC1155_BASE_URI");

    // this script clones an erc1155 token for a partner x and partner y
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        tronicAdminContract = TronicAdmin(tronicAdminContractAddress);

        vm.startBroadcast(deployerPrivateKey);

        //deploy partner x
        tronicAdminContract.deployPartner(
            "Project X", "PRJX", erc721URIX, maxSupply, nameX, symbolX, erc115BaseURIX, "PartnerX"
        );

        //deploy partner y
        tronicAdminContract.deployPartner(
            "Project Y", "PRJY", erc721URIY, maxSupply, nameY, symbolY, erc115BaseURIY, "PartnerY"
        );

        vm.stopBroadcast();
    }
}
