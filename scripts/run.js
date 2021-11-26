const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
      ["Turtwig", "Chimchard", "Piplup"],       // Names
      ["https://imgur.com/a/uzLpyFc", // Images
      "https://imgur.com/a/AUU3Jmt", 
      "https://imgur.com/a/3ZHEXSR"],
      [100, 300, 200],                    // HP values
      [100, 150, 150]                       // Attack damage values
    );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;
    // We only have three characters.
    // an NFT w/ the character at index 2 of our array.
    txn = await gameContract.mintCharacterNFT(2);
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