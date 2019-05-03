pragma solidity >= 0.4.24; 

import "../openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "../openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../contracts/MaisonToken.sol";
import "../contracts/TerrainToken.sol";

contract PropertyToken is ERC721, Ownable {

   struct Property
    {
        address payable owner;
        uint Id;
        uint propertyd;
        uint TerrainId;

        bool complete;
        uint prix;
        bool aVendre;
    }

    string public name;
    string public ticker;
    uint incrementId;

    mapping(address => bool) owners;
    mapping(uint => Property) property;

    constructor() public { 
        ticker = "PTK"; 
        name = "PropertyToken";
        incrementId = 0;
    }

    function RegisterOwner(address addr) public {
        require(msg.sender == owner());
        require(owners[addr] == false);
        
        owners[addr] = true;
    }

    function declareproperty(uint MaisonId, uint TerrainId, uint prix) public {
        require(MaisonToken.isOwnerof(MaisonId));
        require(TerrainToken.isOwnerof(MaisonId));
        property[incrementId] = Property(msg.sender, incrementId, MaisonId, TerrainId, true, prix, false);
        emit Transfer(msg.sender, msg.sender, incrementId);
        incrementId++;
    }

    function statutVente(uint id, bool aVendre) public{
        require(property[id].owner == msg.sender);
        property[id].aVendre = aVendre;
    }

    function modifierPrix(uint id, uint prix) public{
        require(property[id].owner == msg.sender);
        property[id].prix = prix;
    }

    function acheter(uint id) public {
        require(property[id].aVendre);
        property[id].owner.transfer(property[id].prix);
        safeTransferFrom(property[id].owner, msg.sender, id);
        property[id].aVendre = false;
    }

}