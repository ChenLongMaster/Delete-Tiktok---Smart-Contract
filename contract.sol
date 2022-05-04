pragma solidity ^0.8.2;

contract Token{
    string public constant name = "Delete TikTok";
    string public constant symbol = "DTT";

    address public tokenOwner = 0xf6f03523a96788474A6c0603685075E7015a0559;
    address public constant zeroAccount = address(0);
    
    uint public constant decimal = 18;
    uint public constant totalSupply = 10000 * 10 ** decimal;
    uint public constant minimumSupply = 10000 * 5 ** decimal; 
    uint public constant burningRatioPerTransaction = 1; // 1% of tranfered token will be burned

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed sender,address indexed receiver, uint amount);
    event Approval(address indexed delegator,address indexed spender, uint amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(){
        balances[msg.sender] = totalSupply;
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
        require(balanceOf(msg.sender) >= amount,'Sender does not have enough token.');
        require(to != zeroAccount, "Cannot transfer from the zero address");

        balances[to] += amount;
        balances[msg.sender] -= amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFromDelegator(address delegator, address spender, uint amount) public returns(bool){
        require(balanceOf(delegator) >= amount, 'Delegator does not have enough token.');
        require(allowanceOf(delegator,msg.sender) >= amount, 'Spender allowance is too low.');
        balances[spender] += amount;
        balances[delegator] -= amount;
        emit Transfer(delegator,spender,amount);
        return true;
    }

    function approve(address spender, uint amount) public returns(bool){
        allowance[msg.sender][spender] += amount;
        return true;
    }

    function autoBurnByTransferredToken(uint tranferedAmount) private returns(bool){
        uint burnAmount = tranferedAmount * burningRatioPerTransaction / 100;
        require(balanceOf(tokenOwner) - burnAmount >= minimumSupply);
        transfer(zeroAccount,burnAmount);
        return true;
    }

    function burn(uint amount) payable external{
        require(msg.sender == tokenOwner,'Only Token Owner can burn the tokens.');
        require(balanceOf(tokenOwner) - amount >= minimumSupply);
        transfer(zeroAccount,amount);
    }

    function transferOwnership(address newOwner) public returns(bool) {
        require(newOwner != address(0));
        emit OwnershipTransferred(tokenOwner, newOwner);
        tokenOwner = newOwner;
        return true;
    }

    function deleteSmartContract() public {

    }
}
