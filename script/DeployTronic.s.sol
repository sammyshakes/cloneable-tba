// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract DeployTronic is Script {
    // Deployments
    TronicMembership public tronicMembership;
    TronicToken public tronicToken;
    TronicMain public tronicMainContract;

    address public tronicAdminAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("TRONIC_DEPLOYER_PRIVATE_KEY"));

        //Deploy Tronic Master Contracts
        vm.startBroadcast(deployerPrivateKey);

        tronicMembership = new TronicMembership();
        tronicToken = new TronicToken();

        // deploy new Tronic Admin Contract
        tronicMainContract = new TronicMain(
            tronicAdminAddress,
            address(tronicMembership),
            address(tronicToken),
            registryAddress,
            tbaAddress
        );

        vm.stopBroadcast();
    }
}
