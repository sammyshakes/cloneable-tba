// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract DeployTronic is Script {
    // Deployments
    TronicMembership public erc721;
    TronicLoyalty public erc1155;
    TronicMain public tronicAdminContract;

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        //Deploy Tronic Master Contracts
        vm.startBroadcast(deployerPrivateKey);

        erc721 = new TronicMembership();
        erc1155 = new TronicLoyalty();

        // deploy new Tronic Admin Contract
        tronicAdminContract = new TronicMain(
            tronicAddress,
            address(erc721),
            address(erc1155),
            registryAddress,
            tbaAddress
        );

        vm.stopBroadcast();
    }
}
