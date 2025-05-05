import { ethers } from "ethers";
import { QUOTER_ADDRESS, QUOTER_ADDRESS2 } from "../constants";
import quoter1ABI from "@uniswap/v3-periphery/artifacts/contracts/lens/Quoter.sol/Quoter.json";
import quoter2ABI from "@uniswap/v3-periphery/artifacts/contracts/lens/QuoterV2.sol/QuoterV2.json";

const provider = new ethers.JsonRpcProvider(
  "https://rpc.ankr.com/eth/a08dc0c8056dd0b5773c7bc41d752dcd0a03224d6424c0142c8e6a35b1c53c85"
);

// const tokenIn = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619"; // WETH on Polygon
// const tokenOut = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F"; // USDT on Polygon

const tokenIn = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; // WETH on Ethereum
const tokenOut = "0xdAC17F958D2ee523a2206206994597C13D831ec7"; // USDT on Ethereum
const fee = 3000; // 0.3% fee tier
const amountIn = ethers.parseUnits("1", 18);
const sqrtPriceLimitX96 = ethers.parseUnits("0", 18); // 0 USDT per WETH

/**
 * Creates a contract instance for the Uniswap V3 Quoter V1 contract.
 *
 * @param {string} QUOTER_ADDRESS - The Ethereum address of the Quoter V1 contract
 * @param {Object} quoter1ABI - The ABI (Application Binary Interface) for the Quoter V1 contract
 * @param {ethers.Provider} provider - The Ethereum network provider used to interact with the contract
 * @returns {ethers.Contract} An instance of the Quoter V1 contract ready for method calls
 */
const quoter1 = new ethers.Contract(QUOTER_ADDRESS, quoter1ABI.abi, provider);

/**
 * Creates a contract instance for the Uniswap V3 Quoter V2 contract.
 *
 * @param {string} QUOTER_ADDRESS_V2 - The Ethereum address of the Quoter V2 contract
 * @param {Object} quoter2ABI - The ABI (Application Binary Interface) for the Quoter V2 contract
 * @param {ethers.Provider} provider - The Ethereum network provider used to interact with the contract
 * @returns {ethers.Contract} An instance of the Quoter V2 contract ready for method calls
 */
const quoter2 = new ethers.Contract(QUOTER_ADDRESS2, quoter2ABI.abi, provider);

/**
 * Performs token quote comparisons using Uniswap V3 Quoter contracts.
 *
 * Retrieves quote amounts for a token swap using both Quoter V1 and V2 contracts,
 * logging the output amount, sqrt price, and gas estimate for each quote method.
 *
 * @async
 * @throws {Error} If quote retrieval fails for either Quoter contract
 */
const main = async () => {
  const params = [tokenIn, tokenOut, fee, amountIn, sqrtPriceLimitX96];

  // Quote 1
  const quote1 = await quoter1.quoteExactInputSingle.staticCall(
    tokenIn,
    tokenOut,
    fee,
    amountIn,
    sqrtPriceLimitX96
  );
  console.log("Quote 1 Amount Out:", ethers.formatUnits(quote1.toString(), 6));

  // Quote 2
  const quote2 = await quoter2.quoteExactInputSingle.staticCall({
    tokenIn,
    tokenOut,
    amountIn,
    fee,
    sqrtPriceLimitX96,
  });
  console.log(
    "Quote 2 Amount Out:",
    ethers.formatUnits(quote2.amountOut.toString(), 6)
  );
  console.log(
    "Quote 2 sqrtPriceX96After:",
    quote2.sqrtPriceX96After.toString()
  );
  console.log("Quote 2 gasEstimate:", quote2.gasEstimate.toString());
  console.log("Quote 1 gasEstimate:", quote1.gasEstimate.toString());
};
main()
  /**
   * Handles successful completion of the main function.
   * Logs a "Done" message and exits the process with a success status code.
   */
  .then(() => {
    console.log("Done");
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
