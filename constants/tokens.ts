import { erc20Token } from "../types";

const TRUSTWALLET_BASE =
  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/polygon/assets";

export const ERC20Token: erc20Token = {
  WMATIC: {
    symbol: "WPOL",
    name: "Wrapped Polygon Ecosystem Token",
    decimals: 18,
    address: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",
    logoURI: `${TRUSTWALLET_BASE}/0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270/logo.png`,
  },

  USDC: {
    symbol: "USDC",
    name: "USD Coin",
    decimals: 6,
    address: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
    logoURI: `${TRUSTWALLET_BASE}/0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174/logo.png`,
  },

  USDT: {
    symbol: "USDT",
    name: "Tether USD",
    decimals: 6,
    address: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F",
    logoURI: `${TRUSTWALLET_BASE}/0xc2132D05D31c914a87C6611C10748AEb04B58e8F/logo.png`,
  },

  DAI: {
    symbol: "DAI",
    name: "Dai Stablecoin",
    decimals: 18,
    address: "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063",
    logoURI: `${TRUSTWALLET_BASE}/0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063/logo.png`,
  },

  WBTC: {
    symbol: "WBTC",
    name: "Wrapped BTC",
    decimals: 8,
    address: "0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6",
    logoURI: `${TRUSTWALLET_BASE}/0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6/logo.png`,
  },

  LINK: {
    symbol: "LINK",
    name: "ChainLink Token",
    decimals: 18,
    address: "0xb0897686c545045aFc77CF20eC7A532E3120E0F1",
    logoURI: `${TRUSTWALLET_BASE}/0xb0897686c545045aFc77CF20eC7A532E3120E0F1/logo.png`,
  },

  COMP: {
    symbol: "COMP",
    name: "Compound",
    decimals: 18,
    address: "0x8505B9d2254A7ae468c0E9Dd10CcEa3A837aEF5C",
    logoURI: `${TRUSTWALLET_BASE}/0x8505B9d2254A7ae468c0E9Dd10CcEa3A837aEF5C/logo.png`,
  },

  CEL: {
    symbol: "CEL",
    name: "Celsius",
    decimals: 4,
    address: "0xD85d1e945766Fea5Eda9103F918Bd915FbCa63E6",
    logoURI: `${TRUSTWALLET_BASE}/0xD85d1e945766Fea5Eda9103F918Bd915FbCa63E6/logo.png`,
  },

  WETH: {
    symbol: "WETH",
    name: "Wrapped Ether",
    decimals: 18,
    address: "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619",
    logoURI: `${TRUSTWALLET_BASE}/0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619/logo.png`,
  },

  CRV: {
    symbol: "CRV",
    name: "Curve DAO Token",
    decimals: 18,
    address: "0x172370d5Cd63279efa6d502DAB29171933a610af",
    logoURI: `${TRUSTWALLET_BASE}/0x172370d5Cd63279efa6d502DAB29171933a610af/logo.png`,
  },

  QI: {
    symbol: "QI",
    name: "Qi Dao",
    decimals: 18,
    address: "0x580a84C73811E1839F75d86d75d88cca0C241fF4",
    logoURI: `${TRUSTWALLET_BASE}/0x580a84C73811E1839F75d86d75d88cca0C241fF4/logo.png`,
  },

  UNI: {
    symbol: "UNI",
    name: "Uniswap",
    decimals: 18,
    address: "0xb33EaAd8d922B1083446DC23f610c2567fB5180f",
    logoURI: `${TRUSTWALLET_BASE}/0xb33EaAd8d922B1083446DC23f610c2567fB5180f/logo.png`,
  },

  AAVE: {
    symbol: "AAVE",
    name: "Aave Token",
    decimals: 18,
    address: "0xd6Df932A45C0f255f85145f286ea0b292b21C90b",
    logoURI: `${TRUSTWALLET_BASE}/0xd6Df932A45C0f255f85145f286ea0b292b21C90b/logo.png`,
  },

  MUST: {
    symbol: "MUST",
    name: "Must",
    decimals: 18,
    address: "0x9C78ee466D6Cb57A4d01Fd887D2b5dFb2D46288f",
    logoURI: `${TRUSTWALLET_BASE}/0x9C78ee466D6Cb57A4d01Fd887D2b5dFb2D46288f/logo.png`,
  },

  MEME: {
    symbol: "MEME",
    name: "MEME (PoS)",
    decimals: 8,

    address: "0xba4958BdB50Cd8A0a95b01636dF65cE15b1E04b0",
    logoURI: `${TRUSTWALLET_BASE}/0xba4958BdB50Cd8A0a95b01636dF65cE15b1E04b0/logo.png`,
  },

  SUPER: {
    symbol: "SUPER",
    name: "SuperFarm",
    decimals: 18,
    address: "0xa1428174F516F527fafdD146b883bB4428682737",
    logoURI: `${TRUSTWALLET_BASE}/0xa1428174F516F527fafdD146b883bB4428682737/logo.png`,
  },

  MANA: {
    symbol: "MANA",
    name: "Decentraland MANA",
    decimals: 18,
    address: "0xa1c57f48F0Deb89f569DFBE6E2B7f46D33606fD4",
    logoURI: `${TRUSTWALLET_BASE}/0xa1c57f48F0Deb89f569DFBE6E2B7f46D33606fD4/logo.png`,
  },

  YFI: {
    symbol: "YFI",
    name: "yearn.finance",
    decimals: 18,
    address: "0xda537104D6A5edd53c6FbBA9A898708e465260B6",
    logoURI: `${TRUSTWALLET_BASE}/0xda537104D6A5edd53c6FbBA9A898708e465260B6/logo.png`,
  },

  QUICK: {
    symbol: "QUICK",
    name: "Quickswap",
    decimals: 18,
    address: "0xB5C064F955D8e7F38fE0460C556a72987494eE17",
    logoURI: `${TRUSTWALLET_BASE}/0xB5C064F955D8e7F38fE0460C556a72987494eE17/logo.png`,
  },
};
