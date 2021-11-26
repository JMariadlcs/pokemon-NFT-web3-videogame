// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

//Imported Base64 since it codificate JSON format for our NFT URI attributes
import "./libraries/Base64.sol";

contract MyEpicGame is ERC721{
  // Characteristics of our character. Executed only once when contract is called
  //Future work: Add more characteristics
  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
  }

    //We need to define the NFT id (unique for each minted NFT)
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // A array to help us hold the default data for our characters.
    // This will be helpful when we mint new characters and need to know
    // things like their HP, AD, etc.
    CharacterAttributes[] defaultCharacters;

    //Creation of mapping from the nft's tokenId -> that NFT attributes
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. Gives us an easy way
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;

    //Declaration of game boss (WONT BE A NFT. Boss will live on)
    struct BigBoss {
      string name;
      string imageURI;
      uint hp;
      uint maxHp;
      uint attackDamage;
  } 

  BigBoss public bigBoss;

 
  // All the other character code is below here is the same as before, just not showing it to keep thing

  // Data passed in to the contract when it's first created initializing the characters.
  // We're going to actually pass these values in from from run.js.
  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    string memory bossName, // These new variables would be passed in via run.js or deploy.js.
    //Boss atributes
    string memory bossImageURI,
    uint bossHp,
    uint bossAttackDamage

    //Especial identifier and symbol for ERC721 attributes (like Ethereum and ETH)
  )
    ERC721("Pokemons", "POKEMON")
    {

      //Boss initialization attributes. Saved to our global 'bigBoss' state variables.
       bigBoss = BigBoss({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossHp,
      maxHp: bossHp,
      attackDamage: bossAttackDamage
    });

  console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

    //Other characters code
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }

    //Increment of tokenId each time an NFT is minted (they must be unique)
    _tokenIds.increment();
  }

  //Function for MINTING NFT depending on user CHARACTER election.
  function mintCharacterNFT(uint _characterIndex) external {

    // Get current tokenId (starts at 1 since we incremented in the constructor).
    //We want our NFT to starts on 1 not 0 (since 0 is a default value)
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    // We map the tokenId => their character attributes. More on this in
    // the lesson below.
    //This part is used to implement the feature of our NFT properties DYNAMICALLY is changing over the time
    //if our character get attacked or lose health. We need the code below to store this data
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    // Keep an easy way to see who owns what NFT.
    nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
    _tokenIds.increment();
  }

  //Function used to get URI (JSON INFO) from our NFT
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
  CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

  string memory strHp = Strings.toString(charAttributes.hp);
  string memory strMaxHp = Strings.toString(charAttributes.maxHp);
  string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

  string memory json = Base64.encode(
    bytes(
      string(
        abi.encodePacked(
          '{"name": "',
          charAttributes.name,
          ' -- NFT #: ',
          Strings.toString(_tokenId),
          '", "description": "This is an NFT that lets people play in the game Pokemon NFT Metaverse!", "image": "',
          charAttributes.imageURI,
          '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
          strAttackDamage,'} ]}'
        )
      )
    )
  );

  string memory output = string(
    abi.encodePacked("data:application/json;base64,", json)
  );
  
  return output;
}

//FUNCTIONS TO INTERACT WITH OUR CHARACERS AND BOSS

//The attackBoos() function works are following -> once excecuted 1 attack from character to boss and 
// 1 attack from boss to character.
function attackBoss() public {

  // Get the state of the player's NFT.
  uint256 nftTokenIdOfPlayer = nftHolders[msg.sender]; //We get the tokenID (If user minted 3rd NFT -> nftHolders[msg.sener] = 3)
  
  //Next line we use 'storage' to change global variables of hp for example. If we use 'memory' a local
  //copy will be created that only exists within the function.
  CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer]; //We load the attributes of our gotten tokenID character
  console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
  console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage); //Atributes live on our contract. Dont have to load them

  //For attacking we need to check HP from character and boss
  // Make sure the player has more than 0 HP.
  require (
    player.hp > 0,
    "Error: character must have HP to attack boss."
  );

  // Make sure the boss has more than 0 HP.
  require (
    bigBoss.hp > 0,
    "Error: boss must have HP to attack boss."
  );

  //Hp attributes are uint256 types. We need to check if our attack is making a negative inpact (uint cannot be negative)
  // Allow player to attack boss.
  if (bigBoss.hp < player.attackDamage) {
    bigBoss.hp = 0;
  } else {
    bigBoss.hp = bigBoss.hp - player.attackDamage;
  }

  //Also need to check when the boss is attacking our character
   // Allow boss to attack player.
  if (player.hp < bigBoss.attackDamage) {
    player.hp = 0;
  } else {
    player.hp = player.hp - bigBoss.attackDamage;
  }
  
  // Console for ease.
  console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
  console.log("Boss attacked player. New player hp: %s\n", player.hp);
  }
  
}