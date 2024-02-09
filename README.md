# Blockchain-Based Certificate Verification System

## Introduction
This blockchain project facilitates the issuance, verification, and management of educational certificates on the Ethereum network. It consists of three smart contracts tailored for educational institutions, students, and employers, streamlining the certificate verification process for employment purposes.

## Prerequisites
- Node.js and npm
- Ethereum wallet with Ether (for deployment and transactions)
- Hardhat for smart contract compilation, deployment, and testing
- Alchemy or Infura (optional for deploying to public testnets/mainnet)

## Installation and Setup
1. Clone the repository and install dependencies:
   ```
   npm install
   ```
2. Prepare a `.env` file with your Ethereum wallet private key and Alchemy/Infura URL (for public network deployment):
   ```
   PRIVATE_KEY="<your-private-key>"
   ALCHEMY_URL="<your-alchemy-or-infura-url>"
   ```
3. Compile the smart contracts:
   ```
   npx hardhat compile
   ```

## Local Deployment
To deploy the contracts to a local Ethereum network for development and testing:
```
npx hardhat run scripts/deploy.js --network localhost
```
This command deploys the smart contracts to a local Hardhat network, allowing you to interact with them in a development environment.

## Running Tests
Execute the test suite using Hardhat to validate contract functionality:
```
npx hardhat test
```

## Test Coverage Report
Generate and view a test coverage report to assess how much of the code is covered by tests:
```
npx hardhat coverage
```
This command runs the test suite and generates a coverage report, detailing the percentage of code executed by the tests.

## Test Coverage Results

File                                       |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
-------------------------------------------|----------|----------|----------|----------|----------------|
 contracts\                                |    80.91 |    52.08 |    78.38 |    79.45 |                |
  EducationalInstitutionsSmartContract.sol |    82.35 |    71.43 |    77.78 |    86.36 |    112,115,119 |
  EmployerSmartContract.sol                |    84.09 |    42.86 |    81.25 |    86.21 |... 158,160,161 |
  StudentSmartContract.sol                 |    77.55 |    61.54 |       75 |    71.21 |... 115,125,135 |
All files                                  |    80.91 |    52.08 |    78.38 |    79.45 |                |

These metrics indicate the comprehensiveness of the test suite in covering the smart contract code, ensuring reliability and robustness of the deployed contracts.

## License
This project is licensed under the MIT License.

## Contributions and Contact
For contributions or queries, feel free to reach out to the project maintainers.

