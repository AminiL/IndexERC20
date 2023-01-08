// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

contract IndexERC20 is ERC20, Ownable {
    uint public immutable c_count;
    IERC20[] public s_tokens;
    uint[] public s_weights;
    
    address public immutable c_exchanger; //= 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // uniswap v2
    uint public immutable c_commission; // % from buy

    constructor(
        string memory name_, 
        string memory sym_, 
        address[] memory erc20_contracts_, 
        uint[] memory weights_, 
        uint commission_,
        address exchanger_) payable
    ERC20(name_, sym_)
    {
        require(commission_ >= 0 && commission_ < 100, "must be a percent");
        c_count = erc20_contracts_.length;
        require(c_count == weights_.length, "different sizes of weights and tokens");
        s_weights = weights_;
        c_commission = commission_;
        c_exchanger = exchanger_;
        for (uint i = 0; i < c_count; i++) {
            require(s_weights[i] > 0, "zero weight");
            s_tokens.push(IERC20(erc20_contracts_[i]));
        }
    }

    function buyToken(IERC20 token_, uint token_amount_, uint wei_amount_) internal virtual {
        require(wei_amount_ <= msg.value, "do not have such amount of wei");
        IUniswapV2Router01 uniswapRouter = IUniswapV2Router01(c_exchanger);

        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = address(token_);

        uniswapRouter.swapETHForExactTokens{ value: wei_amount_ }(token_amount_, path, address(this), block.timestamp);
    }

    function sellToken(IERC20 token_, uint amount_, address reciept_) internal virtual {
        IUniswapV2Router01 uniswapRouter = IUniswapV2Router01(c_exchanger);

        address[] memory path = new address[](2);
        path[0] = address(token_);
        path[1] = uniswapRouter.WETH();
        token_.approve(c_exchanger, amount_);
        uniswapRouter.swapExactTokensForETH(amount_, 0, path, reciept_, block.timestamp);
    }

    function buy(uint amount_) external payable {
        uint balance_after_tx = address(this).balance;
        uint spend_max = (msg.value * 100) / (100 + c_commission);
        uint spend = 0;
        for (uint i = 0; i < c_count; i++) {
            require(spend <= spend_max, "not enough wei provided");
            buyToken(s_tokens[i], amount_ * s_weights[i], spend_max - spend);
            spend = balance_after_tx - address(this).balance;
        }
        _mint(msg.sender, amount_);
        require(spend * (100 + c_commission) / 100 <= msg.value, "not enough wei provided for commision");
        (bool success, ) = payable(msg.sender).call{value: msg.value - spend * (100 + c_commission) / 100}("");
        require(success, "cannot send change back");
    }

    function sell(uint amount_) external {
        require(balanceOf(msg.sender) >= amount_, "not enough tokens on balance");
        for (uint i = 0; i < c_count; i++) {
            sellToken(s_tokens[i], amount_ * s_weights[i], msg.sender);
        }
        _burn(msg.sender, amount_);
    }

    function getProfit() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "cannot send profit to owner");
    }
    receive() external payable {}
}