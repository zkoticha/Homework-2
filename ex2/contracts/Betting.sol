pragma solidity ^0.4.15;

contract Betting {
	/* Standard state variables */
	address public owner;
	address public gamblerA;
	address public gamblerB;
	uint public num_gamblers;
	address public oracle;
	uint[] internal outcomes;	// Feel free to replace with a mapping

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {
		if (msg.sender == owner) _;
	}
	modifier OracleOnly() {
		if (msg.sender == oracle) _;
	}

	/* Constructor function, where owner and outcomes are set */
	function Betting(uint[] _outcomes) {
		num_gamblers = 0;
		owner = msg.sender;
		outcomes = _outcomes;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		//THIS ALLOWS OWNER TO CHANGE ORACLE AT ANY TIME BAD!!
		oracle  = _oracle;
		return oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
		BetMade(msg.sender);
		require(msg.sender != oracle);
		//require(tx.origin != oracle);
		//require(tx.origin != owner);
		require(msg.sender != owner);

		//require(num_gamblers<2);
		if (num_gamblers == 0) {
			gamblerA = msg.sender;
		} else {
			require(msg.sender != gamblerA);
			gamblerB = msg.sender;
		}
		num_gamblers = num_gamblers + 1;


		Bet memory b;
		b.outcome = _outcome;
		b.amount = msg.value;
		b.initialized = true;
		bets[msg.sender] = b;
		return true;
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() {
		BetClosed();
		uint guessA = bets[gamblerA].outcome;
		uint guessB = bets[gamblerB].outcome;
		uint amtA = bets[gamblerA].amount;
		uint amtB = bets[gamblerB].amount;
		if (guessA == _outcome) {
			if (guessB == _outcome) {
				winnings[gamblerA] = winnings[gamblerA] + amtA;
				winnings[gamblerB] = winnings[gamblerB] + amtB;
			} else{
				winnings[gamblerA] = winnings[gamblerA] + amtA + amtB;
			}
		} else {
			if (guessB == _outcome) {
				winnings[gamblerB] = winnings[gamblerB] + amtA + amtB;
			} else {
				winnings[oracle] = winnings[oracle] + amtA + amtB;
			}
		}

		contractReset();
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
		require(withdrawAmount<=winnings[msg.sender]);
		uint bal = winnings[msg.sender];

		remainingBal = winnings[msg.sender] - withdrawAmount;
		winnings[msg.sender] = remainingBal;
		msg.sender.transfer(withdrawAmount - (withdrawAmount/10));
		owner.transfer(withdrawAmount/10);
	}
	
	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() constant returns (uint[]) {
		return outcomes;
	}
	
	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
		return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
		delete(gamblerA);
		delete(gamblerB);
		delete(num_gamblers);
	}

	/* Fallback function */
	function() payable {
		revert();
	}
}