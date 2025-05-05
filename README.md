# FlashLoan Polygon Project

## Project Overview
The FlashLoan Polygon project is a decentralized finance (DeFi) application that enables users to execute flash loans on the Polygon blockchain. Flash loans are uncollateralized loans that must be borrowed and repaid within a single blockchain transaction. This project supports multi-protocol routing for swaps, including Uniswap V2, Uniswap V3, and DODO V2, allowing users to optimize their trading strategies.

## Project Structure
The project is organized into several directories and files, each serving a specific purpose. Below is a summary of the key components:

### Contracts
- **`contracts/FlashLoan.sol`**: Implements the main flash loan logic, including multi-protocol routing and loan repayment.
- **`contracts/ERC20.sol`**: Defines a custom ERC20 token (`MyToken`) with support for ERC20Permit.
- **`contracts/base/DodoBase.sol`**: Provides base functionality for interacting with DODO flash loan pools.
- **`contracts/base/FlashloanValidation.sol`**: Contains validation logic for flash loan parameters.
- **`contracts/base/Withdraw.sol`**: Allows the contract owner to withdraw ERC20 tokens from the contract.
- **`contracts/interfaces/IFlashloan.sol`**: Defines interfaces for flash loan parameters and routing.
- **`contracts/interfaces/IDODO.sol`**: Interface for interacting with DODO flash loan pools.
- **`contracts/interfaces/IDODOProxy.sol`**: Interface for DODO proxy swaps.
- **`contracts/interfaces/IDODOV2.sol`**: Interface for querying DODO V2 pools.
- **`contracts/uniswap/IUniswapV2Router.sol`**: Interface for Uniswap V2 router.
- **`contracts/uniswap/V3/ISwapRouter.sol`**: Interface for Uniswap V3 router.
- **`contracts/libraries/RouteUtils.sol`**: Utility library for handling token routes in swaps.
- **`contracts/libraries/Part.sol`**: Library for calculating token amounts based on parts.
- **`contracts/libraries/BytestLib.sol`**: Utility library for merging byte arrays.

### Constants
- **`constants/index.ts`**: Defines protocol IDs, router addresses, and DODO pool addresses.
- **`constants/tokens.ts`**: Contains metadata for supported ERC20 tokens, including addresses and symbols.

### Scripts
- **`scripts/deployDodoFlashloan.ts`**: Script for deploying the `FlashLoan` contract.
- **`scripts/executeFlashloan.ts`**: Script for executing a flash loan transaction.
- **`scripts/quote.ts`**: Script for fetching token swap quotes using Uniswap V3 Quoter contracts.

### Utilities
- **`utils/deployContract.ts`**: Utility function for deploying smart contracts.
- **`utils/findRouterByProtocol.ts`**: Utility function for retrieving router addresses based on protocol IDs.

### Types
- **`types/index.ts`**: Defines TypeScript types for flash loan parameters, tokens, and protocols.

### Tests
- **`test/index.test.ts`**: Contains test cases for deploying and executing flash loans.

### Configuration
- **`hardhat.config.ts`**: Configuration file for the Hardhat development environment.
- **`tsconfig.json`**: TypeScript configuration file.
- **`package.json`**: Node.js project metadata and dependencies.

### Other
- **`.gitignore`**: Specifies files and directories to be ignored by Git.

## How to Use
1. **Install Dependencies**: Run `npm install` to install the required dependencies.
2. **Compile Contracts**: Use `npx hardhat compile` to compile the smart contracts.
3. **Deploy Contracts**: Run the deployment script using `npx hardhat run scripts/deployDodoFlashloan.ts`.
4. **Execute Flash Loans**: Use the `executeFlashloan.ts` script to initiate a flash loan.
5. **Run Tests**: Execute `npx hardhat test` to run the test suite.

## Dependencies
- Hardhat
- Ethers.js
- OpenZeppelin Contracts
- Uniswap V3 Core and Periphery

## License
This project is licensed under the MIT License.