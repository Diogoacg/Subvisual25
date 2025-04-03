async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const MyToken = await ethers.getContractFactory("MyToken");
    const token = await MyToken.deploy(1000 * 10 ** 18);
    await token.deployed();
    console.log("Token address:", token.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
  