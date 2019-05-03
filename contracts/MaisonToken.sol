pragma solidity >= 0.4.24; 

import "../openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol"; 


contract MaisonToken is ERC721, Ownable {

    struct Maison
    {
        address payable owner;
        uint Id;
        uint superficie;
        uint nbVolets;
        string couleurVolet;

        uint prix;
        bool aVendre;
    }

    string public name;
    string public ticker;
    uint incrementId;

    mapping(address => bool) owners;
    mapping(uint => Maison) maisons;

    constructor() public { 
        ticker = "MTK"; 
        name = "MaisonToken";
        incrementId = 0;
    }

    function RegisterOwner(address addr) public {
        require(msg.sender == owner());
        require(owners[addr] == false);
        
        owners[addr] = true;
    }

    function isOwnerOf(uint id) public view returns(bool){
        return maisons[id].owner == msg.sender;
    }

    function declareMaison(uint superficie, uint nbVolets, string memory couleurVolets, uint prix) public {
        maisons[incrementId] = Maison(msg.sender, incrementId, superficie, nbVolets, couleurVolets,prix,false);
        emit Transfer(msg.sender, msg.sender, incrementId);
        incrementId++;
    }

    function statutVente(uint id, bool aVendre) public{
        require(maisons[id].owner == msg.sender);
        maisons[id].aVendre = aVendre;
    }

    function modifierPrix(uint id, uint prix) public{
        require(maisons[id].owner == msg.sender);
        maisons[id].prix = prix;
    }

    function acheter(uint id) public {
        require(maisons[id].aVendre);
        maisons[id].owner.transfer(maisons[id].prix);
        safeTransferFrom(maisons[id].owner, msg.sender, id);
        maisons[id].aVendre = false;
    }

}