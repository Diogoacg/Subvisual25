import { useState, useEffect } from 'react';

export function NFTGallery({ nfts, isLoading }) {
  const [metadata, setMetadata] = useState({});

  useEffect(() => {
    const fetchMetadata = async () => {
      const metadataResults = {};
      
      for (const nft of nfts) {
        try {
          // Para finalidade de demonstração, apenas simular metadata
          // Em produção, você faria um fetch real
          metadataResults[nft.id] = {
            name: `NFT #${nft.id}`,
            description: `Este é o NFT #${nft.id} da coleção SimpleNFT`,
            image: `https://via.placeholder.com/150?text=NFT+${nft.id}`
          };
        } catch (error) {
          console.error(`Error fetching metadata for NFT ${nft.id}:`, error);
        }
      }
      
      setMetadata(metadataResults);
    };

    if (nfts.length > 0) {
      fetchMetadata();
    }
  }, [nfts]);

  if (isLoading) {
    return <div className="text-center py-8">Carregando seus NFTs...</div>;
  }

  if (nfts.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        Você ainda não possui NFTs desta coleção. Tente mintar um!
      </div>
    );
  }

  return (
    <div>
      <h2 className="text-xl font-bold mb-4">Seus NFTs</h2>
      
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
        {nfts.map((nft) => {
          const nftMeta = metadata[nft.id];
          
          return (
            <div key={nft.id} className="border rounded-lg overflow-hidden bg-gray-50">
              {nftMeta ? (
                <>
                  <div className="h-40 bg-gray-200 flex items-center justify-center">
                    <img 
                      src={nftMeta.image} 
                      alt={nftMeta.name}
                      className="max-h-full max-w-full"
                    />
                  </div>
                  <div className="p-4">
                    <h3 className="font-bold">{nftMeta.name}</h3>
                    <p className="text-sm text-gray-600">{nftMeta.description}</p>
                    <p className="text-xs text-gray-500 mt-2">Token ID: {nft.id}</p>
                  </div>
                </>
              ) : (
                <div className="p-4 text-center">
                  <p>Token ID: {nft.id}</p>
                  <p className="text-sm text-gray-500">Carregando metadata...</p>
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}