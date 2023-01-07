// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface Priceable {
    function getPriceInWei() external view returns(uint);
}

abstract contract Token is ERC20, Priceable {
    uint internal PRICE;
    function getPriceInWei() external view returns(uint) {
        return PRICE;
    }

    function addToken(address addr, uint amount) public {
        _mint(addr, amount);
    }

    function removeToken(address addr, uint amount) public {
        require(balanceOf(addr) >= amount);
        _burn(addr, amount);
    }
}

contract TokenA is Token {
    constructor() ERC20("TokenA", "A") {
        PRICE = 10;
    }
}

contract TokenB is Token {
    constructor() ERC20("TokenB", "B") {
        PRICE = 100;
    }
}
