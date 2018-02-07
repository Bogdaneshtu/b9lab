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
    
}
