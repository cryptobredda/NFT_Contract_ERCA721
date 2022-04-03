// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";



contract ContractName is ERC721A, Ownable {
  
    uint256 price = 0.01 ether;
    uint256 _maxSupply = 3000;
    uint256 maxMintAmountPerTx = 2;
    uint256 maxMintAmountPerWallet = 2;

    string baseURL = "";
    string ExtensionURL = ".json";
    string HiddenURL;

    bool whitelistFeature = false;
    bytes32 hashRoot;

    bool paused = false;
    bool revealed = false;


    //          string memory hidden, string memory base, bytes32 hashroot   <= For constructor
    constructor() ERC721A("Kaori", "KO") {

    }

    // ================= Mint Function =======================

    function Mint(address to, uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable{
        require(!paused, "The contract is paused!");
        require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, "Invalid mint amount!");
        require(totalSupply() + _mintAmount <= _maxSupply, "Max supply exceeded!");
        require(msg.value >= price * _mintAmount, "You dont have enough funds!");
        require(balanceOf(msg.sender) + _mintAmount <= maxMintAmountPerWallet, "Max mint per wallet exceeded!");

        if(whitelistFeature){
            require(checkHashProof(_merkleProof), "You are not whitelisted!");
        }
  

        _safeMint(to, _mintAmount);
    }

    // =================== Orange Functions (Owner Only) ===============

    function pause(bool state) public onlyOwner {
        paused = state;
    }

    function safeMint(address to, uint256 quantity) public onlyOwner {
        _safeMint(to, quantity);
    }

    function setHiddenURL(string memory uri) public onlyOwner {
        HiddenURL = uri;
    }

    function setbaseURL(string memory uri) public onlyOwner{
        baseURL = uri;
    }

    function setExtensionURL(string memory uri) public onlyOwner{
        ExtensionURL = uri;
    }

    // ====================== Whitelist Feature ============================

    function setwhitelistFeature(bool state) public onlyOwner{
        whitelistFeature = state;
    }

    function setHashRoot(bytes32 hp)public onlyOwner{
        hashRoot = hp;
    }

    function checkHashRoot() view public onlyOwner returns (bytes32){
        return hashRoot;
    }

    function checkHashProof(bytes32[] calldata _merkleProof) view internal returns (bool){
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if(MerkleProof.verify(_merkleProof, hashRoot, leaf)){
            return true;
        }

        return false;
    }

    // ================================ Withdraw Function ====================

    function withdraw() public onlyOwner {
        uint256 CurrentContractBalance = address(this).balance;

        (bool os, ) = payable(owner()).call{value: CurrentContractBalance}("");
        require(os);

    }

    // =================== Blue Functions (View Only) ====================

    function tokenURI(uint256 tokenId) public view override(ERC721A) returns (string memory){
        require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");

    if (revealed == false) {
      return HiddenURL;
    }

        return super.tokenURI(tokenId);
    }

    function checkWhitelist() public view returns (bool){
        return whitelistFeature;
    }


    function cost() public view returns (uint256){
        return price;
    }

    function _baseURI() internal view virtual override returns (string memory) {
    return baseURL;
    }


    function maxSupply() public view returns (uint256){
        return _maxSupply;
    }
    
    // ================ Internal Functions ===================
    
}