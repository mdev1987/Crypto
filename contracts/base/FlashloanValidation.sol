// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {IFlashloan} from "../interfaces/IFlashloan.sol";

/// @dev Abstract contract providing validation for flashloan operations
/// @notice Defines the maximum number of supported protocols for flashloan routing
abstract contract FlashloanValidation {
    uint256 constant MAX_PROTOCOL = 8;

    /// @dev Validates that the total routes parts sum exactly to 10000 (100%)
    /// @notice Ensures routes distribution is precisely allocated across protocols
    /// @param routes An array of Route structs representing protocol distribution
    modifier checkTotalRoutePart(IFlashloan.Route[] memory routes) {
        uint16 totalPart = 0;
        for (uint256 i = 0; i < routes.length; i++) {
            totalPart += routes[i].part;
        }
        require(totalPart == 10000, "Total part must be 10000");
        _; // Continue with the function execution
    }
}
