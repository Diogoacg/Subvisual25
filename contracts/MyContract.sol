// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    uint256 public constant MINT_LIMIT = 100 * 10**18; // Limite de 100 tokens por mint
    mapping(address => uint256) public lastMintTime;
    uint256 public constant MINT_COOLDOWN = 1 days; // Cooldown de 1 dia entre mints

    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    // Função para queimar tokens
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Função para qualquer pessoa mintar tokens com limites
    function publicMint(uint256 amount) public {
        require(amount <= MINT_LIMIT, "Limite de mint excedido");
        require(block.timestamp >= lastMintTime[msg.sender] + MINT_COOLDOWN, "Aguarde o cooldown");
        
        lastMintTime[msg.sender] = block.timestamp;
        _mint(msg.sender, amount);
    }

    // Função para o dono mintar sem limites
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}