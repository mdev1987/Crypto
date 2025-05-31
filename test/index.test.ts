import { ethers } from "hardhat";
import { expect } from "chai";
import { deployDodoFlashloan } from "../scripts/deployDodoFlashloan";
import { executeFlashLoan } from "../scripts/executeFlashloan";
import { impersonateFundERC20 } from "../utils/funding";
import {
  DodoV2Pools,
  Protocols,
  QUOTER_ADDRESS,
  QUOTER_ADDRESS2,
  Routers,
} from "../constants";
import { ERC20Token } from "../constants/tokens";

describe("FlashLoan Contract", () => {
  it("should execute a profitable flash loan", async () => {
    const [deployer] = await ethers.getSigners();

    const flashLoan = await deployDodoFlashloan({ wallet: deployer });
    const contractAddress = await flashLoan.getAddress();

    const WETH = await ethers.getContractAt("IERC20", ERC20Token.WETH.address);
    const whale = "0xdeD8C5159CA3673f543D0F72043E4c655b35b96A";

    console.log("Funding contract with 1 WETH...");
    const txFund = await impersonateFundERC20({
      sender: whale,
      tokenContract: WETH,
      recipient: contractAddress,
      decimals: 18,
      amount: "1",
    });
    await txFund.wait();

    const preBalance = await WETH.balanceOf(contractAddress);
    expect(preBalance).to.equal(ethers.parseEther("1"));

    const hops = [
      {
        protocol: Protocols.QUICKSWAP,
        router: Routers.POLYGON_QUICKSWAP, // QuickSwap router
        path: [ERC20Token.WETH.address, ERC20Token.USDC.address],
      },
      {
        protocol: Protocols.SUSHISWAP,
        router: Routers.POLYGON_SUSHISWAP, // SushiSwap router
        path: [ERC20Token.USDC.address, ERC20Token.WETH.address],
      },
    ];

    const receipt = await executeFlashLoan({
      flashLoanContractAddress: contractAddress,
      flashLoanPool: DodoV2Pools.WETH_USDC,
      loanToken: ERC20Token.WETH.address,
      loanAmount: ethers.parseEther("0.01"),
      hops,
      gasLimit: 3_000_000,
      gasPrice: ethers.parseUnits("200", "gwei"),
      signer: deployer,
    });

    expect(receipt).to.exist;

    const postContractBalance = await WETH.balanceOf(contractAddress);
    const deployerBalance = await WETH.balanceOf(deployer.address);

    console.log(
      "Contract WETH Balance After:",
      ethers.formatEther(postContractBalance)
    );
    console.log("Deployer WETH Profit:", ethers.formatEther(deployerBalance));

    expect(postContractBalance).to.equal(0);
    expect(deployerBalance).to.be.gt(0);
  });
});
