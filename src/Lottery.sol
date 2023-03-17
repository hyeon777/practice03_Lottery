// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lottery{

    address public owner;
    mapping(address => uint) public ledger;
    uint256 public total_amount;
    uint16 public winningNum;
    uint[] public num_list;
    uint public blocktime;
    uint public claim_time = block.timestamp + 24 hours;
    bool claim_check = false;
    bool public duplicate_check = true;
    uint256 payout;
    constructor () {
        owner = msg.sender;
    }

    function buy(uint num) public payable { 
        require(msg.value == 0.1 ether);
        require(block.timestamp < blocktime + 24 hours);
        //blocktime = block.timestamp;
        for(uint a=0; a<num_list.length; a++){
            if(num == num_list[a]){
                duplicate_check = false;
            }
        }
        if(block.timestamp >= blocktime + 24 hours -1){
            duplicate_check = true;
        }
        require(duplicate_check == true);
        num_list.push(num);
        ledger[msg.sender] =  num;

        blocktime = block.timestamp;
        payout = msg.value;
        total_amount += payout;
        
    }

    function draw() public returns (bool) {
        require(msg.sender == owner);
        require(block.timestamp >= blocktime + 24 hours);
        require(claim_check == false);
        uint randNonce = 0;
        uint16 random_num = uint16(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)))) % 100;
        randNonce++;
        winningNum = random_num;
    }

    function claim() public {
        claim_check = true;
        //claim_time = block.timestamp;
        require(block.timestamp >= blocktime + 24 hours);
        if(ledger[msg.sender] == winningNum){
            payable(msg.sender).call{value: total_amount}("");
            total_amount = 0;
        }
    }

    function winningNumber() public returns (uint16) {
        return winningNum;
    }
    receive() external payable {
    }

}