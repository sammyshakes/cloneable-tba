// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract DeployBrand is Script {
    // Deployments
    TronicMain public tronicMainContract;

    // max Supply for membership x and y's erc721 tokens
    bool public isBound = false;

    // THESE SHOULD BE THE BRAND LOYALTY CONTRACT URIs
    string public erc721URIX = vm.envString("MEMBERSHIP_X_ERC721_BASE_URI");
    string public erc721URIY = vm.envString("MEMBERSHIP_Y_ERC721_BASE_URI");

    address public tronicMainContractAddress = vm.envAddress("TRONIC_MAIN_PROXY_ADDRESS");

    string public brandXName = "Brand X ERC721";
    string public brandXSymbol = "BX721";
    string public brandYName = "Brand Y ERC721";
    string public brandYSymbol = "BY721";

    // this script deploys membership x and membership y
    // from Tronic Main contract with tronic admin pkey
    function run() external {
        uint256 adminPrivateKey = uint256(vm.envBytes32("TRONIC_ADMIN_PRIVATE_KEY"));

        tronicMainContract = TronicMain(tronicMainContractAddress);

        vm.startBroadcast(adminPrivateKey);

        //deploy brand x
        tronicMainContract.deployBrand(brandXName, brandXSymbol, erc721URIX, isBound);

        //deploy brand y
        tronicMainContract.deployBrand(brandYName, brandYSymbol, erc721URIY, isBound);

        vm.stopBroadcast();
    }
}
