// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/IndexERC20.sol";

contract IndexERC20Script is Script {
    address constant c_uniswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address[] s_tokens;
    uint[] s_weights;

    address constant chainlink = 0x514910771AF9Ca656af840dff83E8264EcF986CA; // 6$
    address constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // 1$
    address constant wbtc = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599; // 16000$ 

    function setUp() public {
        s_tokens = [dai, chainlink, wbtc];

        // [100$, 200$, 500$]
        uint dai_weight = (10**ERC20(dai).decimals()) * 100;
        uint chain_weight = (10**ERC20(chainlink).decimals()) * 200 / 6;
        uint wbtc_weight = (10**ERC20(wbtc).decimals()) * 500 / 16000;
        s_weights = [dai_weight, chain_weight, wbtc_weight];
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("CREATOR_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new IndexERC20("Test Index", "TIND", s_tokens, s_weights, 10, c_uniswap);
        vm.stopBroadcast();
    }
}