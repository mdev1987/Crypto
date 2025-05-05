import { ethers } from "ethers";
import flashloanJson from "../artifacts/contracts/FlashLoan.sol/FlashLoan.json";
import { FlashLoanParams } from "../types";

/**
 * Executes a flash loan transaction using the specified parameters.
 *
 * @param params - An object containing the parameters required to execute the flash loan.
 * @param params.flashLoanContractAddress - The address of the flash loan contract.
 * @param params.signer - The signer object used to sign the transaction.
 * @param params.flashLoanPool - The address of the flash loan pool.
 * @param params.loanAmount - The amount to borrow in the flash loan.
 * @param params.routes - The routes for the flash loan transaction.
 * @param params.gasLimit - The gas limit for the transaction.
 * @param params.gasPrice - The gas price for the transaction.
 * 
 * @returns A promise that resolves to the transaction object of the executed flash loan.
 */
export async function executeFlashloan(params: FlashLoanParams) {
    const flashLoan = new ethers.Contract(
        params.flashLoanContractAddress,
        flashloanJson.abi,
        params.signer
    );
    const tx = await flashLoan.executeFlashloan({
        flashLoanPool: params.flashLoanPool,
        amountIn: params.loanAmount,
        routes: params.routes,
        gasLimit: params.gasLimit,
        gasPrice: params.gasPrice,

    });
    return tx;

}