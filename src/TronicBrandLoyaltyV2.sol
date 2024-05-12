// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./TronicBrandLoyalty.sol";

contract TronicBrandLoyaltyV2 is TronicBrandLoyalty {
    //upraded variable
    string public constant VERSION = "v0.2.0";

    function newFunction() external pure returns (bool) {
        return true;
    }
}
