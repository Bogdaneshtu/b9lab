pragma solidity ^0.4.19;

contract Remittance {
    
    bytes32 recipientAddressHash;
    bytes32 recipientPasswordHash;
    
    uint256 public createdTime;
    uint256 public validMinutes;
    
    address owner;
    
    function Remittance(address recipient, string password, uint256 expirationAfterMinutes) payable public {
        require(recipient != address(0));
        require(bytes(password).length != 0);
        recipientAddressHash = keccak256(recipient);
        recipientPasswordHash = keccak256(password);
        owner = msg.sender;
        if (expirationAfterMinutes != uint256(0)) {
            require(expirationAfterMinutes > 0);
            Remittance.validMinutes = expirationAfterMinutes;
        }
        Remittance.createdTime = now;
    }
    
    function extract(string password) public {
        require(recipientAddressHash == keccak256(msg.sender));
        require(recipientPasswordHash == keccak256(password));
        selfdestruct(msg.sender);
    }
    
    function kill() public isOwner() {
        require(isExpired() || !canExpire());
        selfdestruct(owner);
    }
    
    function canExpire() public constant returns (bool) {
        return validMinutes > 0;
    }
    
    function isExpired() public constant returns (bool) {
        return canExpire() && getSecondsTillExpiration() == 0;
    }
    
    function getSecondsTillExpiration() public constant returns (uint256) {
        if(canExpire()) {
            uint256 secondsTillExpiration = (createdTime + validMinutes * 60 - now);
            if (secondsTillExpiration > 0) {
                return secondsTillExpiration; 
            }
        }
        return 0;
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    
}
