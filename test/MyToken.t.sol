// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/MyContract.sol";

contract MyTokenTest is Test {
    MyToken token;
    address testUser = address(0x1);  // Test user address
    address anotherUser = address(0x2); // Second test user
    uint256 initialSupply = 1000 * 10 ** 18; // Initial token supply
    
    function setUp() public {
        // Instancia o contrato com um supply inicial
        token = new MyToken(initialSupply);
    }

    // Teste 1: Verificar o supply inicial
    function testInitialSupply() public view {
        uint256 totalSupply = token.totalSupply();
        assertEq(totalSupply, initialSupply, "Supply inicial incorreto");
    }

    // Teste 2: Verificar a função burn
    function testBurn() public {
        uint256 burnAmount = 100 * 10 ** 18;
        token.burn(burnAmount);
        uint256 remainingSupply = token.totalSupply();
        assertEq(remainingSupply, initialSupply - burnAmount, "Burn nao funcionou corretamente");
    }

    // Teste 3: Verificar que um usuário não pode queimar mais do que possui
    function testCannotBurnMoreThanBalance() public {
        // Transfere alguns tokens para o testUser
        uint256 transferAmount = 50 * 10 ** 18;
        token.transfer(testUser, transferAmount);
        
        // Tenta queimar mais do que possui
        vm.startPrank(testUser);
        
        // Use vm.expectRevert() without specific message
        // This works for both string errors and custom errors
        vm.expectRevert();
        token.burn(transferAmount + 1);
        
        vm.stopPrank();
    }

    // Teste 4: Verificar a função publicMint com um usuário diferente
    function testPublicMint() public {
        uint256 supply = token.totalSupply();
        uint256 mintAmount = 50 * 10 ** 18;
        
        // Inicializar o lastMintTime para permitir o mint
        vm.warp(block.timestamp + 1 days); // Avança o tempo para garantir que não há cooldown

        // Muda para o usuário de teste
        vm.startPrank(testUser);
        token.publicMint(mintAmount);
        vm.stopPrank();
        
        uint256 newSupply = token.totalSupply();
        assertEq(newSupply, supply + mintAmount, "Public mint nao funcionou corretamente");
        assertEq(token.balanceOf(testUser), mintAmount, "Saldo do usuario nao foi atualizado corretamente");
    }

    // Teste 5: Verificar o cooldown
    function testMintCooldown() public {
        uint256 mintAmount = 50 * 10 ** 18;
        
        // Avança o tempo para garantir que não há cooldown inicial
        vm.warp(block.timestamp + 1 days);
        
        // Primeiro mint com usuário de teste
        vm.startPrank(testUser);
        token.publicMint(mintAmount);
        
        // Tenta mintar novamente sem esperar o cooldown - deve falhar
        vm.expectRevert("Aguarde o cooldown");
        token.publicMint(mintAmount);
        
        // Avança o tempo para passar o cooldown
        vm.warp(block.timestamp + 1 days + 1); 
        
        // Agora deve funcionar
        token.publicMint(mintAmount);
        vm.stopPrank();
        
        // Verifica se o saldo do usuário é correto (recebeu 2x o mintAmount)
        assertEq(token.balanceOf(testUser), 2 * mintAmount, "Cooldown nao funcionou corretamente");
    }

    // Teste 6: Verificar o limite de mint público
    function testPublicMintLimit() public {
        uint256 mintAmount = 101 * 10 ** 18; // Acima do limite
        
        // Avança o tempo para garantir que não há cooldown
        vm.warp(block.timestamp + 1 days);
        
        vm.startPrank(testUser);
        vm.expectRevert("Limite de mint excedido");
        token.publicMint(mintAmount);
        vm.stopPrank();
        
        // Verifica que nenhum token foi mintado
        assertEq(token.balanceOf(testUser), 0, "Tokens foram mintados mesmo acima do limite");
    }

    // Teste 7: Verificar a função mint (apenas owner)
    function testOwnerMint() public {
        uint256 mintAmount = 500 * 10 ** 18;
        uint256 supply = token.totalSupply();
        
        // Owner deve conseguir mintar
        token.mint(anotherUser, mintAmount);
        
        // Verifica que os tokens foram mintados corretamente
        assertEq(token.balanceOf(anotherUser), mintAmount, "Mint do owner falhou");
        assertEq(token.totalSupply(), supply + mintAmount, "Supply total nao foi atualizado");
    }

    // Teste 8: Verificar que apenas owner pode chamar a função mint
    function testNonOwnerCannotMint() public {
        uint256 mintAmount = 100 * 10 ** 18;
        
        vm.startPrank(testUser);
        vm.expectRevert();
        token.mint(testUser, mintAmount);
        vm.stopPrank();
    }

    // Teste 9: Verificar metadata do token
    function testTokenMetadata() public view {
        assertEq(token.name(), "MyToken", "Nome incorreto");
        assertEq(token.symbol(), "MTK", "Simbolo incorreto");
        assertEq(token.decimals(), 18, "Decimais incorretos");
    }
    
    // Teste 10: Verificar transferência de ownership
    function testTransferOwnership() public {
        // Transferir ownership para testUser
        token.transferOwnership(testUser);
        assertEq(token.owner(), testUser, "Transferencia de ownership falhou");
        
        // Apenas o novo owner deve poder chamar funções onlyOwner
        vm.startPrank(testUser);
        token.mint(anotherUser, 100 * 10 ** 18);
        vm.stopPrank();
        
        // Original owner não deve mais poder chamar funções onlyOwner
        vm.expectRevert();
        token.mint(anotherUser, 100 * 10 ** 18);
    }

    // Teste 11: Verificar atualização do lastMintTime
    function testLastMintTimeUpdate() public {
        // Avança o tempo primeiro para garantir que não há cooldown
        vm.warp(block.timestamp + 1 days);
        
        vm.startPrank(testUser);
        
        // Primeiro mint: lastMintTime deve ser atualizado
        uint256 currentTime = block.timestamp;
        token.publicMint(10 * 10 ** 18);
        assertEq(token.lastMintTime(testUser), currentTime, "lastminttime nao foi atualizado corretamente");
        
        vm.stopPrank();
    }

    // Teste 12: Verificar constantes do contrato
    function testContractConstants() public view {
        assertEq(token.MINT_LIMIT(), 100 * 10 ** 18, "MINT_LIMIT incorreto");
        assertEq(token.MINT_COOLDOWN(), 1 days, "MINT_COOLDOWN incorreto");
    }
}