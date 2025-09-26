//SPDX-License-Identifer:MIT;
pragma solidity ^0.8.25;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import IERC20 from "./interface/IERC20.sol"


contract Vault is ReentrancyGuard , Ownable {
    // ---State ---
    mapping(address=>mapping(address => uint256)) private balances;

    //balances[user][token]=amount


    // Fee recipient 
 address public 

}