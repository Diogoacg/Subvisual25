import { useState } from 'react';
import { ethers } from 'ethers';

export function ConnectWallet({ onConnect, account }) {
  const [isConnecting, setIsConnecting] = useState(false);
  const [error, setError] = useState('');

  const connectWallet = async () => {
    setIsConnecting(true);
    setError('');
    
    try {
      if (!window.ethereum) {
        throw new Error('MetaMask não encontrado! Por favor instale o MetaMask para usar este app.');
      }

      const provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send('eth_requestAccounts', []);
      const signer = await provider.getSigner();
      const address = await signer.getAddress();
      
      onConnect(address, provider, signer);
    } catch (error) {
      console.error('Error connecting wallet:', error);
      setError(error.message);
    } finally {
      setIsConnecting(false);
    }
  };

  return (
    <div className="mb-8 p-4 border rounded-lg">
      {!account ? (
        <div className="text-center">
          <button 
            onClick={connectWallet}
            disabled={isConnecting}
            className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg"
          >
            {isConnecting ? 'Conectando...' : 'Conectar Carteira'}
          </button>
          {error && <p className="text-red-500 mt-2">{error}</p>}
        </div>
      ) : (
        <div className="text-center">
          <p className="font-medium">Carteira Conectada</p>
          <p className="text-gray-600 text-sm mt-1">
            {account.substring(0, 6)}...{account.substring(account.length - 4)}
          </p>
        </div>
      )}
    </div>
  );
}