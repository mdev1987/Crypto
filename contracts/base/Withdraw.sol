// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @dev Utility for owner to withdraw ERC20 or ETH
abstract contract Withdraw is Ownable {
    /// @notice Withdraw stuck ERC20 tokens
    function withdrawToken(address token) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, "Zero balance");
        IERC20(token).transfer(msg.sender, bal);
    }

    /// @notice Withdraw stuck ETH
    function withdrawETH() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "Zero balance");
        payable(msg.sender).transfer(bal);
    }
}
