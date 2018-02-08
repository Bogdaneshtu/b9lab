pragma solidity ^0.4.4;

contract Remittance {
    
    address recipient;
    bytes32 recipientPasswordHash;
    
    uint256 expirationTime;
    uint256 defaultExpirationTimeValue = uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    
    address public owner;
    address public initiator;
    
    event LogEnteredExtractPasswordHash(bytes32 passwordHash);
    
    function Remittance() public {
        owner = msg.sender;
        expirationTime = defaultExpirationTimeValue;
    }
    
    function activate(address recipientAddress, bytes32 passwordHash, uint256 expirationAfterSeconds) payable public {
        require(msg.value > 0);
        require(recipientAddress != address(0));
        recipient = recipientAddress;
        recipientPasswordHash = passwordHash;
        if (expirationAfterSeconds != uint256(0)) {
            expirationTime = now + expirationAfterSeconds;
        }
        initiator = msg.sender;
    }
    
    function extract(bytes32 password) public {
        bytes32 enteredPasswordHash = keccak256(password);
        LogEnteredExtractPasswordHash(enteredPasswordHash);
        require(recipient == msg.sender);
        require(recipientPasswordHash == enteredPasswordHash);
        require(this.balance > 0);
        // there is no check for expiration, since if contract wasn't revoked
        // I expect it should work as usual
        msg.sender.transfer(this.balance);
        initiator = address(0);
        expirationTime = defaultExpirationTimeValue;
    }
    
    function revoke() public {
        require(msg.sender == initiator);
        require(canExpire() && isExpired());
        msg.sender.transfer(this.balance);
        initiator = address(0);
    }
    
    function kill() public isOwner() {
        if (initiator != address(0)) {
            selfdestruct(initiator);
        } else {
            selfdestruct(owner);
        }
    }
    
    function isExpired() public constant returns (bool) {
        return canExpire() && getSecondsTillExpiration() == 0;
    }
    
    function canExpire() public constant returns(bool) {
        return expirationTime == defaultExpirationTimeValue? false : true;
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

