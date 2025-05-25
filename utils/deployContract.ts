import { ethers } from "ethers";
import { FlashLoan } from "../typechain-types";

/**
 * Deploys a contract using the provided factory type, arguments, and wallet.
 *
 * @param factoryType - The contract factory containing ABI and bytecode
 * @param args - Optional array of constructor arguments for contract deployment (default: empty array)
 * @param wallet - The Ethereum wallet or signer used to deploy the contract
 * @returns A deployed FlashLoan contract instance
 */
export const deployContract = async (
  factoryType: any,
  args: Array<any> = [],
  wallet: ethers.Wallet | ethers.JsonRpcSigner
) => {
  const factory = new ethers.ContractFactory(
    factoryType.abi,
    factoryType.bytecode,
    wallet
  );

  const contract = await factory.deploy(...args);
  await contract.waitForDeployment();

  return contract as FlashLoan;
};
