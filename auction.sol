pragma solidity ^0.5.1; 

contract AuctionFactory {
    
    address[] public deployedCampaigns;

    function createCampaign(uint minAmount) public {
        address manager = msg.sender;
        Auction newAuction = new Auction(minAmount, manager);
        deployedCampaigns.push(address(newAuction));
    }
}

contract Auction{
    enum State{inactive, active, completed} 
    State internal status;
    
    struct Product{
        string description;
        uint value;
        address receipient;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    uint internal minContribution;
    address internal manager;
    Product [] internal products;
    uint internal approversCount;
    mapping(address => bool) approvers;

    constructor(uint minimum, address sender) public{
        manager = sender;
        minContribution = minimum;
        status = State.inactive;
    }
    
    function createCampaign(string memory description, uint value, address receipient) public restricted{
        Product memory newProduct = Product({
            description : description,
            value: value,
            receipient: receipient,
            approvalCount: 0
        });
        products.push(newProduct);
    }
    
    modifier restricted(){
        require(msg.sender == manager, "Manager can execute the contract");
        _;
    }
    
    function contribute() public payable{
        require(msg.value > minContribution, "it will only occur if it is more than the min value");
        approvers[msg.sender] = true;
        approversCount++;
    }
    
    function approveRequest(uint index) public{
        Product storage newproduct = products[index];
        require(approvers[msg.sender], "Only approve contributors");
        require(!newproduct.approvals[msg.sender]);
        newproduct.approvals[msg.sender] = true;
        newproduct.approvalCount++;
        status = State.active;
    }
    
    function finalizeRequest(uint index) public restricted{
        Product storage newproduct = products[index];
        require(newproduct.approvalCount > (approversCount/2));
       // product.receipient.transfer(product.value);
        status = State.completed;
    }
    
}