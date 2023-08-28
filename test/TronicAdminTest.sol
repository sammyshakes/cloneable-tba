// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TronicAdmin.sol";
import "../src/ERC721CloneableTBA.sol";
import "../src/ERC1155Cloneable.sol";
import "../src/interfaces/IERC6551Registry.sol";
import "../src/interfaces/IERC6551Account.sol";
import "../src/CloneFactory.sol";

contract TronicAdminTest is Test {
    TronicAdmin tronicAdminContract;
    CloneFactory factory;
    ERC721CloneableTBA tronicERC721;
    ERC1155Cloneable tronicERC1155;
    IERC6551Account tbaCloneable;

    // set users
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    // new address for an unauthorized user
    address public unauthorizedUser = address(0x4);

    address public tronicOwner = address(0x5);
    address public tronicAdmin = address(0x6);

    address payable public tbaAddress =
        payable(vm.envAddress("TOKENBOUND_ACCOUNT_DEFAULT_IMPLEMENTATION_ADDRESS"));

    address public registryAddress = vm.envAddress("ERC6551_REGISTRY_ADDRESS");

    function setUp() public {
        tbaCloneable = IERC6551Account(tbaAddress);
        tronicAdminContract = new TronicAdmin();
        tronicERC721 = new ERC721CloneableTBA();
        tronicERC1155 = new ERC1155Cloneable();

        factory =
        new CloneFactory(tronicAdmin, address(tronicERC721), address(tronicERC1155), address(tbaCloneable), tbaAddress);

        //initialize Tronic erc1155
        tronicERC1155.initialize(
            "http://example1155.com/", address(tronicAdminContract), "Original1155", "OR1155"
        );

        //initialize tronicERC721
        tronicERC721.initialize(
            tbaAddress,
            registryAddress,
            "Original721",
            "OR721",
            "http://example721.com/",
            address(tronicAdminContract)
        );
    }

    function testAddPartnerContracts() public {
        tronicAdminContract.addPartnerContracts(
            "Partner1", address(tronicERC721), address(tronicERC1155)
        );

        TronicAdmin.PartnerInfo memory partner;
        partner = tronicAdminContract.getPartnerInfo(0);
        assertEq(partner.erc721Address, address(tronicERC721));
        assertEq(partner.erc1155Address, address(tronicERC1155));
        assertEq(partner.partnerName, "Partner1");
    }

    function testBatchProcess() public {
        tronicAdminContract.addPartnerContracts(
            "Partner1", address(tronicERC721), address(tronicERC1155)
        );

        address recipient = address(this);
        uint256[] memory partnerIds = new uint256[](1);
        partnerIds[0] = 0;

        uint256[][] memory tokenIds = new uint256[][](1);
        tokenIds[0] = new uint256[](1);
        tokenIds[0][0] = 1;

        uint256[][] memory amounts = new uint256[][](1);
        amounts[0] = new uint256[](1);
        amounts[0][0] = 1;

        address[] memory recipients = new address[](1);
        recipients[0] = recipient;

        TronicAdmin.TokenType[] memory tokenTypes = new TronicAdmin.TokenType[](1);
        tokenTypes[0] = TronicAdmin.TokenType.ERC721;

        // vm.prank(tronicOwner);
        tronicAdminContract.batchProcess(partnerIds, tokenIds, amounts, recipients, tokenTypes);

        // Here you can add assertions to check the result of batch processing
        // For instance, verify if tokens were minted to the recipient
        assertEq(tronicERC721.balanceOf(recipient), 1);
    }

    function testRemovePartner() public {
        tronicAdminContract.addPartnerContracts(
            "Partner1", address(tronicERC721), address(tronicERC1155)
        );
        tronicAdminContract.removePartner(0);

        TronicAdmin.PartnerInfo memory partner = tronicAdminContract.getPartnerInfo(0);
        assertEq(partner.erc721Address, address(0));
        assertEq(partner.erc1155Address, address(0));
        assertEq(partner.partnerName, "");
    }
}
