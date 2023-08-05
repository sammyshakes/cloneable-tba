// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/CloneFactory.sol";
import "../src/ERC721CloneableTBA.sol";

//This script deploys the clone factory and initializes the erc721 token
contract DeployCloneFactory is Script, Test {
    // Deployments
    CloneFactory public cloneFactory;
    ERC721CloneableTBA public erc721;

    address public tronicAddress = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public erc721Address = vm.envAddress("ERC721_CLONEABLE_ADDRESS");
    address public erc1155Address = vm.envAddress("ERC1155_CLONEABLE_ADDRESS");
    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    string public baseURI = vm.envString("ERC721_BASE_URI");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        erc721 = ERC721CloneableTBA(erc721Address);

        vm.startBroadcast(deployerPrivateKey);

        //initialize erc721
        erc721.initialize(tbaAddress, registryAddress, "TrcClub", "TRC", baseURI, tronicAddress);

        // deploy new clone factory with environment variables
        cloneFactory = new CloneFactory(
            tronicAddress,
            erc721Address,
            erc1155Address,
            registryAddress,
            tbaAddress
        );

        vm.stopBroadcast();
    }
}
