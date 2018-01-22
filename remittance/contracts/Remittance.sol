pragma solidity ^0.4.4;

contract Remittance {
    
    address recipient;
    bytes32 recipientPasswordHash;
    
    uint256 expirationTime;
    
    address public owner;
    
    bool activated;
    
    function Remittance() public {
        owner = msg.sender;
    }
    
    function activate(address recipientAddress, bytes32 passwordHash, uint256 expirationAfterSeconds) payable public isOwner() {
        require(msg.value > 0);
        require(recipientAddress != address(0));
        recipient = recipientAddress;
        recipientPasswordHash = passwordHash;
        if (expirationAfterSeconds != uint256(0)) {
            require(expirationAfterSeconds > 0);
            expirationTime = now + expirationAfterSeconds;
        } else {
            expirationTime = 0xFFFFFFF;
        }
        activated = true;
    }
    
    function extract(string password) public {
        require(recipient == msg.sender);
        require(recipientPasswordHash == keccak256(password));
        require(this.balance > 0);
        msg.sender.transfer(this.balance);
        activated = false;
    }
    
    function kill() public isOwner() {
        require(isExpired() || !canExpire() || getBalance() == 0);
        selfdestruct(owner);
    }
    
    function isExpired() public constant returns (bool) {
        return canExpire() && getSecondsTillExpiration() == 0;
    }
    
    function canExpire() public constant returns(bool) {
        return expirationTime == 0xFFFFFFF? false : true;
    }
    
    function getBalance() public constant returns(uint256) {
        return this.balance;
    }
    
    function getSecondsTillExpiration() constant public returns (uint256) {
        if(canExpire()) {
            uint256 currentTime = now * 1 seconds;
            if (expirationTime > currentTime) {
                return expirationTime - currentTime;
            }
        }
        return 0;
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    
}

