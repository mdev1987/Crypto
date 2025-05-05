import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [{ version: "0.8.22" }, { version: "0.8.8" }],
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
      //accounts: [],
    },
    polygon: {
      url: "https://rpc.ankr.com/polygon",
      //accounts: ["YOUR_PRIVATE_KEY"],
    },
  },
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
  },
};

export default config;