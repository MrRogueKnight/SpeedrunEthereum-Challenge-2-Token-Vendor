import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

const deployVendor: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // Get already deployed YourToken contract
  const yourToken = await hre.ethers.getContract<Contract>("YourToken", deployer);
  const yourTokenAddress = await yourToken.getAddress();

  // Deploy Vendor with token address as constructor argument
  await deploy("Vendor", {
    from: deployer,
    args: [yourTokenAddress],
    log: true,
    autoMine: true,
  });

  const vendor = await hre.ethers.getContract<Contract>("Vendor", deployer);
  const vendorAddress = await vendor.getAddress();

  // Transfer 1000 tokens to Vendor so it can sell them
  await yourToken.transfer(vendorAddress, hre.ethers.parseEther("1000"));

  // Transfer ownership of Vendor to your frontend address
  await vendor.transferOwnership("0x58ad103D0C0E69250CaC89Ddf0BDaD396914C411");
};

export default deployVendor;

deployVendor.tags = ["Vendor"];
