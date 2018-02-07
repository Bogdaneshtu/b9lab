var RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

contract('RockPaperScissors', function (accounts) {
    it('should select winner properly', async function () {
        var owner = accounts[0];
        var winner = accounts[1];
        var looser = accounts[2];
        var rockMove = 0;
        var paperMove = 1;
        var secret = 148;
        var bet = 1000;
        var rockPaperScissors = await RockPaperScissors.deployed();
        var looserMoveHash = await rockPaperScissors.hashMove(rockMove, secret);
        var winnerMoveHash = await rockPaperScissors.hashMove(paperMove, secret);

        await rockPaperScissors.makeBet(looserMoveHash, {from: looser, value: bet});
        await rockPaperScissors.makeBet(winnerMoveHash, {from: winner, value: bet});
        await rockPaperScissors.decryptMove(rockMove, secret, {from: looser});
        await rockPaperScissors.decryptMove(paperMove, secret, {from: winner});
        var gameWinner = await rockPaperScissors.winner();

        assert.equal(gameWinner, winner, 'Winner chose wrong.');

    });
});
