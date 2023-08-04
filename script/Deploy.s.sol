// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Imports
import "forge-std/Script.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";
import "../src/interfaces/IERC6551Registry.sol";
import "../src/interfaces/IERC6551Account.sol";

contract Deploy is Script {
    // Deployments
    IERC6551Account public tba;
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public erc1155;
    IERC6551Registry public registry;

    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address payable public tbaAddress = payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TRONIC_ADMIN");

        //Deploy Tronic Master Contracts
        vm.startBroadcast(deployerPrivateKey);

        tba = IERC6551Account(tbaAddress);
        erc721 = new ERC721CloneableTBA();
        erc1155 = new ERC1155Cloneable();
        registry = IERC6551Registry(registryAddress);

        vm.stopBroadcast();
    }
}
