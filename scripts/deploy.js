//File used to compile and deploy our contract ALCHEMY ETHEREUM NETWORK 
require("@nomiclabs/hardhat-waffle");
const { hexStripZeros } = require("@ethersproject/bytes")

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
  const gameContract = await gameContractFactory.deploy(
    ["Turtwig", "Chimchard", "Piplup"],       // Names
    ["https://i.imgur.com/TPurhtm.png", // Images
    "https://i.imgur.com/dOUPBvW.png", 
    "https://i.imgur.com/ADWxerc.png"],
    [100, 300, 200],                    // HP values
    [100, 150, 150],                       // Attack damage values
    "Darkray", // Boss name
    "https://i.imgur.com/uXErRMw.png", // Boss image
    10000, // Boss hp
    50 // Boss attack damage
  );

  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();