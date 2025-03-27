// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SubvisualNFT is ERC721, Ownable {
    uint256 private _nextTokenId;
    uint256 public constant MAX_SUPPLY = 1000;

    constructor(address initialOwner)
        ERC721("SubvisualNFT", "SVNFT")
        Ownable(initialOwner)
    {}

    function safeMint(address to) public {
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }
}