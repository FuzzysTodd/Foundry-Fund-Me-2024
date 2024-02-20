## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


### Summary.
The smart contract is called FundMe and it works similar to a wallet. This contract can be funded by users that want to send ETH to it and the owner of the contract can withdraw the funds. This contract can be deployed to any testnet or mainnet, and it can even be deployed locally on Anvil, which is a fictitious blockchain that is created when an RPC-URL is not specified in the terminal. 

### Deploy
forge script script/DeployFundMe.s.sol

### Testing
forge test
or
forge tet --mt 'testFunctionName'

### Test Coverage
forge coverage

### Deployment to a Testnet or Mainnet
It will be needed to set a SEPOLIA_RPC_URL (this is a url of the Sepolia testnet node. You can get setup with a free one from Alchemy) and a PRIVATE_KEY (this can be taken from your Metamask wallet, but please make sure it does not has real funds associated with it, as it is for development purposes only) as environment variables. These variables can be added to a .env file.

### Estimate Gas Costs
forge snapshot

