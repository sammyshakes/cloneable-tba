// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract DeployMembership is Script {
    // Deployments
    TronicMain public tronicMainContract;

    // max Supply for membership x and y's erc721 tokens
    uint256 public maxSupply = 10_000;
    bool public elastic = false;

    // erc721 token uris
    string public erc721URIX = vm.envString("MEMBERSHIP_X_ERC721_BASE_URI");
    string public erc721URIY = vm.envString("MEMBERSHIP_Y_ERC721_BASE_URI");

    address public tronicMainContractAddress = vm.envAddress("TRONIC_MAIN_CONTRACT_ADDRESS");

    string public membershipXName = "Membership X ERC721";
    string public membershipXSymbol = "MX721";
    string public membershipYName = "Membership Y ERC721";
    string public membershipYSymbol = "MY721";

    // this script deploys membership x and membership y
    // from Tronic Main contract with tronic admin pkey
    function run() external {
        uint256 adminPrivateKey = vm.envUint("TRONIC_ADMIN_PRIVATE_KEY");

        tronicMainContract = TronicMain(tronicMainContractAddress);

        vm.startBroadcast(adminPrivateKey);

        //deploy membership x
        tronicMainContract.deployMembership(
            membershipXName, membershipXSymbol, erc721URIX, maxSupply, elastic
        );

        //deploy membership y
        tronicMainContract.deployMembership(
            membershipYName, membershipYSymbol, erc721URIY, maxSupply, elastic
        );

        vm.stopBroadcast();
    }
}
