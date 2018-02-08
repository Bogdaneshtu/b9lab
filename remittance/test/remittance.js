var Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function (accounts) {
    it('should work only for proper recipient', async function () {
        var owner = accounts[0];
        var donor = accounts[1];
        var recipient = accounts[2];
        var password = web3.sha3("password");
        var hashedPassword = web3.sha3(password, {encoding: 'hex'});
        var secondsTillExpiration = 100;
        var sendValue = 1000;

        var getBalancePromise = new Promise(function(resolve, reject){
            web3.eth.getBalance(recipient, resolve);
        });

        var initialRecipientBalance = await getBalancePromise;

        var remittance = await Remittance.new();

        await remittance.activate(recipient, hashedPassword, secondsTillExpiration, {value: sendValue, from: owner});

        try {
            await remittance.extract(password, {from: owner});
            assert.fail("You have successfully extracted money from contract even if you're not recipient.",
                "Only recipient should be able to extract money.", "Everybody can extract money from contract!");
        } catch (e) {

        }

        var tx = await remittance.extract(password, {from: recipient});

    });

    it('should allow donor of remittance to revoke money after expiration', async function () {

    });
});

/*
contract('Remittance', function (accounts) {
    it('should allow donor of remittance to revoke money after expiration', async function () {
        var owner = accounts[0];
        var donor = accounts[1];
        var recipient = accounts[2];
        var password = "0x8aca9664752dbae36135fd0956c956fc4a370feeac67485b49bcd4b99608ae41";
        var hashedPassword = "0xa180946545070e0177e1addef0831e2b069cbe3819dc0c0046813d8a02510c4d";
        var secondsTillExpiration = 1;
        var sendValue = 1000;

        var remittance = await Remittance.deployed();

        await remittance.activate(recipient, hashedPassword, secondsTillExpiration, {value: sendValue, from: donor});
        sleep(1500);
        remittance.revoke(null, {from: donor});
    });
});

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds){
            break;
        }
    }
}*/
