import { ethers, network } from "hardhat";
import { FundingParams } from "../types";

/**
 * Funds an ERC20 token by transferring a specified amount from a sender to a recipient.
 *
 * @param fundingParams - Parameters for the token transfer, including sender, recipient, token contract, amount, and token decimals
 */
export const fundErc20 = async (fundingParams: FundingParams) => {
  const { sender, tokenContract, amount, decimals, recipient } = fundingParams;
  const FUND_AMOUNT = ethers.parseUnits(amount, decimals);
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
  }
};
