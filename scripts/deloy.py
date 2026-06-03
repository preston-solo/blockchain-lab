const { ethers } = require("hardhat"); 
  
async function main() { 
    const Storage = await ethers.getContractFactory("SimpleStorage");  
    const contract = await Storage.deploy(); 
    
    await contract.waitForDeployment(); 
    
    console.log("Contract deployed to:", await contract.getAddress()); 
} 
  
main().catch((err) => { 
    console.error(err); 
    process.exit(1); 
});