// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SimpleNFT.sol";

contract SimpleNFTTest is Test {
    SimpleNFT public nft;
    address public owner = address(1);
    address public user = address(2);
    
    function setUp() public {
        vm.startPrank(owner);
        nft = new SimpleNFT("SimpleNFT", "SNFT", "https://example.com/metadata/");
        vm.stopPrank();
    }
    
    function testMint() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        
        uint256 initialBalance = user.balance;
        uint256 initialSupply = nft.totalSupply();
        
        nft.mint{value: 0.01 ether}();
        
        assertEq(nft.totalSupply(), initialSupply + 1);
        assertEq(nft.ownerOf(1), user);
        assertEq(user.balance, initialBalance - 0.01 ether);
        
        vm.stopPrank();
    }
    
    // Renomeado e atualizado para usar vm.expectRevert
    function test_RevertWhen_InsufficientPayment() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        
        // Esperando que reverta com a mensagem específica
        vm.expectRevert("Insufficient payment");
        nft.mint{value: 0.005 ether}();
        
        vm.stopPrank();
    }
    
    function testTokenURI() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        
        nft.mint{value: 0.01 ether}();
        string memory uri = nft.tokenURI(1);
        
        assertEq(uri, "https://example.com/metadata/1.json");
        
        vm.stopPrank();
    }
    
    function testWithdraw() public {
        vm.startPrank(user);
        vm.deal(user, 1 ether);
        nft.mint{value: 0.01 ether}();
        vm.stopPrank();
        
        vm.startPrank(owner);
        uint256 initialBalance = owner.balance;
        nft.withdraw();
        assertEq(owner.balance, initialBalance + 0.01 ether);
        vm.stopPrank();
    }
}