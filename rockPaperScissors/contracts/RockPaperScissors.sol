pragma solidity ^0.4.4;

contract RockPaperScissors {
    
    enum GameMove {Rock, Paper, Scissors}
    
    bool public firstBetDone;
    bool public secondBetDone;
    
    bool public firstMoveDecrypted;
    bool public secondMoveDecrypted;
    
    address firstPlayer;
    address secondPlayer;
    
    bytes32 firstPlayersCryptedMove;
    bytes32 secondPlayersCryptedMove;
    
    GameMove firstPlayersChoise;
    GameMove secondPlayersChoise;
    
    address owner;
    
    bool public gameOver;
    address public winner;
    
    uint256 firstBet;
    
    event Bet(uint256 currentBalance, uint256 bet);
    
    function RockPaperScissors() public {
        owner = msg.sender;
    }
    
    function makeBet(bytes32 move) public payable betsNotDone() {
        require(msg.value > 0);
        if (!firstBetDone) {
            firstBetDone = true;
            firstPlayer = msg.sender;
            firstBet = msg.value;
            firstPlayersCryptedMove = move;
        } else {
            require(msg.value == firstBet);
            secondBetDone = true;
            secondPlayer = msg.sender;
            secondPlayersCryptedMove = move;
        }
    }
    
    function decryptMove(GameMove move, uint256 secret) public isPlayer() {
        require(bothMovesRegistered());
        if (msg.sender == firstPlayer) {
            require(hashMove(move, secret) == firstPlayersCryptedMove);
            firstPlayersChoise = GameMove(move);
            firstMoveDecrypted = true;
        } else {
            require(hashMove(move, secret) == secondPlayersCryptedMove);
            secondPlayersChoise = GameMove(move);
            secondMoveDecrypted = true;
        }
        if (bothMovesDecrypted()) {
            chooseWinner();
        }
    }


    function chooseWinner() internal {
        require(bothMovesDecrypted());
        int resultOfComparation = compareMoves(firstPlayersChoise, secondPlayersChoise);
        if (resultOfComparation == 0) {
            winner = address(0);
            firstPlayer.transfer(this.balance/2);
            firstPlayer.transfer(this.balance);
        } else if (resultOfComparation > 0) {
            winner = firstPlayer;
            firstPlayer.transfer(this.balance);
        } else {
            winner = secondPlayer;
            secondPlayer.transfer(this.balance);
        }
        gameOver = true;
    }

    function compareMoves(GameMove move1, GameMove move2) public constant returns(int) {
        if (keccak256(move1) == keccak256(move2)) {
            return 0;
        } else if (move1 == GameMove.Rock) {
            if (move2 == GameMove.Paper) return -1; 
        } else if (move1 == GameMove.Paper) {
            if (move2 == GameMove.Scissors) return -1; 
        } else if (move1 == GameMove.Scissors) {
            if (move2 == GameMove.Rock) return -1; 
        }
        return 1;
    }
    
    function bothMovesRegistered() constant internal returns(bool) {
        return firstPlayersCryptedMove != bytes32(0) && secondPlayersCryptedMove != bytes32(0);
    }
    
    function bothMovesDecrypted() constant internal returns(bool) {
        return firstMoveDecrypted && secondMoveDecrypted;
    }
    
    function hashMove(GameMove move, uint secret) constant public returns(bytes32) {
        return keccak256(move, secret);
    }
    
    function getBalance() public constant returns(uint256) {
        return this.balance;
    }
    
    modifier betsNotDone() {
        require(secondBetDone == false);
        _;
    }
    
    modifier isPlayer() {
        require(msg.sender == firstPlayer || msg.sender == secondPlayer);
        _;
    }
    
    
}
