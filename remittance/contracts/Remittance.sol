pragma solidity ^0.4.4;

contract Remittance {
    
    uint256 defaultExpirationTimeValue = uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    address public owner;
    event LogEnteredExtractPasswordHash(bytes32 passwordHash);
    event LogActivatedNewDeposit(address recipient, address initiator, bytes32 passwordHash, uint256 expirationAfterSeconds, uint256 value);
    event LogExtractedDeposit(address recipient, uint256 value);
    event LogDepositRevoked(address initiator, uint256 value);
    
    function Remittance() public {
        owner = msg.sender;
    }
    
    struct Deposit {
        address initiator;
        address recipient;
        bytes32 hashedPassword;
        uint256 balance;
        uint256 expirationTime;
        bool active;
    }
    
    mapping (address => uint256) recipientIndexes;
    mapping (address => uint256) initiatorIndexes;
    Deposit[] deposits;
    
    function activate(address recipientAddress, bytes32 passwordHash, uint256 expirationAfterSeconds) payable public {
        require(msg.value > 0);
        require(recipientAddress != address(0));
        require(recipientIndexes[recipientAddress] == 0);
        uint256 expirationTime;
        if (expirationAfterSeconds != uint256(0)) {
            expirationTime = now + expirationAfterSeconds;
        } else {
            expirationTime = defaultExpirationTimeValue;
        }
        Deposit memory newDeposit = Deposit(msg.sender, recipientAddress, passwordHash, msg.value, expirationTime, true);
        uint256 index = deposits.push(newDeposit);
        recipientIndexes[recipientAddress] = index;
        initiatorIndexes[msg.sender] = index;
        LogActivatedNewDeposit(recipientAddress, msg.sender, passwordHash, expirationAfterSeconds, msg.value);
    }
    
    function extract(bytes32 password) public {
        bytes32 enteredPasswordHash = keccak256(password);
        uint256 depositIndex = recipientIndexes[msg.sender];
        LogEnteredExtractPasswordHash(enteredPasswordHash);
        require(depositIndex > 0);
        Deposit storage deposit = deposits[depositIndex];
        require(deposit.balance > 0);
        require(deposit.active == true);
        uint256 valueToSend = deposit.balance;
        disableDeposit(depositIndex);
        // there is no check for expiration, since if contract wasn't revoked
        // I expect it should work as usual
        msg.sender.transfer(valueToSend);
        LogExtractedDeposit(msg.sender, valueToSend);
    }
    
    function revoke() public {
        uint256 depositIndex = initiatorIndexes[msg.sender];
        require(depositIndex > 0);
        Deposit storage deposit = deposits[depositIndex];
        require(deposit.active == true && deposit.balance > 0);
        require(isExpired(deposit));
        disableDeposit(depositIndex);
        uint256 valueToSend = deposit.balance;
        msg.sender.transfer(valueToSend);
        LogDepositRevoked(msg.sender, valueToSend);
    }
    
    function disableDeposit(uint256 index) public {
        deposits[index].active = false;
        initiatorIndexes[deposits[index].initiator] = 0;
        recipientIndexes[deposits[index].recipient] = 0;
    }
    
    function kill() public isOwner() {
        selfdestruct(owner);
    }
    
    function isExpired(Deposit deposit) public constant returns (bool) {
        return getSecondsTillExpiration(deposit) == 0;
    }
    
    function canExpire(Deposit deposit) public constant returns(bool) {
        return deposit.expirationTime != defaultExpirationTimeValue;
    }
    
    function getSecondsTillExpiration(Deposit deposit) constant public returns (uint256) {
        if(canExpire(deposit)) {
            uint256 currentTime = now;
            if (deposit.expirationTime > currentTime) {
                return deposit.expirationTime - currentTime;
            }
        }
        return defaultExpirationTimeValue;
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    
}

