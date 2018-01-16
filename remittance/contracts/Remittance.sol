pragma solidity ^0.4.4;

contract Remittance {
    
    address recipient;
    bytes32 recipientPasswordHash;
    
    uint256 expirationTime;
    bool public canExpire;
    
    address owner;
    
    bool activated;
    
    function Remittance() public {
        owner = msg.sender;
        activated = false;
    }
    
    function activate(address recipientAddress, bytes32 passwordHash, uint256 expirationAfterSeconds) payable public isOwner() {
        require(msg.value > 0);
        require(recipientAddress != address(0));
        recipient = recipientAddress;
        recipientPasswordHash = passwordHash;
        if (expirationAfterSeconds != uint256(0)) {
            require(expirationAfterSeconds > 0);
            expirationTime = (now * 1 seconds) + expirationAfterSeconds;
            canExpire = true;
        } else {
            canExpire = false;
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
        require(isExpired() || !canExpire);
        selfdestruct(owner);
    }
    
    function isExpired() public constant returns (bool) {
        return canExpire && getSecondsTillExpiration() == 0;
    }
    
    function getBalance() public view returns(uint256) {
        return this.balance;
    }
    
    function getSecondsTillExpiration() constant public returns (uint256) {
        if(canExpire) {
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
