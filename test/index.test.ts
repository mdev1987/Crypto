import { ethers } from "hardhat";
import { deployDodoFlashloan } from "../scripts/deployDodoFlashloan";
import { dodoV2Pool, Protocols } from "../constants";
import { findRouterByProtocol } from "../utils/findRouterByProtocol";
import { FlashLoanParams } from "../types";
import { ERC20Token } from "../constants/tokens";
import { executeFlashLoan } from "../scripts/executeFlashloan";
import { impersonateFundERC20 } from "../utils/funding";
import { ERC20, ERC20__factory } from "../typechain-types";
import { expect } from "chai";

describe("DODO FlashLoan", () => {
  it("Execute flash loan", async () => {
    // Use Hardhat's built-in provider and signer
    const provider = ethers.provider; // Use Hardhat's provider
    const wallet = (await ethers.getSigners())[0];
    const flashLoan = await deployDodoFlashloan({ wallet });
    console.log("wallet:\t", wallet);
    // === NETWORK VERIFICATION ===
    console.log("=== NETWORK VERIFICATION ===");
    const network = await provider.getNetwork();
    console.log("Network name:", network.name);
    console.log("Chain ID:", network.chainId.toString());

    const latestBlock = await provider.getBlockNumber();
    console.log("Latest block:", latestBlock);

    const tokenContract = ERC20__factory.connect(
      ERC20Token.WETH.address,
      provider // Use the same provider
    );

    const mrWhale = "0xdeD8C5159CA3673f543D0F72043E4c655b35b96A";
    const flashLoanAddress = await flashLoan.getAddress();
    console.log("Flash Loan Address:\t", flashLoanAddress);

    // ADD THIS DEBUG SECTION:
    console.log("=== ADDRESS VERIFICATION ===");
    console.log("flashLoan.getAddress():", flashLoanAddress);
    console.log("flashLoan.target:", flashLoan.target);
    console.log("Are they the same?", flashLoanAddress === flashLoanAddress);

    // === BEFORE FUNDING - Check initial balances ===
    console.log("=== BEFORE FUNDING ===");
    const initialBalance = await tokenContract.balanceOf(flashLoanAddress);
    const whaleInitialBalance = await tokenContract.balanceOf(mrWhale);
    console.log(
      "FlashLoan initial balance:\t",
      ethers.formatEther(initialBalance)
    );
    console.log(
      "Whale initial balance:\t\t",
      ethers.formatEther(whaleInitialBalance)
    );

    // Execute funding transaction
    const fundingTxResponse = await impersonateFundERC20({
      sender: mrWhale,
      tokenContract: tokenContract,
      recipient: flashLoanAddress,
      decimals: 18,
      amount: "1",
    });

    // ADD THIS - Wait for confirmation:
    console.log("Waiting for transaction confirmation...");
    const confirmationReceipt = await fundingTxResponse.wait(1); // Wait for 1 confirmation
    console.log(
      "Transaction confirmed in block:",
      confirmationReceipt?.blockNumber
    );

    // Add a small delay to ensure state is updated:
    await new Promise((resolve) => setTimeout(resolve, 1000));

    console.log("=== FUNDING TRANSACTION DETAILS ===");
    console.log("Transaction hash:\t", fundingTxResponse.hash);
    console.log("From:\t\t\t", fundingTxResponse.from);
    console.log("To (WETH contract):\t", fundingTxResponse.to);
    console.log("Gas limit:\t\t", fundingTxResponse.gasLimit.toString());
    console.log("Gas price:\t\t", fundingTxResponse.gasPrice?.toString());

    // Wait for transaction and get receipt
    const receipt = await fundingTxResponse.wait();
    console.log("=== TRANSACTION RECEIPT ===");
    console.log("Block number:\t\t", receipt?.blockNumber);
    console.log("Gas used:\t\t", receipt?.gasUsed.toString());
    console.log("Status:\t\t\t", receipt?.status === 1 ? "SUCCESS" : "FAILED");

    // === DECODE TRANSACTION DATA ===
    console.log("=== TRANSACTION DATA ANALYSIS ===");
    const txData = fundingTxResponse.data;
    console.log("Raw data:\t\t", txData);

    // Decode the transfer function call
    if (txData.startsWith("0xa9059cbb")) {
      const abiCoder = ethers.AbiCoder.defaultAbiCoder();
      const decodedData = abiCoder.decode(
        ["address", "uint256"],
        "0x" + txData.slice(10) // Remove function selector
      );
      console.log("Decoded transfer to:\t", decodedData[0]);
      console.log(
        "Decoded amount:\t\t",
        ethers.formatEther(decodedData[1]),
        "WETH"
      );
    }

    // === AFTER FUNDING - Verify balances changed ===
    console.log("=== AFTER FUNDING ===");
    const balance = await tokenContract.balanceOf(flashLoanAddress);
    const whaleBalanceAfter = await tokenContract.balanceOf(mrWhale);
    console.log(
      "FlashLoan balance after funding:",
      ethers.formatEther(balance)
    );
    console.log(
      "Whale balance after funding:\t",
      ethers.formatEther(whaleBalanceAfter)
    );

    // === VERIFY TOKEN TRANSFER ===
    console.log("=== TOKEN TRANSFER VERIFICATION ===");
    const transferredAmount = balance - initialBalance;
    const whaleSpent = whaleInitialBalance - whaleBalanceAfter;

    console.log(
      "Amount received by contract:\t",
      ethers.formatEther(transferredAmount)
    );
    console.log("Amount sent by whale:\t\t", ethers.formatEther(whaleSpent));

    // Add this debug section before the assertion:
    console.log("=== DEBUG BALANCE CHECK ===");
    console.log("Checking balance for address:", flashLoanAddress);
    console.log("Token contract address:", await tokenContract.getAddress());
    console.log("Network:", await ethers.provider.getNetwork());

    const debugBalance = await tokenContract.balanceOf(flashLoanAddress);
    console.log("Debug balance result:", debugBalance.toString());
    console.log("Debug balance formatted:", ethers.formatEther(debugBalance));

    // Verify the transfer amounts match
    expect(transferredAmount).to.equal(ethers.parseEther("1"));
    expect(whaleSpent).to.equal(ethers.parseEther("1"));
    expect(transferredAmount).to.equal(whaleSpent);

    console.log("✅ Token transfer verified: 1 WETH successfully transferred");
    console.log("✅ Whale sent exactly what contract received");
    console.log("✅ No tokens lost in transfer");

    // === FINAL STATUS ===
    console.log("=== FINAL STATUS ===");
    console.log("Contract now holds:\t\t", ethers.formatEther(balance), "WETH");
    console.log("Ready for flash loan operations ✅");

    const tokenBalance = await tokenContract.balanceOf(flashLoanAddress);
    console.log("\tflash loan balance\t", ethers.formatEther(balance));

    //     const params: FlashLoanParams = {

    //       flashLoanContractAddress: flashLoanAddress,
    //       flashLoanPool: dodoV2Pool.WETH_ULT,
    //       loanAmount: ethers.parseEther("0.01"),
    //       hops: [
    //         {
    //           protocol: Protocols.QUICKSWAP,
    //           data: ethers.AbiCoder.defaultAbiCoder().encode(
    //             ["address"],
    //             [findRouterByProtocol(Protocols.QUICKSWAP)]
    //           ),
    //           path: [ERC20Token.WETH?.address, ERC20Token.USDC?.address],
    //           amountOutMinV3: 0,
    //           sqrtPriceLimitX96: 0,
    //         },
    //         {
    //           protocol: Protocols.SUSHISWAP,
    //           data: ethers.AbiCoder.defaultAbiCoder().encode(
    //             ["address"],
    //             [findRouterByProtocol(Protocols.SUSHISWAP)]
    //           ),
    //           path: [ERC20Token.USDC?.address, ERC20Token.WETH?.address],
    //           amountOutMinV3: 0,
    //           sqrtPriceLimitX96: 0,
    //         },
    //       ],
    //       gasLimit: 3_000_000,
    //       gasPrice: ethers.parseUnits("300", "gwei"),
    //       signer: wallet,
    //     };

    //     const tx = await executeFlashLoan(params);
    //     console.log(tx);
  });
});
