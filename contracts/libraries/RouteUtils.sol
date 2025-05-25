// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {IFlashloan} from "../interfaces/IFlashloan.sol";
import "../interfaces/IFlashloan.sol";

library RouteUtils {
    /// @notice Retrieves the initial token from the first hop of a route
    /// @dev Returns the first token in the first hop's path
    /// @param route The route containing hops and paths
    /// @return The address of the initial token in the route
    function getInitialToken(
        IFlashloan.Route memory route
    ) internal pure returns (address) {
        return route.hops[0].path[0];
    }
}
