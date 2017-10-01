var Betting = artifacts.require("./Betting.sol");

contract('BettingTestGeneric', function(accounts) {
	const args = {_default: accounts[0], _owner: accounts[1]};

	it("The contract can be deployed", function() {
		return Betting.new()
		.then(function(instance) {
			assert.ok(instance.address);
		});
	});

	it("The contract can be deployed by custom addresses (default)", function() {
		return Betting.new()
		.then(function(instance) {
			return instance.owner.call();
		})
		.then(function(result) {
			assert.equal(result, args._default, "contract owned by " +
				"the wrong address");
		});
	});

	it("The contract can be deployed by custom addresses (using 'from')", function() {
		return Betting.new({from: args._owner})
		.then(function(instance) {
			return instance.owner.call();
		})
		.then(function(result) {
			assert.equal(result, args._owner, "contract owned by " +
				"the wrong address");
		});
	});
});

contract('BettingTestOracleSet', function(accounts) {
	const null_address = '0x0000000000000000000000000000000000000000';
	const args = {_owner: accounts[1], _oracle: accounts[2],
		_other: accounts[3], _fail: null_address};

	it("The Owner can set a new Oracle", function() {
		return Betting.new({from: args._owner})
		.then(function(instance) {
			return instance.chooseOracle.call(args._oracle, {from: args._owner});
		})
		.then(function(result) {
			assert.equal(result, args._oracle, "Oracle address and test " +
				"values do not match");
		});
	});

	it("The Oracle cannot be set by non-Owner addresses", function() {
		return Betting.new({from: args._owner})
		.then(function(instance) {
			return instance.chooseOracle.call(args._oracle, {from: args._other});
		})
		.then(function(result) {
			assert.equal(result, args._fail, "Oracle address and test " +
				"values should both be uninitialized addresses");
		});
	});

    // The contract is deployed, owner and outcomes are set (e.g. [1, 2, 3, 4])
    // Owner chooses their oracle
    // User at address A makes a bet of 50 wei on outcome 1, becomes gamblerA
    // User at address B makes a bet of 210 wei on outcome 2, becomes gamblerB
    // User at address A makes a bet on outcome 3, is not allowed to do so (each gambler can only bet once)
    // User at address G tries to make a bet, is not allowed to do so (only two gamblers in the vanilla contract)
    // Oracle decided on the correct outcome, chooses outcome 2
    // Winnings are dispersed, the game is over and gamblerA and gamblerB are removed from the game
    // User at address B withdraws the winnings they earned (260 wei) when they gambled on outcome 2

	// it(
     //    // function testMakeBet() {
     //    // 	address exampleA = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
     //    //	address exampleB = 0x583031d1113ad414f02576bd6afabfb302140225;
     //    // 	bool boolA = betting.makeBet(1, {from: exampleA, value: 600});
     //    // 	bool boolB = betting.makeBet(2, {from: exampleB, value: 600});
     //    // 	address gamblerA = betting.gamblerA();
     //    // 	Assert.equal(boolA, true, "GamblerA should be set correctly.");
     //    // 	Assert.equal(gamblerA, exampleA, "GamblerA should be set to correct address.");
     //    // }
	// )

});
