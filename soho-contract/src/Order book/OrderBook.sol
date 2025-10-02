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

   function matchOrder(uint256 takerOrderId, uint256 calldata[] makerOrdersIds) external{
    Order storage taker = orders[takerOrderId];
    if(taker.status!=OrderStatus.Active,OrderBook_OrderStatusNotActive());
    if(taker.expiry<0||taker.expiry<=block.timestamp,OrderBook_TakerExpired());
    if(taker.remainingIn<=0&&taker.remainingOut<=0,OrderBook_TakerEmpty());



    for (uint256 i=0;i<makerIds.length&&taker.remainingIn>0,i++)}{
        uint256 mid =makerOrderId[i];
        Order storage maker=orders[mid];
    }

    //Skip Invalid Maker
    if(maker.status!=Order.Active){
        continue;
    }
    if(maker.expiry!=0 &&maker.expiry<=block.timestamp){
        continue;
    }

            // tokens must mirror: maker.tokenIn == taker.tokenOut && maker.tokenOut == taker.tokenIn
            if(!(maker.tokenIn==taker.tokenOut&&maker.tokenOut==taker.tokenIn)){
        continue;
            }

  // compute matchable amount (in terms of maker.tokenIn and taker.tokenIn)
            // We operate by tokenIn units of each order. To match proportionally by price
            // we use remainingIn/remainingOut ratio. Simpler approach: treat amounts as exact pairwise.
            //
            // We'll compute how much of maker.tokenIn we can take, constrained by:
            // - maker.remainingIn
            // - taker.remainingOut * (maker.amountIn / maker.amountOut) ??? To avoid float math,
            // we will convert via cross multiplication to figure makerBuyable = min(maker.remainingIn, taker.remainingOut * maker.amountIn / maker.amountOut)
            //
            // Safer approach: treat amounts as "maker sells A for B" and taker sells B for A. So
            // maker.remainingIn is amount A available, maker.remainingOut is amount B expected.
            // taker.remainingIn is amount B available, taker.remainingOut is amount A expected.
            //
            // So the maximum makerIn we can take is min(maker.remainingIn, taker.remainingOut)
            // because taker.remainingOut is amount of A taker wants to receive.
            //
            // Similarly the maximum takerIn we can take is min(taker.remainingIn, maker.remainingOut).
            //
            // We'll match `filledA = min(maker.remainingIn, taker.remainingOut)` (A = maker.tokenIn)
            // and `filledB = min(taker.remainingIn, maker.remainingOut)` (B = maker.tokenOut).
            //
            // The actual fill must satisfy price; to keep consistency we take the minimum equivalent
            // by cross-checking proportionality using maker.amountIn/maker.amountOut ratio.
            //
            // For MVP we approximate by requiring exact price ratios in orders (i.e., maker.amountIn * taker.amountIn == maker.amountOut * taker.amountOut)
            // and leave more complex price-crossing for advanced versions.

            // Basic price-check (enforce exact ratio equality)


            if(maker.tokenIn*taker.tokenIn&&maker.tokenOut*taker.tokenOut){continue;}


    

    /// -----------------------------
    /// View helpers
    /// -----------------------------
    function getOrders(uint256 orderId) external view returns(order memory){
        returns orders[orderId];

    }
}



    