pragma solidity ^0.5.0;

contract Bank{
    
    address public owner;                            // address of the person who deploys the contract
    mapping (address => uint256) public balanceOf;   // map the address to the balance   
    uint userCount;                                  // it will count the number of the users
    
    constructor() payable public {
        require(msg.value >= 3 ether, "The value must be greater than 6 ethers");
        owner = msg.sender;
    }
    
    function enroll() public returns (uint) {
        if (userCount < 3) {
            userCount++;
            balanceOf[msg.sender] = 1 ether;
        }
        return balanceOf[msg.sender];
    }
    
    function deposit() public payable returns(uint){
        balanceOf[msg.sender] += msg.value;
        return balanceOf[msg.sender];
    }
    
    modifier restricted(){
        require(msg.sender == owner, "The address of the owner of the bank");
        _;
    }
    
    function withdraw(uint amount) public {
        require(balanceOf[msg.sender] >= amount, "the balance in account should be more than amount");
        balanceOf[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
    
    function balance() public view returns(uint){
        return balanceOf[msg.sender];
    }
    
    function bankBalance() public view restricted returns(uint){
        return address(this).balance;
    }
    
    function purge() public restricted{
        msg.sender.transfer(address(this).balance);
    }
    
}