// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";
import "../src/TronicMembership.sol";
import "../src/TronicToken.sol";
import "../src/TronicBrandLoyalty.sol";
import "../src/TronicBeacon.sol";
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

        // Deploy separate beacons for each contract type
        TronicBeacon brandLoyaltyBeacon = new TronicBeacon(address(tronicBrandLoyaltyImpl));
        TronicBeacon membershipBeacon = new TronicBeacon(address(tronicMembershipImpl));
        TronicBeacon achievementBeacon = new TronicBeacon(address(tronicTokenImpl));
        TronicBeacon rewardsBeacon = new TronicBeacon(address(tronicRewardsImpl));

        // deploy proxy contract
        // proxyMain = new ERC1967Proxy(address(tronicMainImpl), "");

        //deploy tronicMainContract via proxy
        proxyMain = new ERC1967Proxy(
            address(tronicMainImpl),
            abi.encodeWithSignature(
                "initialize(address,address,address,address,address,address,address,address)",
                tronicAdminAddress,
                address(brandLoyaltyBeacon),
                address(membershipBeacon),
                address(achievementBeacon),
                address(rewardsBeacon),
                registryAddress,
                tbaAddress,
                tbaProxyAddress
            )
        );

        // Wrap proxy in main contract abi
        tronicMain = TronicMain(address(proxyMain));

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
