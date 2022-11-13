
//SPDX-License-Identifier: GPL-3.0
 pragma solidity ^0.8.7;
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol";
 contract AirdropandMint_contract is ERC721A , Ownable {
  using StringsUpgradeable for uint256;

  uint public maxNFT = 8000;
  uint public maxFREE_mintperwallet = 1;
  uint public  maxMINTperTransaction = 21;
  uint public  PriceperNFT = 1 ether;
  string public suffix = "json";
  string uriPrefix;
  bool paused = true;

  mapping(address => uint) public No_of_NFT_wallet;
  constructor(string memory _name,string memory _symbol) ERC721A(_name,_symbol)
  {}

function mint(uint amount) public payable {
    //130535
    //150218
    //150200
    uint totalsupply = uint(totalSupply());
    uint nft = No_of_NFT_wallet[msg.sender];
    require(totalsupply + amount <= maxNFT,"over exceed the limits");
   require(paused, "The contract is paused!");
  require(amount + nft <= maxMINTperTransaction,"over exceed the limits");
  if( nft > maxMINTperTransaction){
      require(msg.value >= amount * PriceperNFT ,"insufficient balance");
  }
  else{
      uint count = amount + nft;
      if(count > maxFREE_mintperwallet){
          count = count - maxFREE_mintperwallet;
          require( msg.value >= count * PriceperNFT,"insufficient balance");
      }
      _safeMint(msg.sender,amount);
      No_of_NFT_wallet[msg.sender] = nft + amount;
  }
  delete amount;
  delete totalsupply;
}
function Airdrop(uint NFTperWallet, address[] calldata addresses) public onlyOwner{
    uint len = addresses.length;
  uint totalsupply = uint(totalSupply());
  uint total = NFTperWallet * len;
  require(total +  totalsupply <= maxNFT,"total supply exceed");
  for(uint i = 0;i<len;i++){
      _safeMint(addresses[i],NFTperWallet);
  }
  delete totalsupply;
  delete total;
}
 function setFreeMaxLimitPerAddress(uint8 _limit) external onlyOwner{
    maxMINTperTransaction = _limit;
   delete _limit;

}
  function tokenURI(uint256 _tokenId )public view virtual override returns (string memory) { 
      require (_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
   
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString() ,suffix)): "";
  }


function setUriPrefix(string memory _uriPrefix) external onlyOwner {
    uriPrefix = _uriPrefix;
  }
 
  function setPaused() external onlyOwner {
    paused = !paused;
   
  }

  function setCost(uint _cost) external onlyOwner{
      PriceperNFT = _cost;

  }


  function setMaxMintAmountPerTx(uint8 _maxtx) external onlyOwner{
      maxMINTperTransaction = _maxtx;

  }

  function withdraw() external onlyOwner {
  uint _balance = address(this).balance;
     payable(msg.sender).transfer(_balance ); 
       
  }

  function _baseURI() internal view  override returns (string memory) {
    return uriPrefix;
  }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}

 
