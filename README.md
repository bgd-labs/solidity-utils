# BGD Labs Solidity utils

Common contracts we use almost everywhere

## Create3

Contracts to deploy a Create3 Factory which so that contract addresses can be predicted without influence from
constructor arguments.

These contracts where modified from:

- Create3 lib:
  Modified from https://github.com/0xsequence/create3/blob/5a4a152e6be4e0ecfbbbe546992a5aaa43a4c1b0/contracts/Create3.sol by Agustin Aguilar <aa@horizon.io>
  - Modifications consist on:
    - removal of named returns
    - moved logic of addressOf method to addressOfWithPreDeployedFactory so that factory address can be abstracted
- Create3Factory:
  Modified from https://github.com/lifinance/create3-factory/blob/main/src/CREATE3Factory.sol
  - Modifications consist on:
    - removal of named returns
    - changed name of getDeployed for predictAddress
    - usage of create3 lib by Agustin Aguilar instead of solmate

## ZkSync

As ZkSync network requires the use of a [forked](https://github.com/matter-labs/foundry-zksync) version of foundry we have created different profiles so that they can run
as expected.

- Contracts specific for ZkSync network can be found [here](src-zksync)
- Tests specific for ZkSync network can be found [here](test-zksync)

To build and test the contracts use `FOUNDRY_PROFILE=zksync` and the flag `--zksync`

- Example:

```solidity
FOUNDRY_PROFILE=zksync forge test -vvv --zksync
```
