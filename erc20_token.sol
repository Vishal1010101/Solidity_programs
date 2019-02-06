pragma solidity ^0.5.1;

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