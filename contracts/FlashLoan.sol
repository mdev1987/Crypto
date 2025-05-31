// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin v5+ imports
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Interface for DODO FlashLoan pools
interface IDODOFlashLoan {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;
}

// Minimal router interface for external swaps
interface IRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// Struct to describe a trading hop
struct TradeHop {
    uint8 protocol; // e.g. 1 = QuickSwap, 2 = SushiSwap, 3 = UniswapV3...
    address router;
    address[] path;
}

// Main contract
contract FlashLoan is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    address public immutable WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;

    constructor() Ownable(msg.sender) {}

    // Entry point for initiating a flash loan
    function executeFlashLoan(
        address pool,
        address loanToken,
        uint256 loanAmount,
        TradeHop[] calldata hops
    ) external onlyOwner nonReentrant {
        bytes memory data = abi.encode(loanToken, loanAmount, hops, msg.sender);
        IDODOFlashLoan(pool).flashLoan(
            loanToken == WETH ? loanAmount : 0,
            loanToken != WETH ? loanAmount : 0,
            address(this),
            data
        );
    }

    // Callback for DODO to invoke after loan is issued
    function DVMFlashLoanCall(
        address /* sender */,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        _handleFlashLoanCallback(baseAmount, quoteAmount, data);
    }

    function DPPFlashLoanCall(
        address /* sender */,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external nonReentrant {
        _handleFlashLoanCallback(baseAmount, quoteAmount, data);
    }

    function DSPFlashLoanCall(
        address /* sender */,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external nonReentrant {
        _handleFlashLoanCallback(baseAmount, quoteAmount, data);
    }

    // Internal logic for executing trades and repaying loan
    function _handleFlashLoanCallback(
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes memory data
    ) internal {
        (
            address loanToken,
            uint256 loanAmount,
            TradeHop[] memory hops,
            address initiator
        ) = abi.decode(data, (address, uint256, TradeHop[], address));

        require(
            loanAmount == baseAmount || loanAmount == quoteAmount,
            "Invalid flash loan amount"
        );

        IERC20(loanToken).safeIncreaseAllowance(hops[0].router, loanAmount);

        uint256 amountOut;
        for (uint256 i = 0; i < hops.length; i++) {
            TradeHop memory hop = hops[i];

            uint256 inputAmount = i == 0 ? loanAmount : amountOut;
            IERC20(hop.path[0]).safeIncreaseAllowance(hop.router, inputAmount);

            amountOut = IRouter(hop.router).swapExactTokensForTokens(
                inputAmount,
                0, // minOut
                hop.path,
                address(this),
                block.timestamp
            )[hop.path.length - 1];
        }

        // Repay flash loan
        IERC20(loanToken).safeTransfer(msg.sender, loanAmount);

        // Profit sent to initiator
        uint256 finalBalance = IERC20(
            hops[hops.length - 1].path[hops[hops.length - 1].path.length - 1]
        ).balanceOf(address(this));
        if (finalBalance > 0) {
            IERC20(
                hops[hops.length - 1].path[
                    hops[hops.length - 1].path.length - 1
                ]
            ).safeTransfer(initiator, finalBalance);
        }
    }

    // Emergency withdrawal
    function rescueTokens(address token, address to) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, balance);
    }
}
