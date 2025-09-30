//SPDX-License-Identifier:MIT;

pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//@notice A ERC20 based minting and Burning Token 
contract MockToken is ERC20 , Ownable {

    constructor(
        string memory_name,
        string memory_symbol_
    )ERC20(name_, symbol_) Ownable(msg.sender)
    _mint(msg.sender, 1_000_000 ether);

    
//@notice A ERC20 based token minting 
//@dev A only Owner based access
//@params Token would be minted on  given address
@params Only the required amount of token would be minted
    function mint(address to , uint256 amount)  external onlyOwnable{
        _mint(to,amount );

    }
}
