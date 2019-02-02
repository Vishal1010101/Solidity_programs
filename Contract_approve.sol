pragma solidity ^0.5.0; 

contract CampaignFactory {
    
    address[] public deployedCampaigns;
    event ContractDeployed(address at);
    
    function createCampaign(uint minAmount) public {
        address manager = msg.sender;
        Campaign newCampaign = new Campaign(minAmount, manager);
        deployedCampaigns.push(address(newCampaign));
        emit ContractDeployed((address(newCampaign)));
    }
}

contract Campaign{
    
    enum State{inactive, active, completed} 
    State public status;
    
    struct Product{
        string description;  // description of the product
        uint value;         // the value of the product
        address receipient;
        mapping(address => bool) approvals; // Set of approval for the product
        uint approvalCount;     // no of approved 
    }
    
    uint public minContribution;
    address public manager;      // campaign deployer address
    Product [] public products;  // list of products 
    mapping(address => bool) approvals;  // set of approvals for the request
    uint public contributorsCount;    // the number of contributors

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
    
    function contribute() public payable{
        require(msg.value > minContribution, "investment should be more than the minimum value");
        require(status ==State.active, "the state is currently active");
        approvals[msg.sender] = true;
        contributorsCount++;
    }
    
    function approveRequest(uint index) public restricted{
        require(approvals[msg.sender], "Only approve contributors");
        
        Product storage newPro = products[index];
        status = State.active;
        products.approvals[msg.sender] = true;
        products.approvalCount++;
    }
    
    function finalizeRequest(uint index) public restricted{
        Product storage newPro = products[index];
        require(2* products.approvalCount > contributorsCount, "Consensus Approval");
        status = State.completed;
         
         products.recipient.transfer(products.value);
    }
}
