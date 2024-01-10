// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/TronicMain.sol";

contract DeployMembership is Script {
    // Deployments
    TronicMain public tronicMainContract;

    // max Supply for membership x and y's erc721 tokens
    uint256 public maxMintable = 10_000;
    bool public isElastic = false;

    // erc721 token uris
    string public membershipXBaseURI = vm.envString("MEMBERSHIP_X_ERC721_BASE_URI");
    string public membershipYBaseURI = vm.envString("MEMBERSHIP_Y_ERC721_BASE_URI");

    //brand ids
    uint256 public brandIdX = vm.envUint("BRAND_X_ID");
    uint256 public brandIdY = vm.envUint("BRAND_Y_ID");

    address public tronicMainContractAddress = vm.envAddress("TRONIC_MAIN_PROXY_ADDRESS");

    string public membershipXName = "Membership X ERC721";
    string public membershipXSymbol = "MX721";
    string public membershipYName = "Membership Y ERC721";
    string public membershipYSymbol = "MY721";

    // this script deploys membership x and membership y
    // from Tronic Main contract with tronic admin pkey
    function run() external returns (uint256, address, uint256, address) {
        //tiers
        ITronicMembership.MembershipTier[] memory tiersArray =
            new ITronicMembership.MembershipTier[](2);

        //create tiers
        ITronicMembership.MembershipTier memory tier1 =
            ITronicMembership.MembershipTier("tier1", 1 days, true, "tier1URI");

        ITronicMembership.MembershipTier memory tier2 =
            ITronicMembership.MembershipTier("tier2", 2 days, true, "tier2URI");

        tiersArray[0] = tier1;
        tiersArray[1] = tier2;

        uint256 adminPrivateKey = uint256(vm.envBytes32("TRONIC_ADMIN_PRIVATE_KEY"));

        tronicMainContract = TronicMain(tronicMainContractAddress);

        vm.startBroadcast(adminPrivateKey);

        //deploy membership x
        (uint256 membershipXId, address membershipXAddress) = tronicMainContract.deployMembership(
            brandIdX,
            membershipXName,
            membershipXSymbol,
            membershipXBaseURI,
            maxMintable,
            isElastic,
            tiersArray
        );

        //deploy membership y
        (uint256 membershipYId, address membershipYAddress) = tronicMainContract.deployMembership(
            brandIdY,
            membershipYName,
            membershipYSymbol,
            membershipYBaseURI,
            maxMintable,
            isElastic,
            tiersArray
        );

        vm.stopBroadcast();

        return (membershipXId, membershipXAddress, membershipYId, membershipYAddress);
    }
}
