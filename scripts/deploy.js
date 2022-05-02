// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

const main = async () => {
  // Gets info of the account used to deploy
  const [deployer] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();

  console.log('Deploying contract with account: ', deployer.address);
  console.log('Account balance: ', accountBalance.toString());

  // Read contract file
  const LabelContract = await hre.ethers.getContractFactory('LabelContract');

  // Triggers deployment
  const label_contract = await LabelContract.deploy();

  // Wait for deployment to finish
  await label.deployed();

  console.log('Contract deployed to address: ', label_contract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();
