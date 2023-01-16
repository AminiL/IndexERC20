// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/IndexERC20Factory.sol";


// Factory and one underlying token
// Goerli
contract IndexERC20FactoryScript is Script {
    address constant c_uniswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address[] s_tokens;
    uint[] s_weights;

    //Goerli addresses
    address constant link = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    function setUp() public {
        s_tokens = [link];
        s_weights = [10**18];
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        IndexERC20Factory deployedFactory = new IndexERC20Factory();
        address index = deployedFactory.newIndex("Test Index", "TIND", s_tokens, s_weights, 1, c_uniswap);
        vm.stopBroadcast();
        console.logAddress(index);
    }
}