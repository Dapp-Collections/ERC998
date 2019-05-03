pragma solidity >= 0.4.24; 

import "../openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol"; 

contract MaisonToken is ERC721, Ownable {

    struct Maison //Maison attributes
    {
        address payable owner; // the adress is payable so we can buy the house with eth
        uint Id;// id of the house for the mapping
        uint superficie;
        uint nbVolets;
        string couleurVolet;

        uint prix;// price of the house(used when selling it)
        bool aVendre;// tells if the owner is trying to sell the house
    }

    string public name;
    string public ticker;
    uint incrementId;//used to get new ids (for mapping)

    mapping(address => bool) owners;//whitelist
    mapping(uint => Maison) maisons;//id to token

    constructor() public { 
        ticker = "MTK"; 
        name = "MaisonToken";
        incrementId = 0;
    }

    function RegisterOwner(address addr) public {//add to whitelist
        require(msg.sender == owner());
        require(owners[addr] == false);
        
        owners[addr] = true;
    }

    function isOwnerOf(uint id) public view returns(bool){//checks if owner of house
        return maisons[id].owner == msg.sender;
    }

    function declareMaison(uint superficie, uint nbVolets, string memory couleurVolets, uint prix) public {
        maisons[incrementId] = Maison(msg.sender, incrementId, superficie, nbVolets, couleurVolets,prix,false);
        emit Transfer(msg.sender, msg.sender, incrementId);
        incrementId++;
    }

    function statutVente(uint id, bool aVendre) public{// changes selling status
        require(maisons[id].owner == msg.sender);
        maisons[id].aVendre = aVendre;
    }

    function modifierPrix(uint id, uint prix) public{// modifing selling price
        require(maisons[id].owner == msg.sender);
        maisons[id].prix = prix;
    }

    function acheter(uint id) public {//byer transfer [prix] ETH and gets the house token
        require(maisons[id].aVendre);
        maisons[id].owner.transfer(maisons[id].prix);
        safeTransferFrom(maisons[id].owner, msg.sender, id);
        maisons[id].aVendre = false;
    }

}