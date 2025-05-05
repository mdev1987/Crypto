// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {IFlashloan} from "../interfaces/IFlashloan.sol";

import "../interfaces/IFlashloan.sol";

library RouteUtils {
    function getInitialToken(
        IFlashloan.Route memory route
    ) internal pure returns (address) {
        return route.hops[0].path[0];
    }
}
