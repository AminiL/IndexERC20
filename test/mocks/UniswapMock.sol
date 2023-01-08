// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./Token.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

contract UniswapMock is IUniswapV2Router01 {

    constructor () {}

    function tokenToEth(address token_, uint amount_, address to_) internal {
        Token t = Token(token_);
        uint w = t.getPriceInWei() * amount_;
        t.transferFrom(msg.sender, address(this), amount_);

        (bool success, ) = payable(to_).call{value: w}("");
        require(success, "tokenToEth failed");
    }

    function ethToToken(address token_, uint amount_, uint wei_, address to_) internal {
        Token t = Token(address(token_));
        require(wei_ >= t.getPriceInWei() * amount_, "uniswap mock: not enough wei");
        uint ret = wei_ - t.getPriceInWei() * amount_;
        t.transfer(to_, amount_);
        (bool success, ) = payable(msg.sender).call{value: ret}("");
        require(success, "ethToToken failed");
    }

    function swapExactTokensForETH(uint amountIn, uint, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        returns (uint[] memory amounts)
    {
        amounts = new uint[](1); // for removing warnings
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        tokenToEth(path[0], amountIn, to);
    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) 
        external
        virtual
        override
        payable
        returns (uint[] memory amounts)
    {
        amounts = new uint[](1); // for removing warnings
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        ethToToken(path[1], amountOut, msg.value, to);
    }


    ////////////////////


    function factory() external pure override returns (address) {}
    function WETH() external pure override returns (address) {}
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB, uint liquidity) {}
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable override returns (uint amountToken, uint amountETH, uint liquidity) {}
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB) {}
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external override returns (uint amountToken, uint amountETH) {}
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external override returns (uint amountA, uint amountB) {}
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external override returns (uint amountToken, uint amountETH) {}
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts) {}
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts) {}
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        override
        returns (uint[] memory amounts) {}
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        override
        returns (uint[] memory amounts) {}
    function quote(uint amountA, uint reserveA, uint reserveB) external pure override returns (uint amountB) {}
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure override returns (uint amountOut) {}
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure override returns (uint amountIn) {}
    function getAmountsOut(uint amountIn, address[] calldata path) external view override returns (uint[] memory amounts) {}
    function getAmountsIn(uint amountOut, address[] calldata path) external view override returns (uint[] memory amounts) {}
}