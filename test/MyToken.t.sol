// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/MyContract.sol";

contract MyTokenTest is Test {
    MyToken token;
    address testUser = address(0x1);  // Endereço do utilizador de teste
    address anotherUser = address(0x2); // Segundo endereço para testes
    uint256 initialSupply = 1000 * 10 ** 18; // Fornecimento inicial de tokens (1000 tokens)
    
    function setUp() public {
        // Instancia o contrato com um fornecimento inicial
        token = new MyToken(initialSupply);
    }

    // Teste 1: Confirmar que o fornecimento inicial está correto
    function testInitialSupply() public view {
        uint256 totalSupply = token.totalSupply();
        assertEq(totalSupply, initialSupply, "Fornecimento inicial incorreto");
    }

    // Teste 2: Verificar se a função burn (queima de tokens) funciona corretamente
    function testBurn() public {
        uint256 burnAmount = 100 * 10 ** 18; // 100 tokens para queimar
        token.burn(burnAmount);
        uint256 remainingSupply = token.totalSupply();
        // Confirma que o fornecimento total foi reduzido pelo valor queimado
        assertEq(remainingSupply, initialSupply - burnAmount, "A queima nao funcionou corretamente");
    }

    // Teste 3: Garantir que um utilizador não pode queimar mais tokens do que possui
    function testCannotBurnMoreThanBalance() public {
        // Transfere alguns tokens para o utilizador de teste
        uint256 transferAmount = 50 * 10 ** 18; // 50 tokens
        token.transfer(testUser, transferAmount);
        
        // Tentativa de queimar mais do que possui (deveria falhar)
        vm.startPrank(testUser); // Simula ações como sendo o utilizador de teste
        
        // Utiliza vm.expectRevert() sem mensagem específica
        // Isto funciona para erros personalizados e mensagens de erro
        vm.expectRevert();
        token.burn(transferAmount + 1);
        
        vm.stopPrank(); // Termina a simulação como utilizador de teste
    }

    // Teste 4: Verificar se a função publicMint permite a um utilizador normal criar tokens
    function testPublicMint() public {
        uint256 supply = token.totalSupply();
        uint256 mintAmount = 50 * 10 ** 18; // 50 tokens para criar
        
        // Avança o tempo para garantir que não há período de espera
        vm.warp(block.timestamp + 1 days); // Avança o tempo em 1 dia

        // Muda para o utilizador de teste
        vm.startPrank(testUser);
        token.publicMint(mintAmount);
        vm.stopPrank();
        
        // Verifica se os tokens foram criados corretamente
        uint256 newSupply = token.totalSupply();
        assertEq(newSupply, supply + mintAmount, "A criacao publica nao funcionou corretamente");
        assertEq(token.balanceOf(testUser), mintAmount, "O saldo do utilizador nao foi atualizado corretamente");
    }

    // Teste 5: Verificar se o período de espera (cooldown) entre mints funciona
    function testMintCooldown() public {
        uint256 mintAmount = 50 * 10 ** 18; // 50 tokens
        
        // Avança o tempo para garantir que não há período de espera inicial
        vm.warp(block.timestamp + 1 days);
        
        // Primeiro mint com utilizador de teste
        vm.startPrank(testUser);
        token.publicMint(mintAmount);
        
        // Tenta mintar novamente sem esperar o período de espera - deve falhar
        vm.expectRevert("Aguarde o cooldown");
        token.publicMint(mintAmount);
        
        // Avança o tempo para passar o período de espera
        vm.warp(block.timestamp + 1 days + 1); 
        
        // Agora deve funcionar
        token.publicMint(mintAmount);
        vm.stopPrank();
        
        // Verifica se o saldo do utilizador está correto (recebeu 2x o mintAmount)
        assertEq(token.balanceOf(testUser), 2 * mintAmount, "O periodo de espera nao funcionou corretamente");
    }

    // Teste 6: Verificar se o limite de criação pública é respeitado
    function testPublicMintLimit() public {
        uint256 mintAmount = 101 * 10 ** 18; // 101 tokens (acima do limite)
        
        // Avança o tempo para garantir que não há período de espera
        vm.warp(block.timestamp + 1 days);
        
        // Tenta criar acima do limite - deve falhar
        vm.startPrank(testUser);
        vm.expectRevert("Limite de mint excedido");
        token.publicMint(mintAmount);
        vm.stopPrank();
        
        // Verifica que nenhum token foi criado
        assertEq(token.balanceOf(testUser), 0, "Tokens foram criados mesmo acima do limite");
    }

    // Teste 7: Verificar se a função mint (apenas proprietário) funciona corretamente
    function testOwnerMint() public {
        uint256 mintAmount = 500 * 10 ** 18; // 500 tokens
        uint256 supply = token.totalSupply();
        
        // O proprietário deve conseguir criar tokens
        token.mint(anotherUser, mintAmount);
        
        // Verifica se os tokens foram criados corretamente
        assertEq(token.balanceOf(anotherUser), mintAmount, "A criacao pelo proprietario falhou");
        assertEq(token.totalSupply(), supply + mintAmount, "O fornecimento total nao foi atualizado");
    }

    // Teste 8: Garantir que apenas o proprietário pode chamar a função mint
    function testNonOwnerCannotMint() public {
        uint256 mintAmount = 100 * 10 ** 18; // 100 tokens
        
        // Um utilizador normal não deve conseguir chamar mint
        vm.startPrank(testUser);
        vm.expectRevert();
        token.mint(testUser, mintAmount);
        vm.stopPrank();
    }

    // Teste 9: Verificar os metadados do token
    function testTokenMetadata() public view {
        assertEq(token.name(), "MyToken", "Nome incorreto");
        assertEq(token.symbol(), "MTK", "Simbolo incorreto");
        assertEq(token.decimals(), 18, "Numero de casas decimais incorreto");
    }
    
    // Teste 10: Verificar a transferência de propriedade do contrato
    function testTransferOwnership() public {
        // Transferir propriedade para o utilizador de teste
        token.transferOwnership(testUser);
        assertEq(token.owner(), testUser, "A transferencia de propriedade falhou");
        
        // Apenas o novo proprietário deve poder chamar funções onlyOwner
        vm.startPrank(testUser);
        token.mint(anotherUser, 100 * 10 ** 18);
        vm.stopPrank();
        
        // O proprietário original não deve conseguir chamar funções onlyOwner
        vm.expectRevert();
        token.mint(anotherUser, 100 * 10 ** 18);
    }

    // Teste 11: Verificar se o registo de tempo da última criação é atualizado
    function testLastMintTimeUpdate() public {
        // Avança o tempo primeiro para garantir que não há período de espera
        vm.warp(block.timestamp + 1 days);
        
        vm.startPrank(testUser);
        
        // Primeira criação: lastMintTime deve ser atualizado
        uint256 currentTime = block.timestamp;
        token.publicMint(10 * 10 ** 18);
        assertEq(token.lastMintTime(testUser), currentTime, "O registo de tempo da ultima criacao nao foi atualizado corretamente");
        
        vm.stopPrank();
    }

    // Teste 12: Verificar as constantes do contrato
    function testContractConstants() public view {
        assertEq(token.MINT_LIMIT(), 100 * 10 ** 18, "MINT_LIMIT incorreto");
        assertEq(token.MINT_COOLDOWN(), 1 days, "MINT_COOLDOWN incorreto");
    }
}