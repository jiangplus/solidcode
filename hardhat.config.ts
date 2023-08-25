import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';

import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  gasReporter: {
    enabled: (process.env.REPORT_GAS) ? true : false
  },
  solidity: {
    version: '0.8.17',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    localhost: {
    },
    fuji: {
      url: `https://api.avax-test.network/ext/bc/C/rpc`,
      accounts:
        process.env.KEY1 !== undefined ? [process.env.KEY_ONE, process.env.KEY_TWO || ""] : [],
      timeout: 3600000
    },
  }
};

export default config;
