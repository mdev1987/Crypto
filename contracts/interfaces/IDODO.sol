// File: interfaces/IDODO.sol
// Minimal DODO V2 pool interface for flashLoan and token info
pragma solidity ^0.8.8;

interface IDODO {
    /// @notice Returns this pool’s base token
    function _BASE_TOKEN_() external view returns (address);

    /// @notice Initiates a flash loan
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;
}
