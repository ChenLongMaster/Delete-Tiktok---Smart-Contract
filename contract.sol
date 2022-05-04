pragma solidity ^0.8.2;

contract Token{
    string public constant name = "Delete TikTok 3";
    string public constant symbol = "DTT";
    uint public constant decimals = 18;

    address public tokenOwner;
    
    uint public constant totalSupply = 1 * 10 ** decimals;
    uint public constant minimumSupply = 1 * 5 ** decimals; 
    uint public constant burningRatioPerTransaction = 1; // 1% of tranfered token will be burned

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed sender,address indexed receiver, uint amount);
    event Approval(address indexed delegator,address indexed spender, uint amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(){
        balances[msg.sender] = totalSupply;
        tokenOwner = msg.sender;
    }

    function remainingSupply() public view returns(uint){
        return balances[tokenOwner];
    }

    function balanceOf(address owner) public view returns(uint)
    {
        return balances[owner];
    } 
    function allowanceOf(address delegator, address spender) public view returns(uint){
        return allowance[delegator][spender];
    }

    

    function transfer(address to, uint amount) public returns(bool){
        uint chargingAmount = amount + burningAmountCalculator(amount);
        require(balanceOf(msg.sender) >= chargingAmount,"Sender does not have enough token.");
        require(to != address(0), "Cannot transfer to the zero address");
        balances[to] += amount;
        balances[msg.sender] -= chargingAmount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFromDelegator(address delegator, address spender, uint amount) public returns(bool){
        uint chargingAmount = amount + burningAmountCalculator(amount);
        require(balanceOf(delegator) >= chargingAmount, "Delegator does not have enough token.");
        require(allowanceOf(delegator,msg.sender) >= amount, "Spender allowance is too low.");
        balances[spender] += amount;
        balances[delegator] -= chargingAmount;
        emit Transfer(delegator,spender,amount);
        return true;
    }

    function approve(address spender, uint amount) public returns(bool){
        allowance[msg.sender][spender] += amount;
        return true;
    }

    function burningAmountCalculator(uint tranferedAmount) private pure returns(uint){
        return tranferedAmount * burningRatioPerTransaction / 100;
    }

    function burn(uint amount) payable external{
        require(balanceOf(tokenOwner) - amount >= minimumSupply);
        balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function transferOwnership(address newOwner) public returns(bool) {
        require(msg.sender == tokenOwner,"Only token owner can transfer ownership.");
        require(newOwner != address(0));
        emit OwnershipTransferred(tokenOwner, newOwner);
        tokenOwner = newOwner;
        return true;
    }

    function deleteSmartContract() public {
        require(msg.sender == tokenOwner,"Only token owner can destroy this contract.");
        selfdestruct(payable(tokenOwner));
    }
}
