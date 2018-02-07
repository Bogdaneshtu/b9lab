var Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function (accounts) {
    it('should work only for proper recipient', async function () {

        var owner = accounts[0];
        var donor = accounts[1];
        var recipient = accounts[2];
        var password = "hola";
        var hashedPassword = "0x8aca9664752dbae36135fd0956c956fc4a370feeac67485b49bcd4b99608ae41";
        var secondsTillExpiration = 100;
        var sendValue = 1000;

        var initialRecipientBalance = web3.eth.getBalance(recipient);

        var remittance = await Remittance.deployed();
        await remittance.activate(recipient, hashedPassword, secondsTillExpiration, {value: sendValue, from: owner});

        try {
            await remittance.extract(password, {from: owner});
            assert.fail("You have successfully extracted money from contract even if you're not recipient.",
                "Only recipient should be able to extract money.", "Everybody can extract money from contract!");
        } catch (e) {

        }

        var tx = await remittance.extract(password, {from: recipient});

    });
});
