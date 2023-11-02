// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract GasEstimatesMemberships is Script {
    // Deployments
    TronicMain public tronicMain;

    address public tronicMainContract = vm.envAddress("TRONIC_MAIN_CONTRACT_ADDRESS");

    uint256 public membershipID = 0;
    uint256 public batchAMount = 100;

    function run() external {
        uint256 adminPrivateKey = uint256(vm.envBytes32("TRONIC_ADMIN_PRIVATE_KEY"));

        // get project contracts
        tronicMain = TronicMain(tronicMainContract);

        vm.startBroadcast(adminPrivateKey);

        // Mint memberships in batch
        for (uint256 i = 0; i < batchAMount; i++) {
            tronicMain.mintMembership(generateAddress(i), membershipID, 0);
        }

        vm.stopBroadcast();
    }

    function generateAddress(uint256 index) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(index)))));
    }
}
