// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {FlashParams} from "../interfaces/IFlashloan.sol";
import {Route} from "../libraries/RouteUtils.sol";

/// @dev Reuses modifiers to validate flashloan params and route weights
abstract contract FlashloanValidation {
    /// @notice Basic sanity checks on flashloan parameters
    modifier checkParams(FlashParams calldata params) {
        require(params.flashLoanPool != address(0), "Invalid pool");
        require(params.loanAmount > 0, "Zero loan");
        require(params.routes.length > 0, "No routes");
        _;
    }

    /// @notice Ensures that the sum of all route.part values equals 1e18 (100%)
    modifier checkTotalRoutePart(Route[] memory routes) {
        uint256 sum;
        for (uint256 i = 0; i < routes.length; i++) {
            sum += routes[i].part;
        }
        require(sum == 1e18, "Invalid total route weight");
        _;
    }
}
