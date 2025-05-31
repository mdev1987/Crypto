import { ethers } from "hardhat";

async function main() {
  // Raw addresses – no need to use getAddress()
  const factoryAddress = "0x79887f65f83bdf15Bcc8736b5e5BcDB48fb8fE13"; // DVMFactory
  const tokenA = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619"; // WETH
  const tokenB = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174"; // USDC

  const factoryABI = [
    "function getDODOPool(address baseToken, address quoteToken) external view returns (address[])",
  ];

  const provider = ethers.provider;
  const factory = new ethers.Contract(factoryAddress, factoryABI, provider);

  // ERC20 ABI fragment for balanceOf
  const erc20ABI = ["function balanceOf(address owner) view returns (uint256)"];

  const WETH = new ethers.Contract(tokenA, erc20ABI, provider);
  const USDC = new ethers.Contract(tokenB, erc20ABI, provider);

  async function fetchPool(base: string, quote: string) {
    const machines: string[] = await factory.getDODOPool(base, quote);

    let best = ethers.ZeroAddress;
    let bestLiquidity = ethers.toBigInt(0);

    for (const m of machines) {
      const wethBal = await WETH.balanceOf(m);
      const usdcBal = await USDC.balanceOf(m);
      const liquidity = wethBal + usdcBal;

      if (liquidity > bestLiquidity) {
        bestLiquidity = liquidity;
        best = m;
      }
    }

    console.log(`Best WETH/USDC pool: ${best}`);
    console.log(`Total TVL: ${bestLiquidity.toString()}`);
  }

  await fetchPool(tokenA, tokenB);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
