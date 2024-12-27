const LoanMachine = artifacts.require("LoanMachine");

module.exports = function(deployer) {
  deployer.deploy(LoanMachine);
};
