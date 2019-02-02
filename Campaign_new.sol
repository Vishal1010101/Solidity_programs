pragma solidity ^0.5.0;

contract CampaignFactory{
    
    address[] public deployedcontract;
    event Deployedcontract(address ad);
    
    function createnewContract(uint value) public{
        Campaign myCampaign = new Campaign(value);
        deployedcontract.push(address(myCampaign));
        emit Deployedcontract(address(myCampaign));
    }
}

contract Campaign{
    
    enum CampaignState{running, cancelled, ended}  // defines various states of campaign
    CampaignState public state;                    // the state variable of the product  
        
    struct Product{
        uint value;                   // value of a specific product
        string description;           // description of a specific product
        bool status;                  // track the status of the product
        address payable vendor;       // address of receipient
    }
    
    uint public targetValue;         // the target value or the pledged value for the product
    address public owner;            // address of the deployer of the contract
    Product[] public allProducts;    // list of all products here
    mapping(address => uint) balanceOf;
    mapping(uint => Product) products;
    
    constructor(uint value) public{
        targetValue = value;
        state = CampaignState.running;
        owner = msg.sender;
    }
    
    function createCampaign(uint _value, string memory _description, address payable _vendor) public{
        Product memory newProduct = Product({
            value: _value,
            description : _description,
            status: false,
            vendor : _vendor
        });
        allProducts.push(newProduct);
    }
    
    modifier restricted(){
        require(msg.sender == owner, "Only Owner can execute");
        _;
    }
    
    function pledge()  public payable{
        require(msg.value > 0 ether);
        balanceOf[msg.sender] += msg.value;
    }
    
    function buyProduct(uint index) public restricted returns(bool){
        if(index >=0 && index >= allProducts.length)
        require(targetValue < address(this).balance, "checking the balance");
         // allProducts.vendor.transfer(targetValue);
        Product storage p = products[index];
        require(p.value < targetValue);
        uint amount = p.value;
        p.vendor.transfer(amount);
        amount = 0;
        return true;
    
    }
    
    function closeCampaign() public restricted{
        require(address(this).balance >= targetValue , "target achieved");
        state = CampaignState.cancelled;
    }
}