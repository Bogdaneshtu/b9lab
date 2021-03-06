pragma solidity ^0.4.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Splitter.sol";

contract TestSplitter {

    uint public initialBalance = 1 ether;
    
    address firstRecipient = 0x3cB2158E6f327B7294A9FE05574096B46f261904;
    address secondRecipient = 0xC24063d709FDC9c1Ca3e3B56789514dBdBeFa55E;
    
    uint256 previousFirstRecipientBalance;
    uint256 previousSecondRecipientBalance;

    Splitter splitter;
    
    uint moneyToSend = 1000;

    function beforeEach() {
        splitter = new Splitter(firstRecipient, secondRecipient);
        previousFirstRecipientBalance = firstRecipient.balance;
        previousSecondRecipientBalance = secondRecipient.balance;
    }

    function testInitializedTargetAddressesProperly() {
        Assert.equal(splitter.firstRecipient(), firstRecipient, "First recipient didn't set properly.");
        Assert.equal(splitter.secondRecipient(), secondRecipient, "Second recipient didn't set properly.");
    }
    
    function testSplitMoney() {
        splitter.refill.value(moneyToSend)();
        Assert.equal(splitter.balance, moneyToSend, "Splitter should hold all transferred money until payouts will not be done.");
        splitter.performPayout();
        Assert.equal(splitter.balance, moneyToSend/2, "Splitter should hold half of balance after first payout.");
        uint256 firstRecipientIncome = firstRecipient.balance - previousFirstRecipientBalance;
        Assert.equal(firstRecipientIncome, moneyToSend/2, "First recipient should receive half of money.");
        splitter.performPayout();
        Assert.equal(splitter.balance, 0, "Splitter should has 0 balance after payouts.");
        uint256 secondRecipientIncome = secondRecipient.balance - previousSecondRecipientBalance;
        Assert.equal(secondRecipientIncome, moneyToSend/2, "Second recipient should receive half of money.");
    }
    
    function testPerformPayoutsThreeTimesFailExpected() {
        splitter.refill.value(moneyToSend)();
        splitter.performPayout();
        splitter.performPayout();
        bool result = splitter.call(bytes4(bytes32(sha3("performPayout()"))));
        Assert.isFalse(result, "Third call should be throwed.");
    }
    
    function testKillNotEmpty() {
        splitter.refill.value(moneyToSend)();
        bool result = splitter.call(bytes4(bytes32(sha3("kill()"))));
        Assert.isFalse(result, "You should not be able to kill not empty contract.");
    }

}
