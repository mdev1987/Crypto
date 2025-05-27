// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IFlashloan, FlashParams} from "./interfaces/IFlashloan.sol";
import {DodoBase} from "./base/DodoBase.sol";
import {Withdraw} from "./base/Withdraw.sol";
import {FlashloanValidation} from "./base/FlashloanValidation.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20, IERC20 as SafeIERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {RouteUtils, Route, Hop} from "./libraries/RouteUtils.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IDODO} from "./interfaces/IDODO.sol";
import {Part} from "./libraries/Part.sol";
import {ISwapRouter} from "./uniswap/V3/ISwapRouter.sol";
import {IUniswapV2Router} from "./uniswap/IUniswapV2Router.sol";
import {IDODOProxy} from "./interfaces/IDODOProxy.sol";

/**
 * @title FlashLoan Executor
 * @notice Executes multi-protocol flash loans via DODO pools with route-based swaps
 */
contract FlashLoan is DodoBase, FlashloanValidation, Withdraw, ReentrancyGuard {
    using SafeERC20 for SafeIERC20;

    /// @notice Emitted after all swaps are executed
    event SwapsExecuted(address indexed token, uint256 balanceAfter);
    /// @notice Emitted when the loan is repaid
    event LoanRepaid(address indexed pool, uint256 amount);
    /// @notice Emitted when profit is sent to the owner
    event ProfitSent(address indexed recipient, uint256 amount);
    /// @notice Emitted when tokens are approved
    event Approval(
        address indexed token,
        address indexed spender,
        uint256 amount
    );

    constructor() Ownable() {}

    uint256 private constant MAX_UINT = type(uint256).max;
    uint256 private constant SLIPPAGE_NUM = 95;
    uint256 private constant SLIPPAGE_DEN = 100;
    uint256 private constant DEADLINE_DELAY = 60;

    /// @inheritdoc IFlashloan
    function executeFlashLoan(
        FlashParams calldata params
    ) external onlyOwner nonReentrant checkParams(params) {
        bytes memory data = abi.encode(params);

        address loanToken = RouteUtils.getInitialToken(params.routes[0]);
        address baseToken = IDODO(params.flashLoanPool)._BASE_TOKEN_();
        uint256 baseAmt = (baseToken == loanToken) ? params.loanAmount : 0;
        uint256 quoteAmt = (baseToken == loanToken) ? 0 : params.loanAmount;

        IDODO(params.flashLoanPool).flashLoan(
            baseAmt,
            quoteAmt,
            address(this),
            data
        );
    }

    /// @inheritdoc DodoBase
    function _flashLoanCallBack(
        address,
        uint256,
        uint256,
        bytes calldata data
    ) internal override {
        FlashParams memory cfg = abi.decode(data, (FlashParams));
        address pool = cfg.flashLoanPool;
        address loanToken = RouteUtils.getInitialToken(cfg.routes[0]);
        uint256 owed = cfg.loanAmount;

        if (msg.sender != pool) revert Unauthorized();
        if (IERC20(loanToken).balanceOf(address(this)) < owed)
            revert InsufficientBalance();

        _executeRoutes(cfg.routes, owed);
        emit SwapsExecuted(
            loanToken,
            IERC20(loanToken).balanceOf(address(this))
        );

        SafeIERC20(loanToken).safeTransfer(pool, owed);
        emit LoanRepaid(pool, owed);

        uint256 profit = IERC20(loanToken).balanceOf(address(this));
        if (profit > 0) {
            SafeIERC20(loanToken).safeTransfer(owner(), profit);
            emit ProfitSent(owner(), profit);
        }
    }

    /// @dev Approve spender for maximum allowance
    function _approveMax(address token, address spender) internal onlyOwner {
        SafeIERC20(token).safeApprove(spender, MAX_UINT);
        emit Approval(token, spender, MAX_UINT);
    }

    /// @dev Loop through all routes; ensure weights sum to 1e18
    function _executeRoutes(
        Route[] memory routes,
        uint256 total
    ) internal checkTotalRoutePart(routes) {
        uint256 len = routes.length;
        for (uint256 i = 0; i < len; ) {
            uint256 slice = Part.partToAmountIn(routes[i].part, total);
            _executeHops(routes[i], slice);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Execute hops within a single route
    function _executeHops(Route memory route, uint256 amountIn) internal {
        uint256 hopsLen = route.hops.length;
        uint256 amt = amountIn;
        for (uint256 i = 0; i < hopsLen; ) {
            amt = _dispatchSwap(route.hops[i], amt);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Dispatch swap to the correct protocol
    function _dispatchSwap(
        Hop memory hop,
        uint256 amountIn
    ) internal returns (uint256) {
        if (hop.protocol == 0) {
            return _swapV3(hop.data, amountIn, hop.path);
        } else if (hop.protocol < 8) {
            return _swapV2(hop.data, amountIn, hop.path);
        } else {
            return _swapDodoV2(hop.data, amountIn, hop.path);
        }
    }

    /// @dev Uniswap V3 single-hop exactInputSingle
    function _swapV3(
        bytes memory data,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256 amountOut) {
        (address router, uint24 fee) = abi.decode(data, (address, uint24));
        ISwapRouter(router).exactInputSingle(
            ISwapRouter.ExactInputSingleParams(
                path[0],
                path[1],
                fee,
                address(this),
                block.timestamp + DEADLINE_DELAY,
                amountIn,
                0,
                0
            )
        );
        _approveMax(path[0], router);
    }

    /// @dev Uniswap V2 forked swap
    function _swapV2(
        bytes memory data,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256 amountOut) {
        address router = abi.decode(data, (address));
        _approveMax(path[0], router);
        uint256 minOut = Math.mulDiv(amountIn, SLIPPAGE_NUM, SLIPPAGE_DEN);
        uint256[] memory outs = IUniswapV2Router(router)
            .swapExactTokensForTokens(
                amountIn,
                minOut,
                path,
                address(this),
                block.timestamp + DEADLINE_DELAY
            );
        amountOut = outs[outs.length - 1];
    }

    /// @dev DODO V2 token-to-token swap via proxy
    function _swapDodoV2(
        bytes memory data,
        uint256 amountIn,
        address[] memory path
    ) internal returns (uint256 amountOut) {
        // decode the pool address and proxy
        (address pool, , address proxy) = abi.decode(
            data,
            (address, address, address)
        );

        // approve the proxy
        _approveMax(path[0], proxy);

        // fixed-size memory array literal
        address[1] memory pools = [pool];

        // direction: 0 = base→quote, 1 = quote→base
        uint256 direction = IDODO(pool)._BASE_TOKEN_() == path[0] ? 0 : 1;

        // execute the swap
        amountOut = IDODOProxy(proxy).dodoSwapV2TokenToToken(
            path[0],
            path[1],
            amountIn,
            1,
            pools, // pass in the [pool] array
            direction,
            false,
            block.timestamp + DEADLINE_DELAY
        );
    }

    // Custom errors for gas savings
    error Unauthorized();
    error InsufficientBalance();
}
