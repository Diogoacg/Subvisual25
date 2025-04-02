import { useState } from 'react';
import { ethers } from 'ethers';

export function MintNFT({ contract, account, onSuccess }) {
  const [isMinting, setIsMinting] = useState(false);
  const [error, setError] = useState('');
  const [txHash, setTxHash] = useState('');

  const mintNFT = async () => {
    setIsMinting(true);
    setError('');
    setTxHash('');
    
    try {
      const mintPrice = await contract.mintPrice();
      
      const tx = await contract.mint({ value: mintPrice });
      setTxHash(tx.hash);
      
      await tx.wait();
      onSuccess();
    } catch (error) {
      console.error('Error minting NFT:', error);
      setError(error.message);
    } finally {
      setIsMinting(false);
    }
  };

  return (
    <div className="mb-8 p-4 border rounded-lg">
      <h2 className="text-xl font-bold mb-4">Mintar NFT</h2>
      
      <div className="text-center">
        <button 
          onClick={mintNFT}
          disabled={isMinting}
          className="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg"
        >
          {isMinting ? 'Mintando...' : 'Mintar NFT (0.01 ETH)'}
        </button>
        
        {error && (
          <p className="text-red-500 mt-2">
            {error.includes('execution reverted') 
              ? 'Erro: Transação revertida. Verifique se você tem ETH suficiente.' 
              : error}
          </p>
        )}
        
        {txHash && (
          <div className="mt-4">
            <p className="text-green-600 font-medium">Transação enviada!</p>
            <p className="text-sm mt-1">
              Hash: {txHash.substring(0, 10)}...{txHash.substring(txHash.length - 8)}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}