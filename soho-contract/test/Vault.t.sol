// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import"../src/Vault/Vault.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";



contract MockToken is ERC20{

    // ek ERC20 token se test karke dekhte hai ...workflow
   constructor() ERC20("MockToken","MITK"){
    _mint(msg.sender,1_000_000 ether);
   } 
}

contract VaultTest is Test{
    vault vault;
    MockToken token;
    address user= address(1);
    address feeRecipient = address(2);



    function setUp()  public {
        vault = new Vault(feeRecipient,50);
        token = new MockToken();
        vm.startPrank(user);
        token.approve(address(vault),type(uint256).max);
        vm.stopPrank();

    }

    // Unit Testing 
    // Deposit Test
    function testDeposit() public{
       vm.startPrank(user);
       vault.deposit(address(token),100 ether);
       vm.stopPrank(); 


       uint256 balance = vault.getBalance(user,address(token));
       assert(balance,100 ether,"Balance Should be 100");

    }


    // Withdraw Test
    function Withdraw() public{
        vm.startPrank(user);
        vault.deposit(address(token),100 ether);
        vault.withdraw(address(token),50 ether);

        uint256 balance= vault.getBalance(user,address(token));
        assert(balance,50 ether,"balance should be 50 eth");
            }

            function testWithdrawMoreThanBalanceshouldFail()public{
                vm.startPrank(user);
                vault.deposit(address(token),10 ether);
                vm.expectRevert()
                vault.withdraw(address(token),20 ether);
                vm.stopPrank();
            }
 





 // Fuzz test
 function testFuzzDeposit(uint256)public{
    vm.assume(amount > 0 && amount < 1_000_000 ether);

    vm.startPrank(user);
    vault.deposit(address(token),amount);
    vm.stopPrank();

    assert(vault.getBalance(user,address(token)),amount);

 }


 // Events Tests
 function testDepositEmitsEvent() public{
    vm.startPrank(user);
    vm.expectEmit(true,true,false,true)
    emit Vault.Deposit(user,address(token),100 ether);


    vault.deposit(address(token),100 ether);
    vm.stopPrank();
 }


 // Admin function test
 function testOnlyOwnerCanSetFeeRecipient()pubic{
    vm.startPrank();
    vm.expectRevert();
    vault.setFeeRecipient(address(5));


    vault.setFeeRecipient(address(10));
    vm.stopPrank();
 }


 // Scurity Test
 function testDepositZeroShouldFail() public{
    vm.startPrank();
    vm.expectRevert();
    vault.deposit(address(token),0);
    vm.stopPrank();

 }

 //Property Test
 function invariant_TotalBalnceMatches()public{
    uint256 bal = vault.getBalance(user,address(token));
    assertGe(bal,0);
    
 }
}



