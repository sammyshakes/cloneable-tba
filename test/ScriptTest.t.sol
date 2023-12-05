// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../script/01_DeployTronic.s.sol";
import "../script/02_InitializeTronic.s.sol";
import "../script/03_DeployBrand.s.sol";
import "../script/04_DeployMembership.s.sol";

contract ScriptsTest is Test {
    DeployTronic public dt;
    InitializeTronic public it;
    DeployBrand public db;
    DeployMembership public dm;

    function setUp() public {
        //Deploy scripts
        dt = new DeployTronic();
        it = new InitializeTronic();
        db = new DeployBrand();
        dm = new DeployMembership();
    }

    function testDeployTronic() public {
        dt.run();
    }

    // function testInitializeTronic() public {
    //     it.run();
    // }

    function testDeployBrand() public {
        db.run();
    }

    function testDeployMembership() public {
        dm.run();
    }
}
