pragma solidity ^0.4.4;

contract Splitter {
    
    address public firstRecipient;
    address public secondRecipient;
    address public owner;
    
    bool onePayoutPerformed;
    
    function Splitter(address recipient1, address recipient2) public {
        require(recipient1 != address(0));
        require(recipient2 != address(0));
        firstRecipient = recipient1;
        secondRecipient = recipient2;
        owner = msg.sender;
    }
    
    function refill() public payable payoutNotPerformedYet() returns (uint256) {
        return getBalance();
    }
    
    function performPayout() public isOwner() notEmpty() returns(address sendTo, uint256 payoutSumm) {
        if (!onePayoutPerformed) {
            uint256 halfOfBalance = this.balance/2;
            require(firstRecipient.send(halfOfBalance));
            onePayoutPerformed = true;
            return (firstRecipient, halfOfBalance);
        } else {
            uint256 restOfBalance = this.balance;
            require(secondRecipient.send(restOfBalance));
            onePayoutPerformed = false;
            return (secondRecipient, restOfBalance);
        }
    }
    
    function kill() public isOwner() isEmpty() {
        selfdestruct(owner);
    }
    
    function getBalance() public constant returns(uint256) {
        return this.balance;
    }
    
    modifier payoutNotPerformedYet() {
        require(onePayoutPerformed == false);
        _;
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
