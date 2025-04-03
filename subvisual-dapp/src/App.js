import { useState, useEffect } from "react";
import { ethers } from "ethers";
import "./styles.css";

function App() {
  const [account, setAccount] = useState(null);
  const [provider, setProvider] = useState(null);
  const [contract, setContract] = useState(null);
  const [tokenBalance, setTokenBalance] = useState("0");
  const [burnAmount, setBurnAmount] = useState("");
  const [mintAmount, setMintAmount] = useState("");
  const [mintAddress, setMintAddress] = useState("");
  const [publicMintAmount, setPublicMintAmount] = useState("");
  const [isOwner, setIsOwner] = useState(false);
  const [nextMintTime, setNextMintTime] = useState(null);

  // Substitua pelo NOVO endereço do contrato reimplantado
  const contractAddress = "0x09c562fB23c1b81e7B497001Bc1b57BA2a02B8D2";
  
  // ABI atualizado com todas as funções do contrato
  const contractABI = [
    "function balanceOf(address owner) view returns (uint256)",
    "function burn(uint256 amount)",
    "function mint(address to, uint256 amount)",
    "function publicMint(uint256 amount)",
    "function MINT_LIMIT() view returns (uint256)",
    "function lastMintTime(address user) view returns (uint256)",
    "function MINT_COOLDOWN() view returns (uint256)",
    "function name() view returns (string)",
    "function symbol() view returns (string)",
    "function totalSupply() view returns (uint256)",
    "function decimals() view returns (uint8)",
    "function owner() view returns (address)"
  ];

  useEffect(() => {
    if (window.ethereum) {
      const ethProvider = new ethers.BrowserProvider(window.ethereum);
      setProvider(ethProvider);
    }
  }, []);

  // Função para verificar quando o usuário pode mintar novamente
  const checkNextMintTime = async () => {
    if (!contract || !account) return;
    
    try {
      const lastMint = await contract.lastMintTime(account);
      const cooldown = await contract.MINT_COOLDOWN();
      
      if (lastMint > 0) {
        const nextTime = Number(lastMint) + Number(cooldown);
        setNextMintTime(nextTime);
      }
    } catch (error) {
      console.error("Erro ao verificar tempo de mint:", error);
    }
  };

  const connectWallet = async () => {
    if (!provider) return alert("Instale o MetaMask para continuar");
    try {
      const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
      setAccount(accounts[0]);
      const signer = await provider.getSigner();
      const tokenContract = new ethers.Contract(contractAddress, contractABI, signer);
      setContract(tokenContract);
      
      // Buscar o saldo de tokens
      const balance = await tokenContract.balanceOf(accounts[0]);
      setTokenBalance(ethers.formatEther(balance));
      
      // Verificar se o usuário conectado é o dono do contrato
      try {
        const ownerAddress = await tokenContract.owner();
        setIsOwner(ownerAddress.toLowerCase() === accounts[0].toLowerCase());
      } catch (error) {
        console.error("Erro ao verificar dono:", error);
        setIsOwner(false);
      }
      
      // Verificar próxima vez que o usuário pode mintar
      await checkNextMintTime();
      
    } catch (error) {
      console.error("Erro ao conectar carteira:", error);
    }
  };

  const handleBurn = async () => {
    if (!contract) return alert("Conecte a carteira primeiro");
    if (!burnAmount || parseFloat(burnAmount) <= 0) 
      return alert("Insira uma quantidade válida para queimar");
    
    try {
      const amountInWei = ethers.parseEther(burnAmount);
      const tx = await contract.burn(amountInWei);
      await tx.wait();
      
      // Atualizar o saldo após queimar tokens
      const newBalance = await contract.balanceOf(account);
      setTokenBalance(ethers.formatEther(newBalance));
      
      alert("Tokens queimados com sucesso!");
      setBurnAmount("");
    } catch (error) {
      console.error("Erro ao queimar tokens:", error);
      alert("Erro ao queimar tokens: " + error.message);
    }
  };

  const handlePublicMint = async () => {
    if (!contract) return alert("Conecte a carteira primeiro");
    if (!publicMintAmount || parseFloat(publicMintAmount) <= 0) 
      return alert("Insira uma quantidade válida para criar");
    
    const currentTime = Math.floor(Date.now() / 1000);
    if (nextMintTime && currentTime < nextMintTime) {
      const waitTime = nextMintTime - currentTime;
      const waitHours = Math.floor(waitTime / 3600);
      const waitMinutes = Math.floor((waitTime % 3600) / 60);
      return alert(`Aguarde ${waitHours}h ${waitMinutes}m antes de criar mais tokens`);
    }
    
    try {
      const mintLimit = await contract.MINT_LIMIT();
      const mintLimitEth = ethers.formatEther(mintLimit);
      
      if (parseFloat(publicMintAmount) > parseFloat(mintLimitEth)) {
        return alert(`Você só pode criar até ${mintLimitEth} tokens por vez`);
      }
      
      const amountInWei = ethers.parseEther(publicMintAmount);
      const tx = await contract.publicMint(amountInWei);
      await tx.wait();
      
      // Atualizar o saldo após criar tokens
      const newBalance = await contract.balanceOf(account);
      setTokenBalance(ethers.formatEther(newBalance));
      
      // Atualizar o próximo tempo de mint
      await checkNextMintTime();
      
      alert("Tokens criados com sucesso!");
      setPublicMintAmount("");
    } catch (error) {
      console.error("Erro ao criar tokens:", error);
      
      if (error.message.includes("execution reverted")) {
        alert("Erro ao criar tokens: " + error.reason || "A transação foi revertida.");
      } else {
        alert("Erro ao criar tokens: " + error.message);
      }
    }
  };

  const handleMint = async () => {
    if (!contract) return alert("Conecte a carteira primeiro");
    if (!isOwner) return alert("Apenas o dono do contrato pode criar tokens sem limite");
    if (!mintAmount || parseFloat(mintAmount) <= 0) 
      return alert("Insira uma quantidade válida para criar");
    if (!mintAddress || !ethers.isAddress(mintAddress))
      return alert("Insira um endereço Ethereum válido");
    
    try {
      const amountInWei = ethers.parseEther(mintAmount);
      const tx = await contract.mint(mintAddress, amountInWei);
      await tx.wait();
      
      // Se o usuário estiver mintando para si mesmo, atualizar o saldo
      if (mintAddress.toLowerCase() === account.toLowerCase()) {
        const newBalance = await contract.balanceOf(account);
        setTokenBalance(ethers.formatEther(newBalance));
      }
      
      alert("Tokens criados com sucesso!");
      setMintAmount("");
      setMintAddress("");
    } catch (error) {
      console.error("Erro ao criar tokens:", error);
      alert("Erro ao criar tokens: " + error.message);
    }
  };

  // Formatar data para exibição
  const formatNextMintTime = () => {
    if (!nextMintTime) return "Agora";
    
    const date = new Date(nextMintTime * 1000);
    return date.toLocaleString();
  };

  return (
    <div className="container">
      <h1>Subvisual dApp Challenge</h1>
      
      <button onClick={connectWallet}>
        {account ? `Conectado: ${account.substring(0, 6)}...${account.substring(38)}` : "Conectar Carteira"}
      </button>
      
      {account && (
        <div className="token-info">
          <h2>Seu Saldo de Tokens</h2>
          <p className="balance">{tokenBalance} MTK</p>
          
          <div className="public-mint-section">
            <h3>Criar Tokens (Para Todos)</h3>
            <p className="limit-info">Limite: 100 tokens por vez, uma vez por dia</p>
            {nextMintTime && (
              <p className="next-mint-time">
                Próximo mint disponível: {formatNextMintTime()}
              </p>
            )}
            <input
              type="number"
              value={publicMintAmount}
              onChange={(e) => setPublicMintAmount(e.target.value)}
              placeholder="Quantidade de tokens"
              min="0"
              max="100"
              step="0.01"
            />
            <button onClick={handlePublicMint} disabled={!account || !publicMintAmount}>
              Criar Tokens
            </button>
          </div>
          
          <div className="burn-section">
            <h3>Queimar Tokens</h3>
            <input
              type="number"
              value={burnAmount}
              onChange={(e) => setBurnAmount(e.target.value)}
              placeholder="Quantidade de tokens"
              min="0"
              step="0.01"
            />
            <button onClick={handleBurn} disabled={!account || !burnAmount}>
              Queimar Tokens
            </button>
          </div>
          
          {isOwner && (
            <div className="owner-mint-section">
              <h3>Criar Tokens sem Limite (Apenas Dono)</h3>
              <input
                type="text"
                value={mintAddress}
                onChange={(e) => setMintAddress(e.target.value)}
                placeholder="Endereço de destino"
                className="address-input"
              />
              <input
                type="number"
                value={mintAmount}
                onChange={(e) => setMintAmount(e.target.value)}
                placeholder="Quantidade de tokens"
                min="0"
                step="0.01"
              />
              <button 
                onClick={handleMint} 
                disabled={!account || !mintAmount || !mintAddress || !ethers.isAddress(mintAddress)}
              >
                Criar Tokens como Dono
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default App;