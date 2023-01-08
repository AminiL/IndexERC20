// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./mocks/Token.sol";
import "./mocks/UniswapMock.sol";
import "../src/IndexERC20.sol";

contract IndexERC20Test is Test {
    Token public a_tok;
    Token public b_tok;
    UniswapMock public uniswap_mock;
    uint constant uniswap_balance = 10000000000000000000000000;

    IndexERC20 public index;

    function setUp() public {
        a_tok = new Token("TokenA", "A", 10);
        b_tok = new Token("TokenB", "B", 100);
        uniswap_mock = new UniswapMock();
        address[] memory tokens = new address[](2);
        uint[] memory weights = new uint[](2);
        tokens[0] = address(a_tok);
        weights[0] = uint(100);
        tokens[1] = address(b_tok);
        weights[1] = uint(10);

        for (uint i = 0; i < 2; ++i) {
            Token(tokens[i]).addToken(address(uniswap_mock), uniswap_balance);
        }

        index = new IndexERC20("IndexTestAB", "ITAB", tokens, weights, 10, address(uniswap_mock));
    }

    function buy(uint amount_, address addr_, uint wei_) internal {
        vm.prank(addr_);
        index.buy{value: wei_}(amount_);
    }

    function sell(uint amount_, address addr_) internal {
        vm.prank(addr_);
        index.sell(amount_);
    }

    function testSuccessBuy() public {
        address a1 = address(0x1);
        vm.deal(a1, 2500);
        buy(1, a1, 2300); // 2000(tokens) + 200(commision) and 100 back
        assertTrue(a1.balance == 300, "wrong account balance after buy");
        assertTrue(address(index).balance == 200, "wrong commission");

        uint index_cnt = index.balanceOf(a1);
        assertTrue(index_cnt == 1);
        
        for (uint i = 0; i < index.c_count(); i++) {
            assertTrue(index.s_tokens(i).balanceOf(address(uniswap_mock)) == uniswap_balance - index.s_weights(i) * index_cnt);
            assertTrue(index.s_tokens(i).balanceOf(address(index)) == index.s_weights(i) * index_cnt);
        }
    }

    function testErrorBuy() public {
        address a1 = address(0x1);
        vm.deal(a1, 2000);
        vm.expectRevert(bytes("uniswap mock: not enough wei"));
        buy(1, a1, 2000); // 2000(tokens) + 200(commision) and 100 back
    }

    function testSuccessBuySell() public {
        address a1 = address(0x1);
        vm.deal(a1, 2500);
        buy(1, a1, 2300);

        sell(1, a1);
        assertTrue(a1.balance == 2300);
        assertTrue(index.balanceOf(a1) == 0);
        assertTrue(address(index).balance == 200);

        for (uint i = 0; i < index.c_count(); i++) {
            assertTrue(index.s_tokens(i).balanceOf(address(uniswap_mock)) == uniswap_balance);
            assertTrue(index.s_tokens(i).balanceOf(address(index)) == 0);
        }
    }

    function testErrorSell() public {
        address a1 = address(0x1);
        vm.deal(a1, 2500);
        buy(1, a1, 2300);

        vm.expectRevert("not enough tokens on balance");
        sell(2, a1);
    }

    function testProfit() public {
        address a1 = address(0x1);
        vm.deal(a1, 2500);
        buy(1, a1, 2300);
        
        uint balanceBefore = address(index.owner()).balance;
        index.getProfit();
        assertTrue(address(index.owner()).balance - balanceBefore == 200);
    }

    receive() external payable {} // for getProfit
}