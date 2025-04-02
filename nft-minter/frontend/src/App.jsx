import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import { ConnectWallet } from './components/ConnectWallet';
import { MintNFT } from './components/MintNFT';
import { NFTGallery } from './components/NFTGallery';
import SimpleNFTAbi from './utils/SimpleNFT.json';

function App() {
  const [account, setAccount] = useState('');
  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [nftContract, setNftContract] = useState(null);
  const [ownedNFTs, setOwnedNFTs] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  // Contract address - update this after deployment
  const contractAddress = '0x257Ef8f63c08C2d9bb26AeC2cE2fE0358bd37b9E'; // Substitua pelo endereço real após o deploy

  useEffect(() => {
    if (account && provider) {
      loadContractData();
    }
  }, [account, provider]);

  const loadContractData = async () => {
    try {
      const contract = new ethers.Contract(
        contractAddress,
        SimpleNFTAbi.abi,
        signer
      );
      setNftContract(contract);
      
      fetchOwnedNFTs(contract);
    } catch (error) {
      console.error('Error loading contract data:', error);
    }
  };

  const fetchOwnedNFTs = async (contract) => {
    setIsLoading(true);
    try {
      const balance = await contract.balanceOf(account);
      const nfts = [];
      
      for (let i = 0; i < balance; i++) {
        const tokenId = await contract.tokenOfOwnerByIndex(account, i);
        const tokenURI = await contract.tokenURI(tokenId);
        nfts.push({ id: tokenId.toString(), uri: tokenURI });
      }
      
      setOwnedNFTs(nfts);
    } catch (error) {
      console.error('Error fetching NFTs:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleConnect = (accountAddress, providerInstance, signerInstance) => {
    setAccount(accountAddress);
    setProvider(providerInstance);
    setSigner(signerInstance);
  };

  const handleMintSuccess = () => {
    fetchOwnedNFTs(nftContract);
  };

  return (
    <div className="min-h-screen bg-gray-100 p-4">
      <div className="max-w-4xl mx-auto bg-white rounded-lg shadow p-6">
        <h1 className="text-3xl font-bold mb-6 text-center">NFT Minter dApp</h1>
        
        <ConnectWallet onConnect={handleConnect} account={account} />
        
        {account && nftContract && (
          <>
            <MintNFT 
              contract={nftContract} 
              account={account}
              onSuccess={handleMintSuccess}
            />
            
            <NFTGallery 
              nfts={ownedNFTs} 
              isLoading={isLoading} 
            />
          </>
        )}
      </div>
    </div>
  );
}

export default App;