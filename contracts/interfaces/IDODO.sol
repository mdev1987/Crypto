// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IDODO {
    /// @notice Executes a flash loan operation
    /// @dev Allows borrowing tokens temporarily with a callback mechanism
    /// @param baseAmount Amount of base tokens to borrow
    /// @param quoteAmount Amount of quote tokens to borrow
    /// @param assetTo Address to receive the borrowed assets
    /// @param data Arbitrary data passed to the borrower for callback logic
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function _BASE_TOKEN_() external view returns (address); // base token address

    function _BASE_RESERVE_() external view returns (address); // base token reserve address

    function _QUOTE_TOKEN_() external view returns (address); // quote token address

    function _QUOTE_RESERVE_() external view returns (address); // quote token reserve address
}
