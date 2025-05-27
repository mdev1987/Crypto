// File: interfaces/IDODOProxy.sol
// Proxy interface to perform DODO V2 token-to-token swaps
pragma solidity ^0.8.8;

interface IDODOProxy {
    function dodoSwapV2TokenToToken(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 minReceiveAmount,
        address[] calldata pools,
        uint256 directions,
        bool isIncentive,
        uint64 deadLine
    ) external returns (uint256);
}
