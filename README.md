## Token Sale Smart Contract

This repository consists of a token sale smart contract for an ERC20 token.
The sale happens in 2 phases namely PreSale and Public Sale. All necessary details have been shared below under features.

### Features
### Presale:
1. Users can contribute Ether to the presale and receive project tokens in return.
2. The presale has a maximum cap on the total Ether that can be raised.
3. The presale has a minimum and maximum contribution limit per participant.
4. Tokens are distributed immediately upon contribution.
### Public Sale:
1. After the presale ends, the public sale begins.
2. Users can contribute Ether to the public sale and receive project tokens in return.
3. The public sale has a maximum cap on the total Ether that can be raised.
4. The public sale has a minimum and maximum contribution limit per participant.
5. Tokens are distributed immediately upon contribution.
### Token Distribution:
1. The smart contract should have a function to distribute project tokens to a specified
address. This function can only be called by the owner of the contract.
### Refund:
1. If the minimum cap for either the presale or public sale is not reached, contributors
should be able to claim a refund.


This specific project uses the *Foundry framework*. 


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
