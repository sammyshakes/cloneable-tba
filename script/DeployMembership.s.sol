// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract DeployMembership is Script {
    // Deployments
    TronicMain public tronicAdminContract;

    // max Supply for membership x and y's erc721 tokens
    uint256 public maxSupply = 10_000;

    string public nameX = "Membership X Clone ERC1155";
    string public symbolX = "PX1155";

    string public nameY = "Membership Y Clone ERC1155";
    string public symbolY = "PY1155";

    // erc721 token uris
    string public erc721URIX = vm.envString("MEMBERSHIP_X_ERC721_BASE_URI");
    string public erc721URIY = vm.envString("MEMBERSHIP_Y_ERC721_BASE_URI");

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public tronicAdminContractAddress = vm.envAddress("TRONIC_MAIN_CONTRACT_ADDRESS");
    address public membershipAdminAddress = vm.envAddress("SAMPLE_USER_ADDRESS");

    string public erc115BaseURIX = vm.envString("MEMBERSHIP_X_ERC1155_BASE_URI");
    string public erc115BaseURIY = vm.envString("MEMBERSHIP_Y_ERC1155_BASE_URI");

    // this script clones an erc1155 token for a membership x and membership y
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        tronicAdminContract = TronicMain(tronicAdminContractAddress);

        vm.startBroadcast(deployerPrivateKey);

        //deploy membership x
        tronicAdminContract.deployMembership("Project X", "PRJX", erc721URIX, maxSupply);

        //deploy membership y
        tronicAdminContract.deployMembership("Project Y", "PRJY", erc721URIY, maxSupply);

        vm.stopBroadcast();
    }
}
