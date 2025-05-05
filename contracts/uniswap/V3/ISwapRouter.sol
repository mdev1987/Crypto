// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface ISwapRouter {
    /// @notice Parameters for performing a single exact input swap
    /// @dev Defines the details required for swapping a precise amount of input tokens
    /// @param tokenIn Address of the token being sent
    /// @param tokenOut Address of the token being received
    /// @param fee Pool fee tier for the swap
    /// @param recipient Address that will receive the output tokens
    /// @param deadline Timestamp after which the transaction will revert
    /// @param amountIn Exact amount of input tokens to be swapped
    /// @param amountOutMinimum Minimum amount of output tokens expected to be received
    /// @param sqrtPriceLimitX96 Price limit for the swap, represented as a square root price
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Performs a single exact input swap
    /// @dev Swaps a fixed amount of input tokens for a minimum amount of output tokens
    /// @param params The parameters for the exact input single swap
    /// @return amountOut The amount of output tokens received from the swap
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    /**
     * @dev Struct representing the parameters for an exact input swap.
     * @param path The encoded path of the swap, specifying the sequence of pools and tokens.
     * @param recipient The address that will receive the output tokens from the swap.
     * @param deadline The timestamp by which the transaction must be completed, to avoid stale trades.
     * @param amountIn The amount of input tokens to be swapped.
     * @param amountOutMinimum The minimum amount of output tokens that must be received for the transaction not to revert.
     */
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /**
     * @notice Executes a swap with an exact input amount, returning the output amount.
     * @param params The parameters necessary for the swap, encapsulated in the ExactInputParams struct.
     * @return amountOut The amount of the output token received from the swap.
     *
     * @dev This function allows the caller to specify the exact amount of input tokens to be swapped.
     *      The function is payable to support swaps involving ETH.
     */
    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);

    /**
     * @dev Parameters for executing an exact output single swap on Uniswap V3.
     *
     * @param tokenIn The address of the token being swapped from.
     * @param tokenOut The address of the token being swapped to.
     * @param fee The fee tier of the pool to use for the swap, expressed in hundredths of a bip (e.g., 3000 for 0.3%).
     * @param recipient The address that will receive the output tokens.
     * @param deadline The timestamp by which the transaction must be completed, to prevent execution in the future.
     * @param amountOut The exact amount of the output token to receive from the swap.
     * @param amountInMaximum The maximum amount of the input token that can be spent to receive the specified `amountOut`.
     * @param sqrtPriceLimitX96 The price limit of the pool after the swap, encoded as a sqrt(price) Q64.96 value.
     */
    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /**
     * @notice Executes a single-hop swap to achieve an exact output amount of the desired token.
     * @param params The parameters necessary for the swap, encapsulated in the `ExactOutputSingleParams` struct:
     * - `tokenIn`: The address of the input token.
     * - `tokenOut`: The address of the output token.
     * - `fee`: The fee tier of the pool to use for the swap.
     * - `recipient`: The address to receive the output tokens.
     * - `deadline`: The time by which the transaction must be completed.
     * - `amountOut`: The exact amount of the output token to receive.
     * - `amountInMaximum`: The maximum amount of the input token that can be used for the swap.
     * - `sqrtPriceLimitX96`: The price limit of the pool that cannot be exceeded during the swap.
     * @return amountIn The amount of the input token actually spent in the swap.
     */
    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    ) external payable returns (uint256 amountIn);

    /// @notice Parameters for performing an exact output multi-hop swap
    /// @dev Defines the parameters required for swapping tokens with a specified exact output amount across multiple hops
    /// @param path Encoded path of tokens to swap through
    /// @param recipient Address to receive the output tokens
    /// @param deadline Timestamp after which the transaction will revert
    /// @param amountOut Exact amount of output tokens desired
    /// @param amountInMaximum Maximum amount of input tokens willing to be spent
    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Performs a multi-hop exact output swap
    /// @dev Swaps tokens along a specified path to receive a fixed amount of output tokens
    /// @param params The parameters for the exact output swap, including path, recipient, and amount constraints
    /// @return amountIn The total amount of input tokens spent to achieve the desired output
    function exactOutput(
        ExactOutputParams calldata params
    ) external payable returns (uint256 amountIn);
}
