// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TronicMain.sol";
import "./TronicTestBase.t.sol";

contract TronicGasTest is TronicTestBase {
    uint256 public constant GAS_PRICE_20_GWEI = 20e9;
    uint256 public constant GAS_PRICE_40_GWEI = 40e9;

    function generateAddress(uint256 index) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(index)))));
    }

    function estimateGasCost(uint256 gasUsed) private view {
        uint256 costAt20Gwei = gasUsed * GAS_PRICE_20_GWEI;
        uint256 costAt40Gwei = gasUsed * GAS_PRICE_40_GWEI;

        console.log("Cost in wei at 20 Gwei: ", costAt20Gwei);
        console.log("Cost at wei at 40 Gwei: ", costAt40Gwei);

        console.log("Cost in ETH at 20 Gwei: ", costAt20Gwei / 1e18);
        console.log("Cost at ETH at 40 Gwei: ", costAt40Gwei / 1e18);
    }

    function testSingleMintingGasCost() public {
        // Record the initial gas left before executing the function
        uint256 initialGas = gasleft();

        // mint
        vm.prank(tronicAdmin);
        tronicMainContract.mintMembership(user1, membershipIDX, 0);

        // Record the gas left after executing the function
        uint256 finalGas = gasleft();

        // Calculating the gas used
        uint256 gasUsed = initialGas - finalGas;

        console.log("Gas used for minting membership: ", gasUsed);

        estimateGasCost(gasUsed);
    }

    function testBatchMintingGasCost() public {
        uint256 batchAMount = 50;
        uint256 gasBefore = gasleft();

        vm.startPrank(tronicAdmin);

        console.log("Processing batch minting...");

        // Mint memberships in batch
        for (uint256 i = 0; i < batchAMount; i++) {
            tronicMainContract.mintMembership(generateAddress(i), membershipIDX, 0);
        }

        vm.stopPrank();

        uint256 gasAfter = gasleft();

        uint256 gasUsed = gasBefore - gasAfter;
        console.log("Gas Used for Batch Minting: ", gasUsed);
        console.log("Batch Amount: ", batchAMount);
        console.log("Gas Used per Mint: ", gasUsed / batchAMount);

        estimateGasCost(gasUsed);
    }

    // function testMintingDifferentTiersGasCost() public {
    //     uint256 gasBefore = gasleft();

    //     vm.startPrank(tronicAdmin);

    //     // Mint memberships of different tiers
    //     tronicMainContract.mintMembership(user1, membershipIDX, TronicTier1Index);
    //     tronicMainContract.mintMembership(user2, membershipIDX, TronicTier2Index);

    //     vm.stopPrank();

    //     uint256 gasAfter = gasleft();

    //     uint256 gasUsed = gasBefore - gasAfter;
    //     console.log("Gas Used for Minting Different Tiers: ", gasUsed);
    // }
}
