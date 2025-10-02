//SPDX-License-Identifer:MIT;
pragma solidity ^0.8.25;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {IERC20} from "./interface/IERC20.sol";


contract Vault is ReentrancyGuard , Ownable {

/**Errors  */
error Vault_InsufficientBalance();
error Vault_TransferFailed();
error Vault_Max10PercentFee();





    // ---State ---
    mapping(address=>mapping(address => uint256)) public balances;

    //balances[user][token]=amount


    // Fee recipient 
 address public feeRecipient;
 uint256 public feeBasisPoints=30; //0.3% fee

 // ---Events ---
 event Deposit(address indexed user, address indexed token , uint256 amount);
 event Withdraw(address indexed user, address indexed token , uint256 amount);



 // --- Constructor---
 constructor(address _feeRecipient){
    feeRecipient = _feeRecipient; 
 }


/**
 * @notice Allows users to deposit ERC20 tokens into the Vault to participate in trading.
 * @dev User must approve the Vault contract to spend their tokens first.
 * @param _token The ERC20 token contract address to deposit.
 * @param _amount The number of tokens to deposit.
 */

function deposit(address token , uint256 amount ) external nonReentrancy {
    require(amount>0,Vault_InsufficientBalance());


    //Transfer Token from user to Vault
    bool success = IERC20(token).transferFrom(msg.sender,address(this),amount);
    require(success,Vault_TransferFailed());

    //Update interal balance
    balances[msg.sender][token]+=amount;

    emit Deposit(msg.sender,token,amount);




    /**
 * @notice Allows users to withdraw ERC20 tokens from their Vault balance.
 * @dev Prevents reentrancy attacks by updating balance before transfer.
 * @param _token The ERC20 token contract address to withdraw.
 * @param _amount The number of tokens to withdraw.
 */

    function withdraw(address token, uint256 amount)external nonReentrant{
        require(amount>0,Vault_InsufficientBalance());
        require(balances[msg.sender][token]>=amount,Vault_InsufficientBalance());
        // Update internal balance first(prevents reentrancy)
        balances[msg.sender][token]-=amount;


        //Transfer token back to user
        bool  success=IERC20(token).transfer(msg.sender,amount);
        require(success,Vault_TransferFailed());

        emit Withdraw(msg.sender,token,amount);
    }

   /**
 * @notice Returns the Vault balance of a user for a given token.
 * @param _user The user wallet address.
 * @param _token The ERC20 token contract address.
 * @return The amount of tokens the user has in the Vault.
 */
    function getBalance(address user , address token) external view returns(uint256){
        return balances[user][token];
    }

   
/**
 * @notice Sets the fee recipient address for trading fees.
 * @dev Only callable by the contract owner.
 * @param _feeRecipient The new fee recipient address.
 */
    function setFeeRecipient(addresss _feeRecipient)external onlyOwner{
        feeRecipient=_feeRecipient;

    }

    /**
 * @notice Sets the trading fee in basis points.
 * @dev Only callable by the contract owner. Max 1000 bps (10%).
 * @param _feeBasisPoints The new fee amount in basis points.
 */

    function setFeeBasisPoints(uint256 _feeBasisPoints) external onlyOwner{
    }require(_feeBasisPoints <=1000,Vault_Max10PercentFee());
    feeBasisPOints=_feeBasisPoints;


     function _transferTo(address from , address to , address amount , uint256) external onlyOwnable
     {
         require(balances[from][token] >= amount,Vault_InsufficientBalance());
        require(to != address(0),Vault_ZeroAddress());

        balances[from][token] -= amount;
        balances[to][token] += amount
     }



}



