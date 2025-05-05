// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import {IFlashloan} from "../interfaces/IFlashloan.sol";

/// @dev Abstract contract providing validation for flashloan operations
/// @notice Defines the maximum number of supported protocols for flashloan routing
abstract contract FlashloanValidation {
    uint256 constant MAX_PROTOCOL = 8;

    /// @dev Validates that the total route parts sum exactly to 10000 (100%)
    /// @notice Ensures route distribution is precisely allocated across protocols
    /// @param route An array of Route structs representing protocol distribution
    modifier checkTotalRoutePart(IFlashloan.Route[] memory route) {
        uint16 totalPart = 0;
        for (uint256 i = 0; i < route.length; i++) {
            totalPart += route[i].part;
        }
        require(totalPart == 10000, "Total part must be 10000");
        _;
    }
}
