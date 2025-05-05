import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [{ version: "0.8.22" }, { version: "0.8.8" }],
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
      //accounts: [""],
    },
    polygon: {
      url: "https://rpc.ankr.com/polygon/a08dc0c8056dd0b5773c7bc41d752dcd0a03224d6424c0142c8e6a35b1c53c85",
      //accounts: ["YOUR_PRIVATE_KEY"],
    },
  },
  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
  },
};

export default config;
