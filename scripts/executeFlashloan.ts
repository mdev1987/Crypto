import { ethers } from "hardhat";
import type { BigNumberish, Signer } from "ethers";
import { FlashLoan } from "../typechain-types"; // adjust import as per your project structure

export interface TradeHop {
  protocol: number;
  router: string;
  path: string[];
}

export interface ExecuteFlashLoanParams {
  flashLoanContractAddress: string;
  flashLoanPool: string;
  loanToken: string;
  loanAmount: BigNumberish;
  hops: TradeHop[];
  gasLimit?: number;
  gasPrice?: BigNumberish;
  signer: Signer;
}

export async function executeFlashLoan(params: ExecuteFlashLoanParams) {
  const {
    flashLoanContractAddress,
    flashLoanPool,
    loanToken,
    loanAmount,
    hops,
    gasLimit = 3_000_000,
    gasPrice,
    signer,
  } = params;

  const flashLoan = (await ethers.getContractAt(
    "FlashLoan",
    flashLoanContractAddress,
    signer
  )) as FlashLoan;

  const tx = await flashLoan.executeFlashLoan(
    flashLoanPool,
    loanToken,
    loanAmount,
    hops,
    {
      gasLimit,
      gasPrice,
    }
  );

  const receipt = await tx.wait();
  return receipt;
}
