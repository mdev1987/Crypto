import { ethers, network } from "hardhat";
import { FundingParams } from "../types";

/**
 * Funds an ERC20 token by transferring a specified amount from a sender to a recipient.
 *
 * @param fundingParams - Parameters for the token transfer, including sender, recipient, token contract, amount, and token decimals
 */
export const fundErc20 = async (fundingParams: FundingParams) => {
  const { sender, tokenContract, amount, decimals, recipient } = fundingParams;
  console.log("Sender:\t", sender);
  console.log("Recipient:\t", recipient);
  const FUND_AMOUNT = ethers.parseUnits(amount, decimals);
  console.log("Fund Amount:\t", FUND_AMOUNT);
  const mrWhale = await ethers.getSigner(sender);
  const result = await tokenContract
    .connect(mrWhale)
    .transfer(recipient, FUND_AMOUNT);
  return result;
};

/**
 * Impersonates the sender account, funds an ERC20 token, and then stops impersonation.
 *
 * @param fundingParams - Parameters for funding an ERC20 token, including sender, recipient, token contract, amount, and decimals
 */
export const impersonateFundERC20 = async (fundingParams: FundingParams) => {
  const { sender } = fundingParams;

  // Start impersonation
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [sender],
  });

  // Fund the impersonated account with ETH for gas fees
  const [deployer] = await ethers.getSigners();
  await deployer.sendTransaction({
    to: sender,
    value: ethers.parseEther("10.0"), // Send 10 ETH for gas
  });

  console.log("=== IMPERSONATION STARTED ===");
  console.log("Impersonating account:", sender);
  console.log("Funded with ETH for gas fees");

  try {
    // Execute the token transfer
    const res = await fundErc20(fundingParams);
    console.log("✅ Token transfer successful");
    return res;
  } catch (error) {
    console.error("❌ Token transfer failed:", error);
    throw error;
  } finally {
    // Always stop impersonation, even if transfer fails
    await network.provider.request({
      method: "hardhat_stopImpersonatingAccount",
      params: [sender],
    });
    console.log("=== IMPERSONATION STOPPED ===");
  }
};

/**
 * Helper function to check token balance
 */
export const checkTokenBalance = async (
  tokenContract: any,
  address: string,
  tokenSymbol: string = "TOKEN"
) => {
  const balance = await tokenContract.balanceOf(address);
  console.log(
    `${tokenSymbol} balance for ${address}:`,
    ethers.formatEther(balance)
  );
  return balance;
};

/**
 * Helper function to check if account has enough tokens
 */
export const verifyTokenBalance = async (
  tokenContract: any,
  address: string,
  requiredAmount: string,
  decimals: number = 18
) => {
  const balance = await tokenContract.balanceOf(address);
  const required = ethers.parseUnits(requiredAmount, decimals);

  console.log("Current balance:", ethers.formatUnits(balance, decimals));
  console.log("Required amount:", requiredAmount);

  if (balance < required) {
    throw new Error(
      `Insufficient token balance. Has: ${ethers.formatUnits(
        balance,
        decimals
      )}, Needs: ${requiredAmount}`
    );
  }

  console.log("✅ Sufficient token balance confirmed");
  return true;
};
