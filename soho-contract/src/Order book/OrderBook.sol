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


    /// -----------------------------
    /// State
    /// -----------------------------
    Ivault public immutable vault;
    address public owner;
    uint256 public feeBps;


   
    /// -----------------------------
    /// Order Storage
    /// -----------------------------
    uint256 public nextOrderId=1;
    mapping (uint256=>Order) public orders;


 
    /// -----------------------------
    /// Constructor
    /// -----------------------------

constructor(address _vault , uint256 _feeBps){
    if(_vault==address(0),OrderBook_ZeroVaultOrderBook());
    if(_feeBps>1000,OrderBook_FeeTooHigh());
    vault=Ivault(_vault);
    msg.sender(owner);
    feeBps=_feeBps;
}




   
    /// -----------------------------
    /// Modifier
    /// -----------------------------
modifier onlyOwner(){
    if(msg.sender!=owner,OrderBook_OnlyOwner());
    _;
}


   //Admin
function setFeeBps(uint256 _b)external onlyOwner{
    if(_b>1000,FeeBpsOnly10Percent());
    feeBps=_b;
}

function transferOwnerShip(address _new) onlyOwner[
    if(_new==address(0),OrderBook_ZeroAddress());
    owner=_new;

]



 /// -----------------------------
    /// Order lifecycle
    /// -----------------------------



 /**
     * @notice Create an order on-chain. The user must already have deposited tokenIn into Vault.
     * @param tokenIn Token the owner is selling.
     * @param tokenOut Token the owner wants to receive.
     * @param amountIn Amount of tokenIn owner is selling.
     * @param amountOut Amount of tokenOut owner expects.
     * @param expiry Timestamp after which order is invalid.
     * @return orderId newly created order id
     */
   function createOrder(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    uint256 amountOut,
    uint256 expiry
   ) external return(uint256 orderId){
if(amountIn<=0&&amountOut<=0,OrderBook_ZeroAmount());
if(tokenIn==tokenOutc,SameToken());
if(expiry!=0||expiry<=block.timestamp,OrderBook_InvalidExpiry());


// Ensuring user has deposited enough in Vault
uint256 bal=vault.balances(msg.sender, tokenIn);
 if(bal==amountIn,OrderBook_InsufficientAmount());


 orderId=nextOrder++;
 orders[orderId]=Order({
    owner=msg.sender;
    tokenIn=tokenIn;
    tokenOut=tokenOut;
    amountIn=amountIn;
    amountOut=amountOut;
    remainingIn=amountIn;
    remainingOut=amountOut;
    expiry=expiry;
    status = Orderstatus.Active;
 });

 emit OrderCreated(orderId, msg.sender, tokenIn,tokenOut,amountIn,amountOut,expiry);

   };




    /**
     * @notice Cancel an active order (owner only). Remaining funds become withdrawable from Vault.
     * @param orderId id of order to cancel
     */

   function cancelOrder(uint256 orderId)external{
    Order storage 0=orders[orderId];
    if(o.owner!=msg.sender,OrderBook_NotOwner());
    if(o.status!OrderStatus.Active,OrderBook_StatusNotActive())
    o.status=OrderStatus.Cancelled;


    emit OrderCancelled(orderId,msg.sender);
   }



   
    /// -----------------------------
    /// Matching / Settlement
    /// -----------------------------
    /**
     * @notice Match a taker order against one or more maker orders provided by caller.
     * @dev Caller (engine/relayer/taker) supplies `makerOrderIds` in order of matching priority.
     * Partial fills supported. All settlement is done via Vault internal transfer calls.
     *
     * Requirements:
     * - takerOrder and makerOrders must be active and not expired.
     * - token sides must mirror appropriately (maker.tokenIn == taker.tokenOut, etc).
     *
     * @param takerOrderId The id of the taker order (must be Active).
     * @param makerOrderIds Array of maker order ids to match against sequentially.
     */ 

   function OrderMatched() external;
}