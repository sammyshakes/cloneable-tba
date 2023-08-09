// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Imports
import "forge-std/Test.sol";
import "../src/CloneFactory.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";
import "../src/interfaces/IERC6551Registry.sol";
import "../src/interfaces/IERC6551Account.sol";

contract TestnetTests is Test {
    CloneFactory public factory;
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public erc1155;
    IERC6551Account public account;
    IERC6551Registry public registry;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    // new address for an unauthorized user
    address public unauthorizedUser = address(0x4);

    // address public tronicOwner = address(0x5);
    address public tronicOwner = vm.envAddress("TRONIC_ADMIN_ADDRESS");

    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");
    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    address public cloneFactoryAddress = vm.envAddress("CLONE_FACTORY_ADDRESS");
    address public tbaAddressTokenID1 = vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1");
    address public erc721Address = vm.envAddress("ERC721_CLONEABLE_ADDRESS");
    address public erc1155Address = vm.envAddress("ERC1155_CLONEABLE_ADDRESS");

    address public cloned1155AddressX = vm.envAddress("PROJECT_X_CLONED_ERC1155_ADDRESS");

    function setUp() public {
        vm.startPrank(tronicOwner);
        erc721 = ERC721CloneableTBA(erc721Address);
        erc1155 = ERC1155Cloneable(erc1155Address);
        account = IERC6551Account(payable(tbaAddress));
        registry = IERC6551Registry(registryAddress);

        tbaAddress = payable(address(account));

        factory = CloneFactory(cloneFactoryAddress);
        vm.stopPrank();
    }

    function testTransferERC1155PostDeploy() public {
        uint256 tokenId = 1;

        address accountCheck = registry.account(tbaAddress, 11_155_111, erc721Address, 1, 0);
        console.log("accountCheck: ", accountCheck);

        account = IERC6551Account(payable(tbaAddressTokenID1));

        (uint256 chainId, address tokenContract, uint256 _tokenId) = account.token();
        console.log("chainId: ", chainId);
        console.log("tokenContract: ", tokenContract);
        console.log("tokenId: ", _tokenId);

        // Check the clone has correct uri and admin
        ERC1155Cloneable clonedERC1155X = ERC1155Cloneable(cloned1155AddressX);

        assertEq(erc721.ownerOf(tokenId), tronicOwner);

        //retrieve and print out the erc1155 owner, name and symbol
        console.log("clonedERC1155X owner: ", clonedERC1155X.owner());
        console.log("clonedERC1155X name: ", clonedERC1155X.name());
        console.log("clonedERC1155X symbol: ", clonedERC1155X.symbol());

        // mint token to user1
        vm.prank(tronicOwner);
        clonedERC1155X.mintFungible(user1, tokenId, 100);

        assertEq(clonedERC1155X.balanceOf(user1, 1), 100);

        // transfer token to user2
        vm.prank(user1);
        clonedERC1155X.safeTransferFrom(user1, user2, 1, 1, "");

        assertEq(clonedERC1155X.balanceOf(user2, 1), 1);

        // transfer token back to user1
        vm.prank(user2);
        clonedERC1155X.safeTransferFrom(user2, user1, 1, 1, "");

        //transfer token to tbaAddressTokenID1
        vm.prank(user1);
        clonedERC1155X.safeTransferFrom(user1, tbaAddressTokenID1, 1, 1, "");

        // bytes memory erc1155TransferCall = abi.encodeWithSignature(
        //     "safeTransferFrom(address,address,uint256,uint256,bytes)", user1, user2, 1, 10, ""
        // );
        // vm.prank(user1);
        // account.execute(payable(cloned1155AddressX), 0, erc1155TransferCall, 0);

        // // mint token to tbaAddressTokenID1
        // vm.prank(tronicOwner);
        // clonedERC1155.mintFungible(tbaAddressTokenID1, tokenId, 10);

        // assertEq(clonedERC1155.balanceOf(tbaAddressTokenID1, 1), 10);

        // IERC6551Account account = IERC6551Account(payable(tbaAddressTokenID1));
        // bytes memory erc1155TransferCall =
        //     abi.encodeWithSignature("mintFungible(address,uint256,uint256)", user1, 1, 10);
        // vm.prank(tronicOwner);
        // account.execute(cloned1155Address, 0, erc1155TransferCall, 0);
    }

    function testFactoryOwnership() public {
        assertEq(factory.tronicAdmin(), tronicOwner);
    }

    function testChangeFactoryOwnership() public {
        vm.prank(tronicOwner);
        // Change tronicAdmin to user1
        factory.setTronicAdmin(user1);
        assertEq(factory.tronicAdmin(), user1);

        // Try to change tronicAdmin from a non-admin address should fail
        vm.expectRevert();
        vm.prank(user2);
        factory.setTronicAdmin(user2);
    }

    function testCloneERC1155() public {
        vm.prank(tronicOwner);
        address clone1155Address =
            factory.cloneERC1155("http://clone1155.com/", user1, "Clone1155", "CL1155");

        // clone should exist
        assertNotEq(clone1155Address, address(0));

        // Check the clone has correct uri and admin
        ERC1155Cloneable clone1155 = ERC1155Cloneable(clone1155Address);
        assertEq(clone1155.uri(1), "http://clone1155.com/");
        assertEq(clone1155.isAdmin(user1), true);

        // Check the clone can be retrieved using getERC1155Clone function
        assertEq(factory.getERC1155Clone(0), clone1155Address);

        //create token types
        vm.startPrank(user1);
        clone1155.createFungibleType(1, "http://clone1155.com/");

        // mint token to user1
        clone1155.mintFungible(user1, 1, 1);

        // transfer token to user2
        clone1155.safeTransferFrom(user1, user2, 1, 1, "");
        vm.stopPrank();
    }

    function testCloneERC721() public {
        vm.prank(tronicOwner);
        address clone721Address =
            factory.cloneERC721("Clone721", "CL721", "http://clone721.com/", user2);

        // clone should exist
        assertNotEq(clone721Address, address(0));

        // Check the clone has correct name, symbol, uri and admin
        ERC721CloneableTBA clone721 = ERC721CloneableTBA(clone721Address);
        assertEq(clone721.name(), "Clone721");
        assertEq(clone721.symbol(), "CL721");
        assertEq(clone721.isAdmin(user2), true);

        // Check the clone can be retrieved using getERC721Clone function
        assertEq(factory.getERC721Clone(0), clone721Address);

        console.log("clone721Address: ", clone721Address);
        // console clone's registry address
        console.log("clone721Address registry: ", address(clone721.registry()));

        // check clone registry is set
        assertEq(address(clone721.registry()), address(registry));

        //mint token to user2
        vm.prank(user2);
        clone721.mint(user2, 1);

        //check user2 owns token
        assertEq(clone721.ownerOf(1), user2);

        // verify uri
        assertEq(clone721.tokenURI(1), "http://clone721.com/1");
    }

    function testUnauthorizedCloning() public {
        // Prank the VM to make the unauthorized user the msg.sender
        vm.prank(unauthorizedUser);

        // Expect the cloneERC1155 function to be reverted due to unauthorized access
        vm.expectRevert();
        factory.cloneERC1155(
            "http://unauthorized1155.com/", unauthorizedUser, "Clone1155", "CL1155"
        );

        // Expect the cloneERC721 function to be reverted due to unauthorized access
        vm.expectRevert();
        factory.cloneERC721(
            "Unauthorized721", "UN721", "http://unauthorized721.com/", unauthorizedUser
        );
    }
}
