var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./MetaCoin.sol");
var Remittance = artifacts.require("./Remittance.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, MetaCoin);
  deployer.deploy(MetaCoin);
  deployer.deploy(Remittance, "0xa9c334a7edcec626b1d9f24b66d2d3d890f073da", "hola", 10);
};
