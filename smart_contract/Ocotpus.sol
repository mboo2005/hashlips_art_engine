// SPDX-License-Identifier: MIT

/*
                                             ,
                                            ,o
                                            :o
                   _....._                  `:o
                 .'       ``-.                \o
                /  _      _   \                \o
               :  /*\    /*\   )                ;o
               |  \_/    \_/   /                ;o
               (       U      /                 ;o
                \  (\_____/) /                  /o
                 \   \_m_/  (                  /o
                  \         (                ,o:
                  )          \,           .o;o'           ,o'o'o.
                ./          /\o;o,,,,,;o;o;''         _,-o,-'''-o:o.
 .             ./o./)        \    'o'o'o''         _,-'o,o'         o
 o           ./o./ /       .o \.              __,-o o,o'
 \o.       ,/o /  /o/)     | o o'-..____,,-o'o o_o-'
 `o:o...-o,o-' ,o,/ |     \   'o.o_o_o_o,o--''
 .,  ``o-o'  ,.oo/   'o /\.o`.
 `o`o-....o'o,-'   /o /   \o \.                       ,o..         o
   ``o-o.o--      /o /      \o.o--..          ,,,o-o'o.--o:o:o,,..:o
                 (oo(          `--o.o`o---o'o'o,o,-'''        o'o'o
                  \ o\              ``-o-o''''
   ,-o;o           \o \
  /o/               )o )
 (o(               /o /                |
  \o\.       ...-o'o /             \   |
    \o`o`-o'o o,o,--'       ~~~~~~~~\~~|~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ```o--'''                       \| /
                                       |/
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                       |
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

pragma solidity ^0.8.0;
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import 'erc721a/contracts/ERC721A.sol';
import './MerkleDistributor.sol';

contract CyberOctopus is ERC721A, MerkleDistributor, ReentrancyGuard, Ownable{
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_ALLOWLIST_MINT = 3;
    uint256 public constant MAX_PUBLIC_MINT = 3;
    uint256 public constant MAX_RESERVE_SUPPLY = 360;

    uint256 public pricePerToken = 0.001 ether;
    string public provenance;
    string private _baseURIextended;
    bool public saleActive;
    uint256 public reserveSupply;

    address payable public immutable shareholderAddress;

    constructor() ERC721A("CyberOctopus Oracle", "OCTOPUS") {

    }

    modifier ableToMint(uint256 numberOfTokens) {
        require(totalSupply() + numberOfTokens <= MAX_SUPPLY, 'Purchase would exceed max tokens');
        _;
    }

    modifier isPublicSaleActive() {
        require(saleActive, 'Public sale is not active');
        _;
    }

    /**
     * admin
     */
    function devMint(uint256 numberOfTokens) external onlyOwner ableToMint(numberOfTokens) nonReentrant {
        require(reserveSupply + numberOfTokens <= MAX_RESERVE_SUPPLY, 'Number would exceed max reserve supply');

        reserveSupply += numberOfTokens;
        _safeMint(msg.sender, numberOfTokens);
    }

    function devMintToAddress(uint256 numberOfTokens, address _receiver) external onlyOwner ableToMint(numberOfTokens) nonReentrant {
        require(reserveSupply + numberOfTokens <= MAX_RESERVE_SUPPLY, 'Number would exceed max reserve supply');

        reserveSupply += numberOfTokens;
        _safeMint(_receiver, numberOfTokens);
    }

    function setSaleActive(bool state) external onlyOwner {
        saleActive = state;
    }
    /**
    * set price per token 
    */
    function setPrice(uint256 _cost) external onlyOwner {
        pricePerToken = _cost;
    }
    /**
    * start token id from 1
    */
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function contractURI() public view returns (string memory) {
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, "meta"))
            : '';
    }

    /**
     * allow list
     */
    function setAllowListActive(bool allowListActive) external onlyOwner {
        _setAllowListActive(allowListActive);
    }

    function setAllowList(bytes32 merkleRoot) external onlyOwner {
        _setAllowList(merkleRoot);
    }

    /**
     * tokens
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }
    //https://medium.com/coinmonks/the-elegance-of-the-nft-provenance-hash-solution-823b39f99473
    function setProvenance(string memory provenance_) external onlyOwner {
        provenance = provenance_;
    }


    /**
     * public
     */
    function mintAllowList(uint256 numberOfTokens, bytes32[] memory merkleProof)
        external
        payable
        isAllowListActive
        ableToClaim(msg.sender, merkleProof)
        tokensAvailable(msg.sender, numberOfTokens, MAX_ALLOWLIST_MINT)
        ableToMint(numberOfTokens)
        nonReentrant
    {
        require(numberOfTokens * pricePerToken == msg.value, 'Ether value sent is not correct');

        _setAllowListMinted(msg.sender, numberOfTokens);
        _safeMint(msg.sender, numberOfTokens);
    }

    function mint(uint256 numberOfTokens) external payable isPublicSaleActive ableToMint(numberOfTokens) nonReentrant {
        require(numberOfTokens <= MAX_PUBLIC_MINT, 'Exceeded max token purchase');
        require(numberOfTokens * pricePerToken == msg.value, 'Ether value sent is not correct');

        _safeMint(msg.sender, numberOfTokens);
    }

    /**
     * withdraw
     */
    function withdraw() external onlyOwner nonReentrant {
         (bool success, ) = payable(owner()).call{value: address(this).balance}('');
        require(success, 'Transfer failed.');
    }
}