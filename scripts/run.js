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

    let txn;
    // We only have three characters.
    // an NFT w/ the character at index 2 of our array.
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    txn = await gameContract.attackBoss();
    await txn.wait();

    txn = await gameContract.attackBoss();
    await txn.wait();

    // Get the value of the NFT's URI.
    let returnedTokenUri = await gameContract.tokenURI(1); //Function inherited from ERC721 (returs the data inside de NFT)
    console.log("Token URI:", returnedTokenUri)
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