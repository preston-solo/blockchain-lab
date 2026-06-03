import hre from "hardhat";

async function main() {
  const connection = await hre.network.connect();
  const SecureStorage = await connection.ethers.getContractFactory("contracts/SecureStorage.sol:SecureStorage");
  const contract = await SecureStorage.deploy();
  await contract.waitForDeployment();
  console.log("SecureStorage deployed to:", await contract.getAddress());
}

main().catch((err) => { console.error(err); process.exit(1); });
