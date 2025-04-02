// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/SimpleNFT.sol";

contract DeploySimpleNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        SimpleNFT nft = new SimpleNFT(
            "SimpleNFT",
            "SNFT",
            "https://example.com/metadata/"
        );
        
        vm.stopBroadcast();
    }
}