// pages/index.tsx
import { useAccount, useContractWrite, usePrepareContractWrite } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useState } from 'react';
import { abi } from '../artifacts/contracts/SubvisualNFT.sol/SubvisualNFT.json';

export default function Home() {
  const { isConnected } = useAccount();
  const [minted, setMinted] = useState(false);
  
  const { config } = usePrepareContractWrite({
    address: process.env.NEXT_PUBLIC_CONTRACT_ADDRESS,
    abi: abi,
    functionName: 'safeMint',
    args: [address],
  });
  
  const { write: mint } = useContractWrite({
    ...config,
    onSuccess: () => setMinted(true),
  });

  return (
    <div className="min-h-screen bg-gray-100 flex flex-col items-center justify-center">
      <div className="bg-white p-8 rounded-lg shadow-md w-96">
        <h1 className="text-2xl font-bold mb-6">Subvisual NFT Mint</h1>
        
        <div className="mb-6">
          <ConnectButton />
        </div>
        
        {isConnected && (
          <button
            onClick={() => mint?.()}
            disabled={!mint || minted}
            className="bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 disabled:bg-gray-400"
          >
            {minted ? 'NFT Minted!' : 'Mint NFT'}
          </button>
        )}
      </div>
    </div>
  );
}