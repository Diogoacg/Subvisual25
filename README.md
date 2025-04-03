# Projeto MyToken - dApp Subvisual25

Este README fornece instruções detalhadas sobre como configurar, executar e interagir com o projeto MyToken, uma aplicação descentralizada (dApp) desenvolvida para o desafio da Subvisual.

## Índice

- Visão Geral
- Requisitos
- Instalação e Execução Local
- Executar os Testes
- Implementar o Contrato no Remix
- Funcionalidades da Aplicação

## Visão Geral

O projeto consiste em:

- **Contrato Inteligente MyToken**: Um token ERC20 com funcionalidades adicionais como:
  - Queima de tokens (burn)
  - Criação pública de tokens (publicMint) com limites e período de espera
  - Criação reservada ao proprietário (mint)

- **Interface Web**: Uma aplicação React que permite aos utilizadores interagir com o contrato inteligente através do MetaMask.

## Requisitos

- **Node.js** (v14+)
- **npm** ou **yarn**
- **Foundry** (para testes de contrato)
- **MetaMask** (para interagir com a aplicação)

## Instalação e Execução Local

### 1. Clonar o repositório

```bash
git clone https://github.com/seu-utilizador/Subvisual25.git
cd Subvisual25
```

### 2. Instalar dependências do contrato

```bash
forge install
```

### 3. Configurar e iniciar a aplicação frontend

```bash
cd subvisual-dapp
npm install
npm start
```

A aplicação estará disponível no endereço `http://localhost:3000`.

### 4. Conectar ao MetaMask

1. Certifique-se de que a extensão MetaMask está instalada no seu navegador
2. Configure o MetaMask para uma rede de teste como Sepolia ou Goerli
3. Clique no botão "Conectar Carteira" na aplicação

## Executar os Testes

O projeto utiliza Foundry para testes dos contratos inteligentes:

```bash
forge test
```

Para ver informações detalhadas sobre os testes:

```bash
forge test -vvv
```

## Implementar o Contrato no Remix

O Remix IDE é uma forma fácil de implementar o contrato numa rede de teste ou na mainnet.

### 1. Aceder ao Remix IDE

Abra o [Remix IDE](https://remix.ethereum.org/) no seu navegador.

### 2. Criar um novo ficheiro para o contrato

1. Clique em "File Explorer" (ícone de pasta)
2. Clique em "Create New File" (+)
3. Atribua o nome `MyToken.sol` ao ficheiro

### 3. Copiar o código do contrato

Copie o conteúdo do ficheiro MyContract.sol do projeto e cole-o no Remix.

```solidity
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
```

### 4. Compilar o contrato

1. Selecione a aba "Solidity Compiler" (ícone com o "S")
2. Selecione a versão do compilador (0.8.x)
3. Clique no botão "Compile MyToken.sol"

### 5. Implementar o contrato

1. Selecione a aba "Deploy & Run Transactions" (ícone de seta para cima)
2. Certifique-se de que o ambiente está configurado para "Injected Provider - MetaMask" para implementar numa rede real
3. Selecione o contrato "MyToken" no menu suspenso
4. Adicione o parâmetro de entrada para o construtor (ex.: 1000000000000000000000 para 1000 tokens com 18 casas decimais)
5. Clique no botão "Deploy" e confirme a transação no MetaMask

### 6. Obter o endereço do contrato implementado

Após a implementação, o contrato aparecerá na secção "Deployed Contracts". Copie o endereço do contrato para usá-lo na aplicação.

### 7. Atualizar o endereço do contrato na aplicação

Abra o ficheiro App.js e atualize a variável `contractAddress` com o endereço do contrato recém-implementado:

```javascript
const contractAddress = "0xSeuEndereçoDoContratoAqui";
```

## Funcionalidades da Aplicação

A aplicação oferece as seguintes funcionalidades:

1. **Conectar à carteira MetaMask**
   - Exibe o endereço atual conectado e o saldo de tokens

2. **Mint Público**
   - Qualquer utilizador pode criar até 100 tokens por vez
   - Há um período de espera de 1 dia entre criações
   - A interface mostra quando será possível criar novos tokens

3. **Queimar Tokens**
   - Os utilizadores podem destruir os seus próprios tokens

4. **Mint de Proprietário**
   - O proprietário do contrato pode criar uma quantidade ilimitada de tokens
   - O proprietário pode criar tokens para qualquer endereço