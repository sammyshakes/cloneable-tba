// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../script/01_DeployTronic.s.sol";
import "../script/03_DeployBrand.s.sol";
import "../script/04_DeployMembership.s.sol";
import "../script/05_CreateFungibleTypes.s.sol";
import "../script/06_MintBrandLoyalty.s.sol";
import "../script/07_MintMembership.s.sol";

contract ScriptsTest is Test {
    DeployTronic public dt;
    CreateFungibleTypes public cft;
    DeployBrand public db;
    DeployMembership public dm;
    MintBrandLoyalty public mbl;
    MintMembership public mm;

    function setUp() public {
        //Deploy scripts
        dt = new DeployTronic();
        cft = new CreateFungibleTypes();
        db = new DeployBrand();
        dm = new DeployMembership();
        mbl = new MintBrandLoyalty();
        mm = new MintMembership();
    }

    function testDeployTronic() public {
        dt.run();
    }

    function testCreateFungibleTypes() public {
        cft.run();
    }

    function testDeployBrand() public {
        db.run();
    }

    function testDeployMembership() public {
        dm.run();
    }

    function testMintBrandLoyalty() public {
        mbl.run();
    }

    function testMintMembership() public {
        mm.run();
    }
}
