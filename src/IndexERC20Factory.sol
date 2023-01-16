// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IndexERC20.sol";

contract IndexERC20Factory is Ownable {
    address[] private s_tokens;

    event IndexERC20Created(address token_address);

    function newIndex(
        string memory name_, 
        string memory sym_, 
        address[] memory erc20_contracts_, 
        uint[] memory weights_, 
        uint commission_,
        address exchanger_) external payable returns(address)
    {
        uint before_create = address(this).balance;
        IndexERC20 index = new IndexERC20(name_, sym_, erc20_contracts_, weights_, commission_, exchanger_);
        uint spend = before_create - address(this).balance;
        require(spend <= msg.value);
        (bool success, ) = payable(msg.sender).call{value: msg.value - spend}("");
        require(success, "cannot send change back");
        s_tokens.push(address(index));
        emit IndexERC20Created(address(index));
        return address(index);
    }

    function getProfit() external onlyOwner {
        for (uint i = 0 ; i < s_tokens.length; i++) {
            IndexERC20(payable(s_tokens[i])).getProfit();
        }
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "cannot send profit to owner");
    }

    receive() external payable {} // from underlying indecies
}