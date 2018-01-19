pragma solidity ^0.4.4;

contract Splitter {
    
    address firstRecipient;
    address secondRecipient;
    address owner;
    
    function Splitter(address recipient1, address recipient2) public payable {
        firstRecipient = recipient1;
        secondRecipient = recipient2;
        owner = msg.sender;
    }
    
    function refill() public payable {
        firstRecipient.transfer(msg.value/2);
        secondRecipient.transfer(msg.value/2);
    }
    
    function kill() public isOwner() {
        selfdestruct(owner);
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    
}
