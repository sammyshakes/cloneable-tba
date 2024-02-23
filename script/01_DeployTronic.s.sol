// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";
import "../src/TronicMembership.sol";
import "../src/TronicToken.sol";
import "../src/TronicBrandLoyalty.sol";
import "../src/TronicRewards.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployTronic is Script {
    // Implementation Deployments
    TronicMembership public tronicMembershipImpl;
    TronicToken public tronicTokenImpl;
    TronicMain public tronicMainImpl;
    TronicBrandLoyalty public tronicBrandLoyaltyImpl;
    TronicRewards public tronicRewardsImpl;

    //Proxy Deployments
    ERC1967Proxy public proxyMain;
    TronicMain public tronicMain;

    uint8 public maxTiersPerMembership = 10;
    uint64 public nftTypeStartId = 100_000;

    address public tronicAdminAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address public tbaAddress = vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS");
    address payable public tbaProxyAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_PROXY_IMPLEMENTATION_ADDRESS"));

    function run() external returns (address, address, address, address, address) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("TRONIC_DEPLOYER_PRIVATE_KEY"));

        //Deploy Tronic Master Contracts
        vm.startBroadcast(deployerPrivateKey);

        tronicBrandLoyaltyImpl = new TronicBrandLoyalty();
        tronicMembershipImpl = new TronicMembership();
        tronicTokenImpl = new TronicToken();
        tronicRewardsImpl = new TronicRewards();

        // deploy new Tronic Main Contract implementation
        tronicMainImpl = new TronicMain();

        // deploy proxy contract
        proxyMain = new ERC1967Proxy(address(tronicMainImpl), "");

        // Wrap proxy in main contract abi
        tronicMain = TronicMain(address(proxyMain));

        // initialize main contract
        tronicMain.initialize(
            tronicAdminAddress,
            address(tronicBrandLoyaltyImpl),
            address(tronicMembershipImpl),
            address(tronicTokenImpl),
            address(tronicRewardsImpl),
            registryAddress,
            tbaAddress,
            tbaProxyAddress,
            maxTiersPerMembership,
            nftTypeStartId, // start id for nft type achievements
            nftTypeStartId // start id for nft type rewards
        );

        vm.stopBroadcast();

        // return the address of the deployed contracts
        return (
            address(tronicMain),
            address(tronicBrandLoyaltyImpl),
            address(tronicMembershipImpl),
            address(tronicTokenImpl),
            address(tronicRewardsImpl)
        );
    }
}
