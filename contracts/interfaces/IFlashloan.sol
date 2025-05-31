// SPDX-License-Identifier: MIT
// Defines the flashloan parameters and interface for executeFlashLoan
pragma solidity ^0.8.8;

import {Route} from "../libraries/RouteUtils.sol";

/// @notice Parameters for flashloan execution
struct FlashParams {
    address flashLoanPool;
    uint256 loanAmount;
    Route[] routes;
}

/// @notice Interface for initiating a flashloan
interface IFlashloan {
    /// @notice Executes flashloan according to params
    function executeFlashLoan(FlashParams calldata params) external;
}
