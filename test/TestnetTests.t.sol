// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Imports
import "forge-std/Test.sol";
import "../src/TronicAdmin.sol";
import "../src/interfaces/IERC6551Account.sol";

contract TestnetTests is Test {
    TronicAdmin public tronicAdminContract;
    ERC721CloneableTBA public erc721;
    ERC1155Cloneable public erc1155;
    IERC6551Account public account;
    IERC6551Account public accountTba;
    IERC6551Account public accountX;
    IERC6551Account public accountY;
    IERC6551Account public accountTronic;

    IERC6551Registry public registry;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    // new address for an unauthorized user
    address public unauthorizedUser = address(0x4);

    address public tronicOwner = vm.envAddress("TRONIC_ADMIN_ADDRESS");
    address public tbaOwner = vm.envAddress("TRONIC_ADMIN_ADDRESS");

    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));
    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");

    // deployed tronic contracts
    address public tronicAdminContractAddress = vm.envAddress("TRONIC_ADMIN_CONTRACT_ADDRESS");
    address public erc721Address = vm.envAddress("TRONIC_MEMBER_ERC721_ADDRESS");
    address public erc1155Address = vm.envAddress("TRONIC_REWARDS_ERC1155_ADDRESS");

    // cloned project contracts
    address public cloned1155AddressX = vm.envAddress("PARTNER_X_CLONED_ERC1155_ADDRESS");
    address public cloned1155AddressY = vm.envAddress("PARTNER_Y_CLONED_ERC1155_ADDRESS");
    address public cloned721AddressX = vm.envAddress("PARTNER_X_CLONED_ERC721_ADDRESS");
    address public cloned721AddressY = vm.envAddress("PARTNER_Y_CLONED_ERC721_ADDRESS");

    // tokenbound accounts
    address public tbaAddressTokenID1 = vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1");
    address public tbaAddressXTokenID1 = vm.envAddress("PARTNER_X_TOKENBOUND_ACCOUNT_TOKENID_1");
    address public tbaAddressYTokenID1 = vm.envAddress("PARTNER_Y_TOKENBOUND_ACCOUNT_TOKENID_1");

    function setUp() public {
        vm.startPrank(tronicOwner);
        erc721 = ERC721CloneableTBA(erc721Address);
        erc1155 = ERC1155Cloneable(erc1155Address);
        registry = IERC6551Registry(registryAddress);

        account = IERC6551Account(payable(tbaAddress));
        accountX = IERC6551Account(payable(tbaAddressXTokenID1));
        accountY = IERC6551Account(payable(tbaAddressYTokenID1));
        accountTronic = IERC6551Account(payable(tbaAddressTokenID1));
        accountTba = IERC6551Account(payable(tbaAddressTokenID1));

        tbaAddress = payable(address(account));

        tronicAdminContract = TronicAdmin(tronicAdminContractAddress);
        vm.stopPrank();
    }

    function testTransferERC1155FromNestedAccount() public {
        address nestedTbaAddress = tbaAddressXTokenID1;
        IERC6551Account nestedTba = accountX;

        (uint256 chainId, address tokenContractAddress, uint256 _tokenId) = accountTba.token();
        console.log("chainId: ", chainId);
        console.log("tokenContract: ", tokenContractAddress);
        console.log("tokenId: ", _tokenId);

        ERC721CloneableTBA tokenContract = ERC721CloneableTBA(tokenContractAddress); // Parent TBA ERC721 token contract
        ERC721CloneableTBA clonedERC721X = ERC721CloneableTBA(cloned721AddressX); // Nested TBA ERC721 token contract
        ERC1155Cloneable clonedERC1155X = ERC1155Cloneable(cloned1155AddressX); // assets owned by nested TBA

        // Top level TBA is owned by tbaOwner (a random user),
        assertEq(_tokenId, 1);
        assertEq(tokenContract.ownerOf(_tokenId), tbaOwner);
        assertEq(accountTba.owner(), tbaOwner);

        // Top level TBA owns tokenId 1 on clonedERC721X (erc721), `nestedTbaAddress`
        assertEq(clonedERC721X.ownerOf(1), address(accountTba));
        assertEq(nestedTba.owner(), address(accountTba)); //  parent TBA owns nested TBA
        assertEq(tbaAddressTokenID1, address(accountTba));

        // construct SafeTransferCall for ERC721
        bytes memory erc721TransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,bytes)", tbaAddressTokenID1, user1, 1, ""
        );

        vm.prank(tbaOwner);
        accountTba.executeCall(cloned721AddressX, 0, erc721TransferCall);

        // verify that user 1 now owns token
        assertEq(clonedERC721X.ownerOf(1), user1);

        // transfer token back to tbaAddressTokenID1
        vm.prank(user1);
        clonedERC721X.safeTransferFrom(user1, tbaAddressTokenID1, 1, "");

        // verify that tbaAddressTokenID1 now owns token
        assertEq(clonedERC721X.ownerOf(1), tbaAddressTokenID1);

        //ERC1155
        assertEq(clonedERC1155X.balanceOf(nestedTbaAddress, 1), 100);

        // construct SafeTransferCall for nested ERC1155
        bytes memory erc1155TransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)",
            nestedTbaAddress,
            user1,
            1,
            10,
            ""
        );

        // construct execute call for nestedTbaAddress to execute erc1155TransferCall
        bytes memory executeCall = abi.encodeWithSignature(
            "executeCall(address,uint256,bytes)", cloned1155AddressX, 0, erc1155TransferCall
        );

        vm.prank(tbaOwner);
        accountTba.executeCall(nestedTbaAddress, 0, executeCall);

        // verify that user 1 now owns 10 of token 1
        assertEq(clonedERC1155X.balanceOf(user1, 1), 10);
        assertEq(clonedERC1155X.balanceOf(nestedTbaAddress, 1), 90);

        // approve user 2 to control tba
        address[] memory approved = new address[](1);
        approved[0] = user2;
        bool[] memory approvedValues = new bool[](1);
        approvedValues[0] = true;

        vm.prank(tbaOwner);
        accountTba.setPermissions(approved, approvedValues);

        vm.prank(user2);
        accountTba.executeCall(nestedTbaAddress, 0, executeCall);
    }

    function testTransferERC1155PostDeploy() public {
        uint256 tokenId = 1;

        address accountCheck = registry.account(tbaAddress, 11_155_111, erc721Address, 1, 0);
        console.log("accountCheck: ", accountCheck);

        (uint256 chainId, address tokenContract, uint256 _tokenId) = accountTronic.token();
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

    function testUnauthorizedCloning() public {
        // Prank the VM to make the unauthorized user the msg.sender
        vm.prank(unauthorizedUser);

        // Expect the cloneERC1155 function to be reverted due to unauthorized access
        vm.expectRevert();
        tronicAdminContract.deployPartner(
            "", "", "", 0, "Clone1155", "CL1155", "http://unauthorized1155.com/", "Name1"
        );

        // Expect the cloneERC721 function to be reverted due to unauthorized access
        vm.expectRevert();
        tronicAdminContract.deployPartner(
            "Unauthorized721", "UN721", "http://unauthorized721.com/", 10_000, "", "", "", "Name2"
        );
    }
}
