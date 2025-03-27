// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SubvisualNFT.sol";

contract SubvisualNFTTest is Test {
    SubvisualNFT public nft;
    address public owner = address(1);
    address public user = address(2);

    function setUp() public {
        nft = new SubvisualNFT(owner);
    }

    function testMint() public {
        vm.prank(user);
        nft.safeMint(user);
        assertEq(nft.ownerOf(0), user);
        assertEq(nft.totalSupply(), 1);
    }

    function testMaxSupply() public {
        vm.startPrank(user);
        
        for (uint256 i = 0; i < nft.MAX_SUPPLY(); i++) {
            nft.safeMint(user);
        }
        
        vm.expectRevert("Max supply reached");
        nft.safeMint(user);
        
        vm.stopPrank();
    }
}