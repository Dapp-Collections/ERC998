pragma solidity >= 0.4.24; 

import "../openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./MaisonToken.sol";
import "./TerrainToken.sol";

contract PackageToken is ERC721, Ownable { //ERC998

   struct Package
    {
        address payable owner;// the adress is payable so we can buy the Package with eth
        uint id;// id of the Package for the mapping
        
        uint maisonId;// maison and terrain Id to package both of them into a single token
        uint terrainId;

        uint prix;// price of the house(used when selling it)
        bool aVendre;// tells if the owner is trying to sell the house
    }

    string public name;
    string public ticker;
    uint incrementId;//used to get new ids (for mapping)

    address maisonToken;//MaisonToken and TerrainToken contracts adresses 
    address terrainToken;//so they can be used in this contract

    mapping(address => bool) owners;//whitelist
    mapping(uint => Package) package;//id to token

    constructor(address _maisonToken, address _terrainToken) public { //addresses as parameter (used in migration)
        ticker = "PTK"; 
        name = "PackageToken";
        incrementId = 0;

        maisonToken = _maisonToken;
        terrainToken = _terrainToken;
    }

    modifier tokenOwner(address owner_addr) {
        require(owners[owner_addr]);
        _;
    }

    function isComplete(uint Id) public view returns(bool) {//verifies if the owner of the ERC998 token owns both of ERC721 tokens
        bool b = false;
        if(MaisonToken(maisonToken).isOwnerOf(package[Id].maisonId) 
        && TerrainToken(terrainToken).isOwnerOf(package[Id].terrainId)) b = true;
        return b;
    }

    function RegisterOwner(address addr) public {//add to whitelist
        require(msg.sender == owner());
        require(owners[addr] == false);
        
        owners[addr] = true;
    }

    //declares new Package only if owner owns house and land
    function declarePackage(uint MaisonId, uint TerrainId, uint prix) public tokenOwner(msg.sender){
        require(MaisonToken(maisonToken).isOwnerOf(MaisonId));//verifies if the owner of the ERC998 
        require(TerrainToken(terrainToken).isOwnerOf(TerrainId));//token owns both of ERC721 tokens
        package[incrementId] = Package(msg.sender, incrementId, MaisonId, TerrainId, prix, false);
        emit Transfer(msg.sender, msg.sender, incrementId);
        incrementId++;
    }

    function statutVente(uint id, bool aVendre) public tokenOwner(msg.sender){// changes selling status
        require(package[id].owner == msg.sender);
        package[id].aVendre = aVendre;
    }

    function modifierPrix(uint id, uint prix) public{// modifing selling price
        require(package[id].owner == msg.sender);
        package[id].prix = prix;
    }

    function acheter(uint id) public {//byer transfer [prix] ETH and gets the token
        require(package[id].aVendre);
        package[id].owner.transfer(package[id].prix);
        safeTransferFrom(package[id].owner, msg.sender, id);
        package[id].aVendre = false;
    }

}