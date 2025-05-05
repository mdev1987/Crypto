// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Withdraw
 * @notice Contract for withdrawing ERC20 tokens with owner-only access and reentrancy protection
 * @dev Inherits from OpenZeppelin's Ownable and ReentrancyGuard contracts
 */
contract Withdraw is Ownable, ReentrancyGuard {
    constructor() Ownable(msg.sender) {}

    /**
     * @notice Emitted when tokens are withdrawn from the contract
     * @param to The address receiving the withdrawn tokens
     * @param value The amount of tokens withdrawn
     */
    event Withdrawn(address indexed to, uint256 value);

    /**
     * @notice Withdraws a specified amount of ERC20 tokens to a given address
     * @dev Requires the caller to be the contract owner and prevents reentrancy
     * @param token The ERC20 token to withdraw
     * @param _to The recipient address of the withdrawn tokens
     * @param _value The amount of tokens to withdraw
     */
    function withdrawToken(
        IERC20 token,
        address _to,
        uint256 _value
    ) external onlyOwner nonReentrant {
        require(
            token.balanceOf(address(this)) >= _value,
            "Insufficient balance"
        );
        SafeERC20.safeTransfer(token, _to, _value);
        emit Withdrawn(_to, _value);
    }
}
