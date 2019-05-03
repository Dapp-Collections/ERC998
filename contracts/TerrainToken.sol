pragma solidity >= 0.4.24; 

import "../openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol"; 


contract TerrainToken is ERC721, Ownable {

    struct GPS
    {
        int latitude;// between -90 and +90
        uint latDecimal;//0 and 99999
        int longitude;// -180 and +180
        uint longDecimal;//0 and 99999
    }

    struct Terrain
    {
        address payable owner; // the adress is payable so we can buy the token with eth
        uint Id;// id of the token for the mapping

        uint superficie;
        bool jardin;
        GPS location;//GPS coordinates of the land
        string addresse;

        uint prix;// price of the token(used when selling it)
        bool aVendre;// tells if the owner is trying to sell the token
    }

    string public name;
    string public ticker;
    uint incrementId;

    mapping(address => bool) owners;
    mapping(uint => Terrain) Terrains;

    constructor() public { 
        ticker = "TTK"; 
        name = "TerrainToken";
        incrementId = 0;
    }

    function RegisterOwner(address addr) public {//add to whitelist
        require(msg.sender == owner());
        require(owners[addr] == false);
        
        owners[addr] = true;
    }

    function isOwnerOf(uint id) public view returns(bool own){//checks if owner of token
        own = Terrains[id].owner == msg.sender;
    }

    function declareTerrain(uint superficie,  bool jardin, 
            int lat, uint latD, int long, uint longD, 
            string memory adresse, uint prix) public {
        require(lat>= -90 && lat<=90);// verifies if GPS coordinates are valid
        require(latD>= 0 && latD<=10000);
        require(long>= -80 && long<=80);
        require(longD>= 0 && longD<=10000);
        GPS memory location = GPS(lat,latD,long,longD);
        Terrains[incrementId] = Terrain(msg.sender, incrementId, superficie, jardin, location, adresse, prix,false);
        emit Transfer(msg.sender, msg.sender, incrementId);
        incrementId++;
    }

    function statutVente(uint id, bool aVendre) public{// changes selling status
        require(Terrains[id].owner == msg.sender);
        Terrains[id].aVendre = aVendre;
    }

    function modifierPrix(uint id, uint prix) public{//modifing selling price
        require(Terrains[id].owner == msg.sender);
        Terrains[id].prix = prix;
    }

    function acheter(uint id) public {//byer transfer [prix] ETH and gets the token
        require(Terrains[id].aVendre);
        Terrains[id].owner.transfer(Terrains[id].prix);
        safeTransferFrom(Terrains[id].owner, msg.sender, id);
        Terrains[id].aVendre = false;
    }

}