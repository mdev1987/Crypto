// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IUniswapV2Router {
    /**
     * @notice Swaps an exact amount of input tokens for output tokens
     * @param amountIn The amount of input tokens to send
     * @param amountOutMin The minimum amount of output tokens that must be received
     * @param path An array of token addresses defining the swap route
     * @param to The recipient address of the output tokens
     * @param deadline The timestamp after which the transaction will revert
     * @return amounts An array of amounts representing input and output token amounts
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
