pragma solidity ^0.4.15;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Betting.sol";

contract BettingTest {
	Betting betting = Betting(DeployedAddresses.Betting());

	function testChooseOracle() {
		address oracle = betting.chooseOracle(0x56a686aa7ce2a9a4210dfe2dc28d24fdd8d83a1e);
		address expected = betting.oracle();
		Assert.equal(oracle, expected, "Oracle chosen by Owner should be registered.");
	}

	 function testMakeBet() {
	 	address exampleA = this;
	 	bool boolA = betting.makeBet(1);
	 	address gamblerA = betting.gamblerA();
		 Assert.equal(boolA, true, "GamblerA should be set correctly.");
	 	Assert.equal(gamblerA, exampleA, "GamblerA should be set to correct address.");
	 }
}
