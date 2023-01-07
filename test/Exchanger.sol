// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./Token.sol";

contract Exchanger {
    function TokenToEth(ERC20 tok, uint cnt) public {
        Token t = Token(address(tok));
        uint w = t.getPriceInWei() * cnt;
        t.removeToken(msg.sender, cnt);
        payable(msg.sender).transfer(w);
    }

    function EthToToken(ERC20 tok, uint cnt, uint ethwei) public payable {
        Token t = Token(address(tok));
        require(ethwei >= t.getPriceInWei() * cnt, "not enough wei");
        uint ret = ethwei - t.getPriceInWei() * cnt;
        t.addToken(msg.sender, cnt);
        payable(msg.sender).transfer(ret);
    }
}