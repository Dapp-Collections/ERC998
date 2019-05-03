var Terrain = artifacts.require("../contracts/TerrainToken.sol");
var Maison = artifacts.require("../contracts/MaisonToken.sol");
var Package = artifacts.require("../contracts/PackageToken.sol");

module.exports = function(deployer) {

    // Deploy the TerrainToken contract
    deployer.deploy(Terrain)
    // Wait until the TerrainToken contract is deployed
    .then(() => Terrain.deployed())
    // Same for MaisonToken
    .then(() => deployer.deploy(Maison))
    .then(() => Maison.deployed())
    // Deploy the PackageToken contract, while passing the address of the MaisonToken and TerrainToken
    .then(() => deployer.deploy(Package, Maison.address, Terrain.address));
}