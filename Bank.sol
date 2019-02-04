pragma solidity ^0.5.0;

contract Bank{
    
    struct Enrollment{
        string name;
        address beneficiary;
    }
    
    address public owner;
    Enrollment[] public allEnrollers;
    uint256 value;
    mapping (address => uint256) balanceOf;
    
    constructor(uint _value) public payable{
        require(msg.value >= 6 ether, "The value must be greater than 6 ethers");
        value = _value;
    }
    
    function enroll(string memory _name, address _beneficiary) public{
        Enrollment memory newEnroll = Enrollment({
           name : _name,
           beneficiary: _beneficiary
        });
        allEnrollers.push(newEnroll);
    }
    
    function deposit() public payable returns(uint256){
        balanceOf[msg.sender] += msg.value;
        return balanceOf[msg.sender];
    }
    
    modifier restricted(){
        require(msg.sender == owner, "The address of the owner of the bank");
        _;
    }
    
    function withdraw(uint amount) public{
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
    
    function reward() public{
        uint i;
        for(i=0; i<3; i++){
            if(allEnrollers[i].beneficiary == msg.sender){
                msg.sender.transfer(2 ether);
            }
        }
    }
    
    
}