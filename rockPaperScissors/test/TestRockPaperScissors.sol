pragma solidity ^0.4.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RockPaperScissors.sol";

contract TestRockPaperScissors {
    
    uint public initialBalance = 1 ether;
    RockPaperScissors rockPaperScissors;
    
    uint256 secret = 148;
    uint defaultBet = 1000;
    
    function beforeEach() {
        rockPaperScissors = new RockPaperScissors();
    }
    
    function testCompareMovesMove() {
        int result;
        result = rockPaperScissors.compareMoves(RockPaperScissors.GameMove.Rock, RockPaperScissors.GameMove.Rock);
        Assert.equal(result, 0, "Move rock should be equal to itself.");
        result = rockPaperScissors.compareMoves(RockPaperScissors.GameMove.Paper, RockPaperScissors.GameMove.Paper);
        Assert.equal(result, 0, "Move paper should be equal to itself.");
        result = rockPaperScissors.compareMoves(RockPaperScissors.GameMove.Scissors, RockPaperScissors.GameMove.Scissors);
        Assert.equal(result, 0, "Move scissors should be equal to itself.");
        result = rockPaperScissors.compareMoves(RockPaperScissors.GameMove.Rock, RockPaperScissors.GameMove.Paper);
        Assert.equal(result, -1, "Move rock should lose against paper.");
        result = rockPaperScissors.compareMoves(RockPaperScissors.GameMove.Rock, RockPaperScissors.GameMove.Scissors);
        Assert.equal(result, 1, "Move rock should win against scissors.");
        result = rockPaperScissors.compareMoves(RockPaperScissors.GameMove.Paper, RockPaperScissors.GameMove.Scissors);
        Assert.equal(result, -1, "Move paper should lose against scissors.");
    }
    
    function testMakeBets() {
        RockPaperScissors.GameMove move = RockPaperScissors.GameMove.Rock;
        bytes32 hashedMove = rockPaperScissors.hashMove(move, secret);
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove);
        Assert.isTrue(rockPaperScissors.firstBetDone(), "Contract should mark that first bet is done.");
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove);
        Assert.isTrue(rockPaperScissors.secondBetDone(), "Contract should mark that second bet is done.");
        Assert.equal(rockPaperScissors.balance, defaultBet*2, "Contract should receive bet money and hold them.");
    }
    
    function testMakeBetsWithDifferentValuesFailExpected() {
        RockPaperScissors.GameMove move = RockPaperScissors.GameMove.Rock;
        bytes32 hashedMove = rockPaperScissors.hashMove(move, secret);
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove);
        bool result = rockPaperScissors.call.value(defaultBet+1)(bytes4(bytes32(sha3("makeBet(bytes32)"))), hashedMove);
        Assert.isFalse(result, "There should be validation against not equal bets.");
    }

    function testBetsAndDecryptionsSeenProperly() {
        RockPaperScissors.GameMove move = RockPaperScissors.GameMove.Rock;
        bytes32 hashedMove = rockPaperScissors.hashMove(move, secret);
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove);
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove);
        uint256 playerBalanceAfterBetsDone = this.balance;
        rockPaperScissors.decryptMove(move, secret);
        Assert.isTrue(rockPaperScissors.firstMoveDecrypted(), "Contract should decrypt first move.");
        rockPaperScissors.decryptMove(move, secret);
        Assert.isTrue(rockPaperScissors.secondMoveDecrypted(), "Contract should decrypt second move.");
    }
    
    function testAdrawRewardSendProperly() {
        RockPaperScissors.GameMove move = RockPaperScissors.GameMove.Rock;
        bytes32 hashedMove = rockPaperScissors.hashMove(move, secret);
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove);
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove);
        uint256 playerBalanceAfterBetsDone = this.balance;
        rockPaperScissors.decryptMove(move, secret);
        rockPaperScissors.decryptMove(move, secret);
        Assert.equal(rockPaperScissors.winner(), address(0), "No one is winner.");
        uint256 newBalance = this.balance;
        uint256 reward = newBalance - playerBalanceAfterBetsDone;
        Assert.equal(reward, defaultBet*2, "All money should be returned to players.");
    }
    
    function testWinRewardSendProperly() {
        RockPaperScissors.GameMove move1 = RockPaperScissors.GameMove.Rock;
        bytes32 hashedMove1 = rockPaperScissors.hashMove(move1, secret);
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove1);
        RockPaperScissors.GameMove move2 = RockPaperScissors.GameMove.Scissors;
        bytes32 hashedMove2 = rockPaperScissors.hashMove(move2, secret);
        rockPaperScissors.makeBet.value(defaultBet)(hashedMove2);
        uint256 playerBalanceAfterBetsDone = this.balance;
        rockPaperScissors.decryptMove(move1, secret);
        rockPaperScissors.decryptMove(move2, secret);
        Assert.equal(rockPaperScissors.winner(), this, "This contract should be marked as winner.");
        uint256 newBalance = this.balance;
        uint256 reward = newBalance - playerBalanceAfterBetsDone;
        Assert.equal(reward, defaultBet*2, "All money should be returned to players.");
    }
    
    function () payable {
        
    }
    
}
