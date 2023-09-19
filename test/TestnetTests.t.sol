// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Imports
import "forge-std/Test.sol";
import "../src/TronicMain.sol";
import "../src/interfaces/IERC6551Account.sol";

contract TestnetTests is Test {
    TronicMain public tronicAdminContract;
    TronicMembership public erc721;
    TronicToken public erc1155;
    IERC6551Account public account;
    IERC6551Account public accountTba;
    IERC6551Account public accountX;
    IERC6551Account public accountY;

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
    address public tronicAdminContractAddress = vm.envAddress("TRONIC_MAIN_CONTRACT_ADDRESS");
    address public erc721Address = vm.envAddress("TRONIC_MEMBERSHIP_ERC721_ADDRESS");
    address public erc1155Address = vm.envAddress("TRONIC_TOKEN_ERC1155_ADDRESS");

    // cloned project contracts
    address public cloned1155AddressX = vm.envAddress("MEMBERSHIP_X_ERC1155_ADDRESS");
    address public cloned1155AddressY = vm.envAddress("MEMBERSHIP_Y_ERC1155_ADDRESS");
    address public cloned721AddressX = vm.envAddress("MEMBERSHIP_X_ERC721_ADDRESS");
    address public cloned721AddressY = vm.envAddress("MEMBERSHIP_Y_ERC721_ADDRESS");

    // tokenbound accounts
    address public tbaAddressTokenID1 = vm.envAddress("TOKENBOUND_ACCOUNT_TOKENID_1");
    address public tbaAddressXTokenID1 = vm.envAddress("MEMBERSHIP_X_TOKENBOUND_ACCOUNT_TOKENID_1");
    address public tbaAddressYTokenID1 = vm.envAddress("MEMBERSHIP_Y_TOKENBOUND_ACCOUNT_TOKENID_1");

    function setUp() public {
        erc721 = TronicMembership(erc721Address);
        erc1155 = TronicToken(erc1155Address);
        registry = IERC6551Registry(registryAddress);

        accountTba = IERC6551Account(payable(tbaAddressTokenID1));
        accountX = IERC6551Account(payable(tbaAddressXTokenID1));
        accountY = IERC6551Account(payable(tbaAddressYTokenID1));

        tronicAdminContract = TronicMain(tronicAdminContractAddress);
    }

    function testTransferERC1155FromNestedAccount() public {
        (uint256 chainId, address tokenContractAddress, uint256 _tokenId) = accountTba.token();
        console.log("chainId: ", chainId);
        console.log("tokenContract: ", tokenContractAddress);
        console.log("tokenId: ", _tokenId);

        (, address tokenContractAddressaccountX, uint256 _tokenIdaccountX) = accountX.token();
        console.log("tokenContract accountX: ", tokenContractAddressaccountX);
        console.log("tokenId accountX: ", _tokenIdaccountX);

        (, address tokenContractAddressaccountY, uint256 _tokenIdaccountY) = accountY.token();
        console.log("tokenContract accountY: ", tokenContractAddressaccountY);
        console.log("tokenId accountY: ", _tokenIdaccountY);

        TronicMembership tokenContract = TronicMembership(tokenContractAddress); // Parent TBA ERC721 token contract
        TronicMembership clonedERC721X = TronicMembership(cloned721AddressX); // Nested TBA ERC721 token contract
        TronicToken clonedERC1155X = TronicToken(cloned1155AddressX); // assets owned by nested TBA

        console.log("accountTba: ", address(accountTba));
        console.log("accountTba owner: ", accountTba.owner());
        console.log("accountX: ", address(accountX));
        console.log("accountX owner: ", accountX.owner());

        console.log("accountY owner: ", accountY.owner());
        console.log("clonedERC721X.ownerOf(1): ", clonedERC721X.ownerOf(1));

        // Top level TBA is owned by tbaOwner (a random user),
        assertEq(_tokenId, 1);
        assertEq(tokenContract.ownerOf(_tokenId), tbaOwner);
        assertEq(accountTba.owner(), tbaOwner);

        assertEq(tokenContractAddress, erc721Address);

        // Top level TBA owns tokenId 1 on clonedERC721X (erc721), `nestedTbaAddress`
        assertEq(clonedERC721X.ownerOf(1), address(accountTba));
        assertEq(accountX.owner(), address(accountTba)); //  parent TBA owns nested TBA
        assertEq(tbaAddressTokenID1, address(accountTba));

        // construct SafeTransferCall for ERC721
        bytes memory erc721TransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,bytes)", tbaAddressTokenID1, user1, 1, ""
        );

        vm.prank(tbaOwner, tbaOwner);
        accountTba.executeCall(cloned721AddressX, 0, erc721TransferCall);

        // verify that user 1 now owns token
        assertEq(clonedERC721X.ownerOf(1), user1);

        // transfer token back to tbaAddressTokenID1
        vm.prank(user1);
        clonedERC721X.safeTransferFrom(user1, tbaAddressTokenID1, 1, "");

        // verify that tbaAddressTokenID1 now owns token
        assertEq(clonedERC721X.ownerOf(1), tbaAddressTokenID1);

        //ERC1155
        assertEq(clonedERC1155X.balanceOf(tbaAddressXTokenID1, 1), 100);

        // construct SafeTransferCall for nested ERC1155
        bytes memory erc1155TransferCall = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)",
            tbaAddressXTokenID1,
            user1,
            1,
            10,
            ""
        );

        // construct execute call for tbaAddressXTokenID1 to execute erc1155TransferCall
        bytes memory executeCall = abi.encodeWithSignature(
            "executeCall(address,uint256,bytes)", cloned1155AddressX, 0, erc1155TransferCall
        );

        vm.prank(tbaOwner);
        accountTba.executeCall(tbaAddressXTokenID1, 0, executeCall);

        // verify that user 1 now owns 10 of token 1
        assertEq(clonedERC1155X.balanceOf(user1, 1), 10);
        assertEq(clonedERC1155X.balanceOf(tbaAddressXTokenID1, 1), 90);

        // approve user 2 to control tba
        address[] memory approved = new address[](1);
        approved[0] = user2;
        bool[] memory approvedValues = new bool[](1);
        approvedValues[0] = true;

        vm.prank(tbaOwner);
        accountTba.setPermissions(approved, approvedValues);

        vm.prank(user2);
        accountTba.executeCall(tbaAddressXTokenID1, 0, executeCall);
    }

    function testTransferERC1155PostDeploy() public {
        uint256 tokenId = 1;

        address accountCheck = registry.account(tbaAddress, 11_155_111, erc721Address, 1, 0);
        console.log("accountCheck: ", accountCheck);

        (uint256 chainId, address tokenContract, uint256 _tokenId) = accountTba.token();
        console.log("chainId: ", chainId);
        console.log("tokenContract: ", tokenContract);
        console.log("tokenId: ", _tokenId);

        // Check the clone has correct uri and admin
        TronicToken clonedERC1155X = TronicToken(cloned1155AddressX);

        assertEq(erc721.ownerOf(tokenId), tronicOwner);

        //retrieve and print out the erc1155 owner, name and symbol
        console.log("clonedERC1155X owner: ", clonedERC1155X.owner());

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
    }

    function testUnauthorizedCloning() public {
        // Prank the VM to make the unauthorized user the msg.sender
        vm.prank(unauthorizedUser);

        // Expect the cloneERC1155 function to be reverted due to unauthorized access
        vm.expectRevert();
        tronicAdminContract.deployMembership("", "", "", 0, false);

        // Expect the cloneERC721 function to be reverted due to unauthorized access
        vm.expectRevert();
        tronicAdminContract.deployMembership(
            "Unauthorized721", "UN721", "http://unauthorized721.com/", 10_000, false
        );
    }
}
