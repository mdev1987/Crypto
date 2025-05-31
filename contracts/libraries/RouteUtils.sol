// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/// @dev Represents a single protocol hop in a route
struct Hop {
    uint8 protocol;
    bytes data;
    address[] path;
}

/// @dev A route is a weighted sequence of hops
struct Route {
    uint256 part;
    Hop[] hops;
}

library RouteUtils {
    /// @notice Returns the initial token of a route
    function getInitialToken(Route memory r) internal pure returns (address) {
        return r.hops[0].path[0];
    }
}
