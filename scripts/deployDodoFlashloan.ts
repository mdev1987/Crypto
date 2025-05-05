import { FlashLoan, FlashLoan__factory } from "../typechain-types";
import { DeployDODOFlashloanParams } from "../types";
import { deployContract } from "../utils/deployContract";

/**
 * Deploys a FlashLoan contract using the provided deployment parameters.
 *
 * @param params - Configuration parameters for deploying the FlashLoan contract, including the wallet to use
 * @returns A Promise resolving to the deployed FlashLoan contract instance
 */
export async function deployDodoFlashloan(params: DeployDODOFlashloanParams) {
  const flashLoan: FlashLoan = await deployContract(
    FlashLoan__factory,
    [],
    params.wallet
  );

  const deployed = await flashLoan.waitForDeployment();
  console.log(`FlashLoan deployed at: ${deployed.target}`);

  return deployed;
}
