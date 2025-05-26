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
    const provider = ethers.provider;
    const [wallet] = await ethers.getSigners();
    const flashLoan = await deployDodoFlashloan({ wallet });

    const tokenContract = ERC20__factory.connect(
      ERC20Token.WETH.address,
      provider
    );

    const mrWhale = "0xdeD8C5159CA3673f543D0F72043E4c655b35b96A";
    const flashLoanAddress = await flashLoan.getAddress();

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

    const receipt = await fundingTxResponse.wait();
    console.log("=== TRANSACTION RECEIPT ===");
    console.log("Transaction Hash:\t\t", receipt?.hash);
    console.log("Gas used:\t\t", receipt?.gasUsed.toString());
    console.log(
      "Status:\t\t\t",
      receipt?.status === 1 ? "SUCCESS ✅" : "FAILED ❌"
    );

    const tokenBalance = await tokenContract.balanceOf(flashLoanAddress);
    console.log(
      "FlashLoan Balance Before Swaping\t",
      ethers.formatEther(tokenBalance),
      " WETH"
    );
    expect(tokenBalance).to.equal(ethers.parseEther("1"));

    const params: FlashLoanParams = {
      flashLoanContractAddress: flashLoanAddress,
      flashLoanPool: dodoV2Pool.WETH_ULT,
      loanAmount: ethers.parseEther("0.01"),
      hops: [
        {
          protocol: Protocols.QUICKSWAP,
          data: ethers.AbiCoder.defaultAbiCoder().encode(
            ["address"],
            [findRouterByProtocol(Protocols.QUICKSWAP)]
          ),
          path: [ERC20Token.WETH?.address, ERC20Token.USDC?.address],
          amountOutMinV3: 0,
          sqrtPriceLimitX96: 0,
        },
        {
          protocol: Protocols.SUSHISWAP,
          data: ethers.AbiCoder.defaultAbiCoder().encode(
            ["address"],
            [findRouterByProtocol(Protocols.SUSHISWAP)]
          ),
          path: [ERC20Token.USDC?.address, ERC20Token.WETH?.address],
          amountOutMinV3: 0,
          sqrtPriceLimitX96: 0,
        },
      ],
      gasLimit: 3_000_000,
      gasPrice: ethers.parseUnits("300", "gwei"),
      signer: wallet,
    };

    const tx = await executeFlashLoan(params);
    const tokenBalanceFinal = await tokenContract.balanceOf(flashLoanAddress);
    console.log(
      "Final FlashLoan Balance:\t",
      ethers.formatEther(tokenBalanceFinal),
      " WETH"
    );
    expect(tokenBalanceFinal).to.equal(ethers.parseEther("0"));
    expect(tx).to.exist;
    //expect(tx).to.not.be.null;
    const ownerBalance = await tokenContract.balanceOf(wallet.address);
    console.log("🚀 ~ it ~ ownerBalance:", ownerBalance);
    expect(ownerBalance).to.be.gt(ethers.parseEther("0"));
  });
});
