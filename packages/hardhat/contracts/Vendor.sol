pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  //Errors
  error Vendor__BalanceIsZero();

  // Events
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);
  
  // Variables 
  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:

  function buyTokens() payable external {
    yourToken.transfer(msg.sender, tokensPerEth*msg.value);
    emit BuyTokens(msg.sender, msg.value, tokensPerEth*msg.value); 
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

  function withdraw() onlyOwner() external {
    uint256 balance = address(this).balance;
    if (balance <=0){
      revert Vendor__BalanceIsZero();
    }

    (bool success,)=owner().call{value:balance}("");
    require(success,"Vendor: Withdraw failed");
  }

  // ToDo: create a sellTokens(uint256 _amount) function:

  function sellTokens(uint256 _amount) public {

    require (yourToken.balanceOf(msg.sender)>0,"Vendor: Your balance of tokens <=0");
    require(_amount>0,"Vendor: Selling amount equals 0");
    
  
    bool sent=yourToken.transferFrom(msg.sender,address(this), _amount);
    require (sent,"Vendor: Tokens not recieved");

    uint256 ethAmount = _amount / tokensPerEth;
    require(address(this).balance >= ethAmount, "Vendor: Insufficient ETH balance in Vendor");

    (bool success,)=msg.sender.call{value:ethAmount}("");
    require(success,"Vendor: Selling failed");

    emit SellTokens(msg.sender, _amount, ethAmount);
  }
}
