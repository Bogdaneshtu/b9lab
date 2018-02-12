pragma solidity ^0.4.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Remittance.sol";

contract TestRemittance {

    uint public initialBalance = 1 ether;
    
    bytes32 password = keccak256("passord");
    bytes32 hashedPassword = keccak256(password);
    uint valuetoSend = 1000;
    uint secondsBeforeExpiration = 100;
    
    Remittance remittance;
    
    function beforeEach() {
        remittance = new Remittance();
    }
    
    function testActivateAndExtract() {
        remittance.activate.value(valuetoSend)(this, hashedPassword, 100);
        uint newremittanceBalance = remittance.balance;
        Assert.equal(newremittanceBalance, valuetoSend, "All send money should be on remittance contract.");
        remittance.extract(password);
        Assert.equal(this.balance, initialBalance, "All money should be returned to recipient.");
    }
    
    function testExpirationWorkingProperly() {
        bool canExpire;
        canExpire = remittance.canExpire();
        Assert.isFalse(canExpire, "Contract can not expire if it was not even activated yet.");
        remittance.activate.value(valuetoSend)(this, hashedPassword, secondsBeforeExpiration);
        canExpire = remittance.canExpire();
        Assert.isTrue(canExpire, "Since we set expiration time, contract should be able to expire.");
        uint secondsBeforeExpirationLeft = remittance.getSecondsTillExpiration();
        Assert.isTrue(secondsBeforeExpirationLeft > 0 && secondsBeforeExpirationLeft <= secondsBeforeExpiration, "Number of expiration was not set properly.");
    }
    
    function testActivateWithWrongRecipientFailExpected() {
        bool result = remittance.call.value(valuetoSend)(bytes4(bytes32(sha3("activate(address, bytes32, uint256)"))), address(0), hashedPassword, secondsBeforeExpiration);
        Assert.isFalse(result, "You should not be able to send empty recipient.");
    }
    
    function testActivateAndExtractWithWrongPassword() {
        remittance.activate.value(valuetoSend)(this, hashedPassword, 100);
        bool result = remittance.call(bytes4(bytes32(sha3("extract(string)"))), "blabla");
        Assert.isFalse(result, "You should not be able to extract money with wrong password.");
    }
    
    function testActivateWithWrongExpirationFailExpected() {
        bool result = remittance.call.value(valuetoSend)(bytes4(bytes32(sha3("activate(address, bytes32, uint256)"))), this, hashedPassword, -100);
        Assert.isFalse(result, "You should not be able to set such expiration time.");
    }
    
    function () payable {
        
    }
    
}
