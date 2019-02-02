pragma solidity ^0.5.0; 

contract CampaignFactory {
    
    address[] public deployedCampaigns;

    function createCampaign(uint minAmount) public {
        address manager = msg.sender;
        Campaign newCampaign = new Campaign(minAmount, manager);
        deployedCampaigns.push(address(newCampaign));
    }

}

contract Campaign{
    
    enum State{inactive, active, completed} 
    State public status;
    
    struct Product{
        string description;
        uint value;
        address receipient;
        mapping(address => bool) approvals;
        uint approvalCount;
    }
    
    uint public minContribution;
    address public manager;
    Product [] public products;
    mapping(address => bool) approvals;
    uint public contributorsCount;

    constructor(uint minimum, address sender) public{
        manager = sender;
        minContribution = minimum;
        status = State.inactive;
    }
    
    function createCampaign(string memory description, uint value, address receipient) public restricted{
        Product memory newProduct = Product({
            description : description,
            value: value,
            receipient: receipient
        });
        products.push(newProduct);
    }
    
    modifier restricted(){
        require(msg.sender == manager, "Manager can execute the contract");
        _;
    }
    
    function contribute(){
        require(msg.value > minValue, "it will only occur if it is more than the min value");
        require(status = State.active, "the state is currently active");
        approvers[msg.sender] = true;
        contributorsCount++;
    }
    
    function approveRequest(uint index) public{
        require(approvers[msg.sender], "Only approve contributors");
        
        Product storage newPro = products[index];
        require(products.approvals[msg.sender], "the owner of the products can only update");
        status = State.active;
    }
    
    
    
}