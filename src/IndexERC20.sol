// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// library IndexNaming {
//     function createName(string memory pref, address[] memory erc20_contracts_) public view returns(string memory) {
//         string memory res = pref;
//         for (uint i = 0; i < erc20_contracts_.length; i++) {
//             res = string.concat(res, "_");
//             res = string.concat(res, ERC20(erc20_contracts_[i]).symbol());
//         }
//         return res;
//     }
// }

contract IndexERC20 is ERC20, Ownable {
    uint public immutable _count;
    ERC20[] public _tokens;
    uint[] public _weights;

    function createName(string memory pref, address[] memory erc20_contracts_) internal virtual view returns(string memory) {
        string memory res = pref;
        for (uint i = 0; i < erc20_contracts_.length; i++) {
            res = string.concat(res, "_");
            res = string.concat(res, IERC20Metadata(erc20_contracts_[i]).symbol());
        }
        return res;
    }

    function createSymbol(string memory /*pref*/, address[] memory /*erc20_contracts_*/) internal virtual view returns(string memory) {
        return "ERC20IND";
    }

    constructor(address[] memory erc20_contracts_, uint[] memory weights_) payable
    ERC20(createName("IND", erc20_contracts_), createSymbol("", erc20_contracts_))
    {
        _count = erc20_contracts_.length;
        require(_count == weights_.length, "different sizes of weights and tokens");
        _weights = weights_;
        for (uint i = 0; i < _count; i++) {
            require(_weights[i] > 0, "zero weight");
        }
    }

    function buyToken(ERC20 token, uint amount) internal virtual {
        address UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        //uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }

    function sellToken(ERC20 token, uint amount, address reciept) internal virtual {

    }



}