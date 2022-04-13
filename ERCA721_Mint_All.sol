// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract ContractName is ERC721A, Ownable, ReentrancyGuard {
  
    uint256 price = 0.01 ether;
    uint256 _maxSupply = 3000;
    uint256 maxMintAmountPerTx = 2;
    uint256 maxMintAmountPerWallet = 2;

    string baseURL = "";
    string ExtensionURL = ".json";
    string HiddenURL;

    bool revealed = false;


    //          string memory hidden, string memory base, bytes32 hashroot   <= For constructor
    constructor( string memory _name, string memory _symbol, string memory _initBaseURI, string memory _initNotRevealedUri
    ) ERC721A(_name, _symbol) {
        baseURL = _initBaseURI;
        HiddenURL = _initNotRevealedUri;
        for (uint256 i = 1; i <=_maxSupply; i++) {
        _safeMint(msg.sender, 1);
        }
    }

    // =================== Orange Functions (Owner Only) ===============


    function safeMint(address to, uint256 quantity) public onlyOwner {
        _safeMint(to, quantity);
    }

    function setHiddenURL(string memory uri) public onlyOwner {
        HiddenURL = uri;
    }
    
    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setbaseURL(string memory uri) public onlyOwner{
        baseURL = uri;
    }

    function setExtensionURL(string memory uri) public onlyOwner{
        ExtensionURL = uri;
    }





    // ================================ Withdraw Function ====================

    function withdraw() public onlyOwner nonReentrant{
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

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), ExtensionURL))
            : '';
    }


    function _baseURI() internal view virtual override returns (string memory) {
    return baseURL;
    }
    
    // ================ Internal Functions ===================
    
}
