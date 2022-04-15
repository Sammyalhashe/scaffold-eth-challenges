// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  // in withdraw state?
  bool public openForWithdraw = false;
  // mapping of balances
  mapping (address => uint256) public balances;
  // theshold definition
  uint256 public constant threshold = 1 ether;
  // deadline definition
  uint256 public deadline = block.timestamp + 30 seconds;
  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  event Stake(address from, uint256 amount);
  function stake(address add, uint256 amount) public payable {
    console.log("in stake");
    balances[add] += amount;
    emit Stake(add, amount);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public {
    if (timeLeft() == 0) {
        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        }
        else {
            openForWithdraw = true;
        }
    }
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw(address add) public returns (uint256) {
    uint256 amt = balances[add];
    balances[add] = 0;
    return amt;
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint) {
    if (deadline <= block.timestamp) {
        return 0;
    }
    // number of days between deadline.
    uint256 left = deadline - block.timestamp;
    return left;
  }


  // Add the `receive()` special function that receives eth and calls stake()
  function recieve(address add, uint256 amount) public {

  }

}
