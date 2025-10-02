//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IVault{
    function _transferFromTo(address From , address to , uint256 amount) external;
    function balances(address user, address token) external view returns(uint256);

}


contract Orderbook is {

    // Events
    event OrderCreated(uint256 indexed orderd, address indexed owner, address tokenIn, address tokenOut, uint256 tokenIn, uint256 tokenOut, uint256 expiry);
    event OrderCancelled(uint256 indexed orderId, address indexed owner);
    event OrderMatched(
        uint256 takerOrderId;
        uint256 makerOrderId; 
        address maker,
        address taker,
        address tokenIn,
        address tokenOut,
        uint256 makerFilled,
        uint256 takerFilled,
        uint256 fee;
    );


    // Types 
    enum OrderStatus{Active , Cancelled, Filled}

    struct Order{
        address owner;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        uint256 remainingIn;
        uint256 remainingOut;
        uint256 expiry;
        OrderStatus status;
    }

    // States
    Ivault public immutable vault;
    


}