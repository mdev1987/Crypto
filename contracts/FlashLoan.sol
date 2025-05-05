// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IFlashloan} from "./interfaces/IFlashloan.sol";
import {DodoBase} from "./base/DodoBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Withdraw} from "./base/Withdraw.sol";
import {RouteUtils} from "./libraries/RouteUtils.sol";
import {IDODO} from "./interfaces/IDODO.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {FlashloanValidation} from "./base/FlashloanValidation.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Part} from "./libraries/Part.sol";
import "hardhat/console.sol";
import {ISwapRouter} from "./uniswap/V3/ISwapRouter.sol";
import {IUniswapV2Router} from "./uniswap/IUniswapV2Router.sol";
import {IDODOProxy} from "./interfaces/IDODOProxy.sol";

/**
 * @title FlashLoan Contract
 * @notice Implements a multi-protocol flash loan execution and routing mechanism
 * @dev Supports swaps across Uniswap V2, Uniswap V3, and Dodo V2 protocols
 * @dev Inherits from multiple base contracts for flash loan validation, withdrawal, and DODO base functionality
 */
contract FlashLoan is IFlashloan, DodoBase, Withdraw, FlashloanValidation {
    using Math for uint256;
    using SafeERC20 for IERC20;
    event SentProfit(address indexed receiption, uint256 profit);
    event SwapFinished(address token, uint256 amount);
    event LoanRepaid(address indexed pool, uint256 amount);
    event TokenApproved(
        address indexed token,
        address indexed spender,
        uint256 amount
    );

    /**
     * @notice Executes a flash loan from a specified DODO pool
     * @dev Initiates a flash loan with configurable routes and loan parameters
     * @param params Flash loan parameters including pool, amount, and routing information
     * @dev Requires the caller to be the contract owner and passes parameter validation
     * @dev Supports flash loans with base and quote token configurations
     * @dev Logs token balances before and after borrowing for debugging purposes
     */
    function executeFlashLoan(
        FlashParams memory params
    ) external nonReentrant checkParams(params) onlyOwner {
        bytes memory data = abi.encode(
            params.flashLoanPool,
            params.loanAmount,
            params.routes
        );

        address loanToken = RouteUtils.getInitialToken(params.routes[0]);
        console.log(
            "Balance Before Borrowing: ",
            IERC20(loanToken).balanceOf(address(this))
        );

        address baseToken = IDODO(params.flashLoanPool)._BASE_TOKEN_();
        console.log("Base Token: ", baseToken);
        uint256 baseAmount = baseToken == loanToken ? params.loanAmount : 0;
        uint256 quoteAmount = baseToken == loanToken ? 0 : params.loanAmount;

        IDODO(params.flashLoanPool).flashLoan(
            baseAmount,
            quoteAmount,
            address(this),
            data
        );
        console.log(
            "Balance After Borrowing: ",
            IERC20(loanToken).balanceOf(address(this))
        );
    }

    /**
     * @notice Approves a token for spending by a specific spender
     * @dev Internal function that can only be called by the contract owner
     * @param token The address of the token to be approved
     * @param spender The address allowed to spend the tokens
     * @param amount The amount of tokens to approve for spending
     * @dev Requires successful token approval, otherwise reverts with an error message
     * @dev Emits a TokenApproved event upon successful approval
     */
    function ApproveToken(
        address token,
        address spender,
        uint256 amount
    ) internal onlyOwner {
        require(IERC20(token).approve(spender, amount), "Approval failed");
        emit TokenApproved(token, spender, amount);
    }

    /**
     * @dev Callback function for handling flash loan logic after borrowing
     * @param data Encoded flash loan parameters
     *
     * This internal function is called after receiving a flash loan and performs the following steps:
     * 1. Decodes the flash loan parameters
     * 2. Validates the loan token balance
     * 3. Executes routing through different swap protocols
     * 4. Repays the original loan amount
     * 5. Transfers any remaining profit to the contract owner
     *
     * Emits:
     * - SwapFinished when swap operations are completed
     * - LoanRepaid when the loan is repaid to the flash loan pool
     * - SentProfit when remaining balance is transferred to the owner
     *
     * Requirements:
     * - Must have sufficient balance to repay the loan
     * - Loan token balance must meet minimum requirements
     */
    function _flashLoanCallBack(
        address,
        uint256,
        uint256,
        bytes calldata data
    ) internal override {
        FlashParams memory decoded = abi.decode(data, (FlashParams));

        address loanToken = RouteUtils.getInitialToken(decoded.routes[0]);
        require(
            IERC20(loanToken).balanceOf(address(this)) >= decoded.loanAmount,
            "Insufficient balance after borrowing"
        );
        console.log(
            "Balance Before Borrowing: ",
            IERC20(loanToken).balanceOf(address(this))
        );

        // Execute the logic for routing the loan through different swaps
        routeLoop(decoded.routes, decoded.loanAmount);

        console.log(
            "Loan Token balance after borrowing and swap: ",
            IERC20(loanToken).balanceOf(address(this))
        );

        emit SwapFinished(
            loanToken,
            IERC20(loanToken).balanceOf(address(this))
        );

        // Repay the loan back to the flash loan pool
        require(
            IERC20(loanToken).balanceOf(address(this)) >= decoded.loanAmount,
            "Not enough amount to return the loan"
        );
        IERC20(loanToken).transfer(decoded.flashLoanPool, decoded.loanAmount);
        emit LoanRepaid(decoded.flashLoanPool, decoded.loanAmount);

        // Transfer the profit
        console.log(
            "Loan Token Balance After Repaying: ",
            IERC20(loanToken).balanceOf(address(this))
        );
        uint256 remaindedBalance = IERC20(loanToken).balanceOf(address(this));
        IERC20(loanToken).transfer(owner(), remaindedBalance);

        emit SentProfit(owner(), remaindedBalance);
    }

    /**
     * @dev Executes a loop over an array of routes and processes each route by calculating the
     *      corresponding amount and invoking the hopLoop function.
     * @param routes An array of Route structs representing the paths for the operation.
     * @param totalAmount The total amount to be distributed across the routes.
     *
     * Requirements:
     * - The `routes` array must satisfy the `checkTotalRoutePart` modifier condition.
     *
     * Emits:
     * - Logs the total loan token amount for each swap iteration.
     */
    function routeLoop(
        Route[] memory routes,
        uint256 totalAmount
    ) internal checkTotalRoutePart(routes) {
        for (uint256 i = 0; i < routes.length; i++) {
            uint256 amountIn = Part.partToAmountIn(routes[i].part, totalAmount);
            console.log("Loan Token Amount for swap: ", totalAmount);
            hopLoop(routes[i], amountIn);
        }
    }

    function hopLoop(Route memory route, uint256 totalAmount) internal {
        uint256 amountIn = totalAmount;
        for (uint256 i = 0; i < route.hops.length; i++) {
            amountIn = pickProtocol(route.hops[i], amountIn);
        }
    }

    function pickProtocol(
        Hop memory hop,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        if (hop.protocol == 0) {
            amountOut = uniSwapV3(hop.data, amountIn, hop.path);
            console.log(
                "Amount Out: ",
                amountOut,
                " for protocol: ",
                hop.protocol
            );
        } else if (hop.protocol > 8) {
            // UniswapV2 forked: QuickSwap, Sushiswap, PancakeSwap, etc.
            // Add logic for another protocol here
            amountOut = uniSwapV2(hop.data, amountIn, hop.path);
            console.log(
                "Amount Out: ",
                amountOut,
                " for protocol: ",
                hop.protocol
            );
        } else {
            amountOut = dodoV2Swap(hop.data, amountIn, hop.path);
            console.log(
                "Amount Out: ",
                amountOut,
                " for protocol: ",
                hop.protocol
            );
        }
    }

    function uniSwapV3(
        bytes memory data,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256 amountOut) {
        (address router, uint24 fee) = abi.decode(data, (address, uint24));
        ISwapRouter swapRouter = ISwapRouter(router);

        // Approve the router to spend the token
        ApproveToken(path[0], address(swapRouter), amountIn);

        amountOut = swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: path[0],
                tokenOut: path[1],
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );
    }

    /**
     * @dev Performs a token swap on Uniswap V2
     * @param data Encoded router address to use for the swap
     * @param amountIn Amount of input tokens to swap
     * @param path Array of token addresses representing the swap path
     * @return amountOut Amount of output tokens received from the swap
     * @notice This function:
     * 1. Decodes the router address from input data
     * 2. Approves the router to spend input tokens
     * 3. Executes swap with 1 minute deadline
     * 4. Returns amount of output tokens (second element in returned array)
     */
    function uniSwapV2(
        bytes memory data,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256 amountOut) {
        address router = abi.decode(data, (address));
        // Approve the router to spend the token
        ApproveToken(path[0], router, amountIn);
        // Perform the swap
        uint256 amountOutMin = Math.mulDiv(amountIn, 95, 100); // 5% slippage
        amountOut = IUniswapV2Router(router).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 60 // 1 minute deadline
        )[1]; // Amount out is the second element in the returned array
    }

    /**
     * @dev Executes a swap on the Dodo V2 protocol.
     * @param data The encoded parameters for the swap.
     * @param amountIn The amount of input tokens to be swapped.
     * @param path The path of tokens for the swap.
     * @return amountOut The amount of output tokens received from the swap.
     */
    function dodoV2Swap(
        bytes memory data,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256 amountOut) {
        (address dodoV2Pool, address dodoApprove, address dodoProxy) = abi
            .decode(data, (address, address, address));
        address[] memory dodoPairs = new address[](1);
        dodoPairs[0] = dodoV2Pool;
        uint256 directions = IDODO(dodoV2Pool)._BASE_TOKEN_() == path[0]
            ? 1
            : 0; // 0 for base to quote, 1 for quote to base
        // Approve the Dodo router to spend the token
        ApproveToken(path[0], dodoApprove, amountIn);
        // Perform the swap
        amountOut = IDODOProxy(dodoProxy).dodoSwapV2TokenToToken(
            path[0],
            path[1],
            amountIn,
            1,
            dodoPairs,
            directions,
            false,
            block.timestamp + 60 // 1 minute deadline
        );
    }
}
