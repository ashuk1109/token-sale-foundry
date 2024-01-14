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

### About the Contract
The contract uses a SupraToken which is an ERC20 Token for the Pre sale and Public sale. 
The owner has been given the option to stop the sale in case of any unforeseen emergency.
The tests are written so as to cover all the functionalities and edge cases as well as ensure safety of the contract.
Initially all tokens are minted to the owner address.
A sale phase minCap has been introduced to streamline the refund process.
Users can claim refund for the specific phase only when the particular phase has passed and no other phase is active i.e. between preSale and publicSale or after publicSale and the minCap for sale is not reached.

This specific project uses the *Foundry framework*. 

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
$ forge script script/DeployTokenSale.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
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

## Foundry Documentation

https://book.getfoundry.sh/
