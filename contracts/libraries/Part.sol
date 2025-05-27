// File: libraries/Part.sol
pragma solidity ^0.8.8;

library Part {
    /// @notice Converts a route fraction into an absolute amount
    /// @param part  Fraction in 1e18 units (e.g. 0.5e18 for 50%)
    /// @param total Total amount to split
    function partToAmountIn(
        uint256 part,
        uint256 total
    ) internal pure returns (uint256) {
        return (total * part) / 1e18;
    }
}
