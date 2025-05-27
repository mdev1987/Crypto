// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IFlashloan} from "../interfaces/IFlashloan.sol";

/// @dev Provides plumbing for dispatching DODO flash callbacks
abstract contract DodoBase is IFlashloan {
    function DVMFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    /// @dev Flash-loan callbacks funnel here
    function _flashLoanCallBack(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) internal virtual;
}
