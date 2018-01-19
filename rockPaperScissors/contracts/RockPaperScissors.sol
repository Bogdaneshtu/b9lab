pragma solidity ^0.4.4;

contract RockPaperScissors {
    
    bool public firstBetDone;
    bool public secondBetDone;
    
    address firstPlayer;
    address secondPlayer;
    
    bytes32 firstPlayersCryptedMove;
    bytes32 secondPlayersCryptedMove;
    
    string firstPlayersChoise;
    string secondPlayersChoise;
    
    address owner;
    
    bool public gameOver;
    address public winner;
    
    uint256 firstBet;
    
    event Bet(uint256 currentBalance, uint256 bet);
    
    
    function RockPaperScissors() public {
        owner = msg.sender;
    }
    
    function makeBet() public payable betsNotDone() {
        require(msg.value > 0);
        if (!firstBetDone) {
            firstBetDone = true;
            firstPlayer = msg.sender;
            firstBet = msg.value;
        } else {
            require(msg.value >= firstBet);
            secondBetDone = true;
            secondPlayer = msg.sender;
        }
    }
    
    function setMove(bytes32 move) public isPlayer() {
        if (msg.sender == firstPlayer) {
            firstPlayersCryptedMove = move;
        } else {
            secondPlayersCryptedMove = move;
        }
    }
    
    function decryptMove(string move, string secret) public isPlayer() {
        require(bothMovesRegistered());
        if (msg.sender == firstPlayer) {
            require(keccak256(move, secret) == firstPlayersCryptedMove);
            firstPlayersChoise = move;
        } else {
            require(keccak256(move, secret) == secondPlayersCryptedMove);
            secondPlayersChoise = move;
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

    function compareMoves(string move1, string move2) internal constant returns(int) {
        require(validMove(move1) && validMove(move2));
        if (keccak256(move1) == keccak256(move2)) {
            return 0;
        } else if (keccak256(move1) == keccak256("rock")) {
            if (keccak256(move2) == keccak256("paper")) return -1; 
        } else if (keccak256(move1) == keccak256("paper")) {
            if (keccak256(move2) == keccak256("scissors")) return -1; 
        } else if (keccak256(move1) == keccak256("scissors")) {
            if (keccak256(move2) == keccak256("rock")) return -1; 
        }
        return 1;
    }
    
    function bothMovesRegistered() constant internal returns(bool) {
        return firstPlayersCryptedMove != bytes32(0) && secondPlayersCryptedMove != bytes32(0);
    }
    
    function bothMovesDecrypted() constant internal returns(bool) {
        return notEmpty(firstPlayersChoise) && notEmpty(secondPlayersChoise);
    }
    
    function hashMove(string move, string secret) constant public returns(bytes32) {
        require(validMove(move));
        return keccak256(move, secret);
    }
    
    function validMove(string move) constant internal returns(bool valid) {
        require(notEmpty(move));
        bytes32 hashedMove = keccak256(move);
        return hashedMove == keccak256("rock") || hashedMove == keccak256("paper") || hashedMove == keccak256("scissors");
    }
    
    function notEmpty(string value) constant internal returns(bool) {
        return bytes(value).length > 0;
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
