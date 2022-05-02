# Where to get started 

Please reference the Wiki first for details on our progress.

# HonestNFT Protocol: Deploying contracts:

First, you have to make sure that you have a `.env` file in the root directory that looks somewhat like this:

```shell
API_URL = "https://eth-rinkeby.alchemyapi.io/v2/yourAPIKeyThatYouObtainFromAlchemy"
PRIVATE_KEY = "YourWalletPrivateKey"
```

Then, you may deploy the contracts by running:

```shell
npx hardhat run --network rinkeby scripts/deploy.js
```

# Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network rinkeby DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```
