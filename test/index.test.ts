import { ethers } from "ethers";
import { deployDodoFlashloan } from "../scripts/deployDodoFlashloan";
import { dodoV2Pool, Protocols } from "../constants";
import { findRouterByProtocol } from "../utils/findRouterByProtocol";
import { FlashLoanParams } from "../types";
import { ERC20Token } from "../constants/tokens";
import { executeFlashLoan } from "../scripts/executeFlashloan";

describe("DODO FlashLoan", () => {
  it("Execute flash loan", async () => {
    const providerUrl = "http://localhost:8545";
    //const privateKey = process.env.PRIVATE_KEY || "";
    //const wallet = new ethers.Wallet(privateKey);
    const provider = new ethers.JsonRpcProvider(providerUrl);
    const wallet = await provider.getSigner(0);
    const flashLoan = await deployDodoFlashloan({ wallet });
    const params: FlashLoanParams = {
      flashLoanContractAddress: flashLoan.target.toString(),
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
    console.log(tx);
  });
});
