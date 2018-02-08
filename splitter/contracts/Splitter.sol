pragma solidity ^0.4.4;

contract Splitter {
    
    address public owner;
    
    mapping(address => uint256) deposites;
    
    bool onePayoutPerformed;
    
    function Splitter() public {
        owner = msg.sender;
    }
    
    function refill(address recipient1, address recipient2) public payable {
        require(recipient1 != address(0));
        require(recipient2 != address(0));
        deposites[recipient1] += msg.value/2;
        deposites[recipient2] += msg.value/2;
    }
    
    function performPayout() public notEmpty() returns(uint256 payoutSumm) {
        payoutSumm = deposites[msg.sender];
        require(payoutSumm > 0);
        msg.sender.transfer(payoutSumm);
        deposites[msg.sender] = 0;
    }
    
    function getBalance() public constant returns (uint256 depositBalance) {
        return deposites[msg.sender];
    }
    
    function kill() public isOwner() isEmpty() {
        selfdestruct(owner);
    }
    
    modifier notEmpty() {
        require(this.balance > 0);
        _;
    }
    
    modifier isEmpty() {
        require(this.balance == 0);
        _;
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    
}
