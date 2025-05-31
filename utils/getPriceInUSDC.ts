import { ethers } from "hardhat";
import { getPriceParams } from "../types";
import routerAbi from "../abis/routerAbi.json";
import factoryAbi from "../abis/factoryAbi.json";
import pairAbi from "../abis/pairAbi.json";
import { ERC20Token } from "../constants/tokens";
import { Factories, Protocols, Routers } from "../constants";
export const getPriceInUSDC = async (params: getPriceParams) => {
  const providerUrl =
    "https://rpc.ankr.com/polygon/a08dc0c8056dd0b5773c7bc41d752dcd0a03224d6424c0142c8e6a35b1c53c85";
  const provider = new ethers.JsonRpcProvider(providerUrl);
  const router = new ethers.Contract(params.router, routerAbi, provider);
  const factory = new ethers.Contract(params.factory, factoryAbi, provider);
  const pairAddress = await factory.getPair(
    params.tokenAddress,
    ERC20Token.USDC.address
  );
  const pair = new ethers.Contract(pairAddress, pairAbi, provider);
  const reserves = await pair.getReserves();
  const quote = await router.quote(
    ethers.parseEther("1"),
    reserves[1],
    reserves[0]
  );
  // Helper to get protocol name by id
  const getProtocolNameById = (id: number) => {
    return Object.keys(Protocols).find((key) => (Protocols as any)[key] === id);
  };

  console.log(
    `Price of ${params.tokenAddress} = ${ethers.formatUnits(
      quote,
      6
    )} on protocol: ${getProtocolNameById(params.id)}`
  );

  return {
    quote: quote,
    protocol: params.id,
    reserves,
  };
};

// getPriceInUSDC({
//   router: Routers.POLYGON_SUSHISWAP,
//   factory: Factories.POLYGON_SUSHISWAP,
//   tokenAddress: ERC20Token.WETH.address,
//   id: Protocols.SUSHISWAP,
// });
