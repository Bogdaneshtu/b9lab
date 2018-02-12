pragma solidity ^0.4.4;

contract Splitter {
    
    address public owner;
    
    mapping(address => uint256) deposites;
    
    bool onePayoutPerformed;
    
    event LogRefill(address, address, uint256);
    event LogPayout(address, uint256);
    
    function Splitter() public {
        owner = msg.sender;
    }
    
    function refill(address recipient1, address recipient2) public payable {
        require(recipient1 != address(0));
        require(recipient2 != address(0));
        require(msg.value % 2 == 0);
        deposites[recipient1] += msg.value/2;
        deposites[recipient2] += msg.value/2;
        LogRefill(recipient1, recipient2, msg.value);
    }
    
    function performPayout() public returns(uint256 payoutSumm) {
        payoutSumm = deposites[msg.sender];
        require(payoutSumm > 0);
        deposites[msg.sender] = 0;
        msg.sender.transfer(payoutSumm);
        LogPayout(msg.sender, payoutSumm);
    }
    
    function getBalance(address depositHolder) public constant returns (uint256 depositBalance) {
        return deposites[depositHolder];
    }
    
    function kill() public isOwner() isEmpty() {
        selfdestruct(owner);
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
