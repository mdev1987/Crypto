// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "../interfaces/IFlashloan.sol";
import "../libraries/RouteUtils.sol";
import "../interfaces/IDODO.sol";

/**
 * @title DodoBase
 * @dev Base contract for Dodo flash loan implementations across different pool types
 * @notice Provides standardized flash loan callback methods for DVM, DPP, and DSP pool types
 */
contract DodoBase is IFlashloan {
    /**
     * @notice Callback function for DVM pool flash loan
     * @dev Handles the flash loan callback for DVM (Dodo Vending Machine) type pools
     * @param sender The initiator of the flash loan
     * @param baseAmount The amount of base tokens borrowed
     * @param quoteAmount The amount of quote tokens borrowed
     * @param data Additional data passed to the flash loan callback
     */
    function DVMFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    /**
     * @notice Callback function for DPP pool flash loan
     * @dev Handles the flash loan callback for DPP (Dodo Private Pool) type pools
     * @param sender The initiator of the flash loan
     * @param baseAmount The amount of base tokens borrowed
     * @param quoteAmount The amount of quote tokens borrowed
     * @param data Additional data passed to the flash loan callback
     */
    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    /**
     * @notice Callback function for DSP pool flash loan
     * @dev Handles the flash loan callback for DSP (Dodo Stable Pool) type pools
     * @param sender The initiator of the flash loan
     * @param baseAmount The amount of base tokens borrowed
     * @param quoteAmount The amount of quote tokens borrowed
     * @param data Additional data passed to the flash loan callback
     */
    function DSPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _flashLoanCallBack(sender, baseAmount, quoteAmount, data);
    }

    function _flashLoanCallBack(
        address,
        uint256,
        uint256,
        bytes calldata data
    ) internal virtual {}

    /**
     * @notice Validates flash loan parameters against the specified pool
     * @dev Checks that the initial loan token matches either the base or quote token of the flash loan pool
     * @param params The flash loan parameters to validate
     * @custom:throws Reverts if the loan token does not match the base or quote token of the flash loan pool
     */
    modifier checkParams(FlashParams memory params) {
        address loanToken = RouteUtils.getInitialToken(params.routes[0]); // Get the initial token from the route
        bool loanEqBase = loanToken ==
            IDODO(params.flashLoanPool)._BASE_TOKEN_(); // Check if the loan token is the base token
        bool loanEqQuote = loanToken ==
            IDODO(params.flashLoanPool)._QUOTE_TOKEN_(); // Check if the loan token is the quote token
        require(loanEqBase || loanEqQuote, "Wrong flashloan pool address");
        _;
    }
}
