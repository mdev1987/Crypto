// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IDODOProxy {
    /**
     * @notice Executes a token swap between two tokens using DODO V2 protocol
     * @param fromToken The address of the input token to be swapped
     * @param toToken The address of the output token to be received
     * @param fromTokenAmount The amount of input tokens to swap
     * @param minReturnAmount The minimum amount of output tokens expected from the swap
     * @param dodoPairs An array of DODO pair addresses used in the swap route
     * @param directions Bit-packed routing directions for the swap
     * @param isIncentive Flag indicating if the swap is incentivized
     * @param deadLine The timestamp by which the transaction must be completed
     * @return returnAmount The actual amount of tokens received after the swap
     */
    function dodoSwapV2TokenToToken(
        address fromToken,
        address toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        address[] memory dodoPairs,
        uint256 directions,
        bool isIncentive,
        uint256 deadLine
    ) external returns (uint256 returnAmount);
}
