pragma solidity ^0.5.1;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20Interface {
    uint256 public totalSupply; 
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _tokenOwner, address indexed _spender, uint _value);
}

contract MyToken is ERC20Interface{
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    string public name;           // name of the token 
    string public symbol;         // symbol of the token
    uint256 public decimals;         // conversions from wei to ether 
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    
    constructor(uint256 _initialSupply, string memory _name,string memory _symbol, uint256 _decimals) public{
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    
       function balanceOf(address _owner) public view returns (uint256 balance){
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns(bool success){
        require(balances[msg.sender] >= _value, "the balance should be more than what we send to the sender");
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender , _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success){
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value,"the balance of the account should be more than the actual value to send" );
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }  
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return allowed[_owner][_spender];
    }
    
}

contract Configurable {
    uint256 public constant cap = 1000000*10**18;
    uint256 public constant basePrice = 100*10**18; // tokens per 1 ether
    uint256 public tokensSold = 0;
    
    uint256 public constant tokenReserve = 1000000*10**18;
    uint256 public remainingTokens = 0;
}

contract CrowdSaleToken is ERC20Interface,Configurable, MyToken{
    
    enum Stages {preSale, duringSale, endSale}
    Stages currentStage;
    address public owner;
    using SafeMath for uint256;
    
    constructor() public {
        currentStage = Stages.preSale;
        emit Transfer(address(this), owner, tokenReserve);
    }
    
    function buytoken() public payable {
        require(currentStage == Stages.preSale);
        require(msg.value > 0);
        require(remainingTokens > 0);
        
        
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(basePrice).div(1 ether);
        uint256 returnWei = 0;
        
        if(tokensSold.add(tokens) > cap){
            uint256 newTokens = cap.sub(tokensSold);
            uint256 newWei = newTokens.div(basePrice).mul(1 ether);
            returnWei = weiAmount.sub(newWei);
            weiAmount = newWei;
            tokens = newTokens;
        }
        
        tokensSold = tokensSold.add(tokens);
        remainingTokens = cap.sub(tokensSold);
        if(returnWei > 0){
            msg.sender.transfer(returnWei);
            emit Transfer(address(this), msg.sender, returnWei);
        }
        
        balances[msg.sender] = balances[msg.sender].add(tokens);
        emit Transfer(address(this), msg.sender, tokens);
        totalSupply = totalSupply.add(tokens);
        msg.sender.transfer(weiAmount);
    }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function startIco() public onlyOwner {
        require(currentStage != Stages.endSale);
        currentStage = Stages.duringSale;
    }

    function endIco() internal {
        currentStage = Stages.endSale;
        // Transfer any remaining tokens
        if(remainingTokens > 0)
            balances[owner] = balances[owner].add(remainingTokens);
        msg.sender.transfer(address(this).balance); 
    }

    function finalizeIco() public onlyOwner {
        require(currentStage != Stages.endSale);
        endIco();
    }
    
}