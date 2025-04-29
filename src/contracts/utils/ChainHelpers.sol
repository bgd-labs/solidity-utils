// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Vm} from 'forge-std/Vm.sol';

library ChainIds {
  uint256 internal constant MAINNET = 1;
  uint256 internal constant ETHEREUM = 1;
  uint256 internal constant OPTIMISM = 10;
  uint256 internal constant BNB = 56;
  uint256 internal constant POLYGON = 137;
  uint256 internal constant FANTOM = 250;
  uint256 internal constant ZKSYNC = 324;
  uint256 internal constant METIS = 1088;
  uint256 internal constant ZK_EVM = 1101;
  uint256 internal constant BASE = 8453;
  uint256 internal constant ARBITRUM = 42161;
  uint256 internal constant AVALANCHE = 43114;
  uint256 internal constant GNOSIS = 100;
  uint256 internal constant SCROLL = 534352;
  uint256 internal constant SEPOLIA = 11155111;
  uint256 internal constant HARMONY = 1666600000;
  uint256 internal constant CELO = 42220;
  uint256 internal constant POLYGON_ZK_EVM = 1101;
  uint256 internal constant LINEA = 59144;
  uint256 internal constant SONIC = 146;
  uint256 internal constant MANTLE = 5000;
  uint256 internal constant INK = 57073;
  uint256 internal constant SONEIUM = 1868;
}

library TestNetChainIds {
  uint256 internal constant ETHEREUM_SEPOLIA = 11155111;
  uint256 internal constant POLYGON_AMOY = 80002;
  uint256 internal constant AVALANCHE_FUJI = 43113;
  uint256 internal constant FANTOM_TESTNET = 4002;
  uint256 internal constant HARMONY_TESTNET = 1666700000;
  uint256 internal constant METIS_TESTNET = 599;
  uint256 internal constant BNB_TESTNET = 97;
  uint256 internal constant GNOSIS_CHIADO = 10200;
  uint256 internal constant SCROLL_SEPOLIA = 534351;
  uint256 internal constant BASE_SEPOLIA = 84532;
  uint256 internal constant CELO_ALFAJORES = 44787;
  uint256 internal constant OPTIMISM_SEPOLIA = 11155420;
  uint256 internal constant ARBITRUM_SEPOLIA = 421614;
  uint256 internal constant ZKSYNC_SEPOLIA = 300;
  uint256 internal constant LINEA_SEPOLIA = 59141;
  uint256 internal constant SONIC_BLAZE = 57054;
  uint256 internal constant MANTLE_SEPOLIA = 5003;
  uint256 internal constant SONEIUM_MINATO = 1946;
}

library ChainHelpers {
  error UnknownChainId();

  function selectChain(Vm vm, uint256 chainId) internal returns (uint256, uint256) {
    uint256 previousFork = vm.activeFork();
    if (chainId == block.chainid) return (previousFork, previousFork);
    uint256 newFork;
    if (chainId == ChainIds.MAINNET) {
      newFork = vm.createSelectFork(vm.rpcUrl('mainnet'));
    } else if (chainId == ChainIds.OPTIMISM) {
      newFork = vm.createSelectFork(vm.rpcUrl('optimism'));
    } else if (chainId == ChainIds.BNB) {
      newFork = vm.createSelectFork(vm.rpcUrl('bnb'));
    } else if (chainId == ChainIds.POLYGON) {
      newFork = vm.createSelectFork(vm.rpcUrl('polygon'));
    } else if (chainId == ChainIds.FANTOM) {
      newFork = vm.createSelectFork(vm.rpcUrl('fantom'));
    } else if (chainId == ChainIds.ZKSYNC) {
      newFork = vm.createSelectFork(vm.rpcUrl('zkSync'));
    } else if (chainId == ChainIds.METIS) {
      newFork = vm.createSelectFork(vm.rpcUrl('metis'));
    } else if (chainId == ChainIds.ZK_EVM) {
      newFork = vm.createSelectFork(vm.rpcUrl('zkEvm'));
    } else if (chainId == ChainIds.BASE) {
      newFork = vm.createSelectFork(vm.rpcUrl('base'));
    } else if (chainId == ChainIds.GNOSIS) {
      newFork = vm.createSelectFork(vm.rpcUrl('gnosis'));
    } else if (chainId == ChainIds.SCROLL) {
      newFork = vm.createSelectFork(vm.rpcUrl('scroll'));
    } else if (chainId == ChainIds.ARBITRUM) {
      newFork = vm.createSelectFork(vm.rpcUrl('arbitrum'));
    } else if (chainId == ChainIds.AVALANCHE) {
      newFork = vm.createSelectFork(vm.rpcUrl('avalanche'));
    } else if (chainId == ChainIds.SEPOLIA) {
      newFork = vm.createSelectFork(vm.rpcUrl('sepolia'));
    } else if (chainId == ChainIds.HARMONY) {
      newFork = vm.createSelectFork(vm.rpcUrl('harmony'));
    } else if (chainId == ChainIds.ZKSYNC) {
      newFork = vm.createSelectFork(vm.rpcUrl('zksync'));
    } else if (chainId == ChainIds.LINEA) {
      newFork = vm.createSelectFork(vm.rpcUrl('linea'));
    } else if (chainId == ChainIds.CELO) {
      newFork = vm.createSelectFork(vm.rpcUrl('celo'));
    } else if (chainId == ChainIds.SONIC) {
      newFork = vm.createSelectFork(vm.rpcUrl('sonic'));
    } else if (chainId == ChainIds.MANTLE) {
      newFork = vm.createSelectFork(vm.rpcUrl('mantle'));
    } else if (chainId == ChainIds.INK) {
      newFork = vm.createSelectFork(vm.rpcUrl('ink'));
    } else if (chainId == ChainIds.SONEIUM) {
      newFork = vm.createSelectFork(vm.rpcUrl('soneium'));
    } else {
      revert UnknownChainId();
    }
    return (previousFork, newFork);
  }

  function getNetworkNameFromId(uint256 chainId) internal pure returns (string memory) {
    string memory networkName;
    if (chainId == ChainIds.ETHEREUM) {
      networkName = 'ethereum';
    } else if (chainId == ChainIds.POLYGON) {
      networkName = 'polygon';
    } else if (chainId == ChainIds.AVALANCHE) {
      networkName = 'avalanche';
    } else if (chainId == ChainIds.ARBITRUM) {
      networkName = 'arbitrum';
    } else if (chainId == ChainIds.OPTIMISM) {
      networkName = 'optimism';
    } else if (chainId == ChainIds.METIS) {
      networkName = 'metis';
    } else if (chainId == ChainIds.BNB) {
      networkName = 'binance';
    } else if (chainId == ChainIds.BASE) {
      networkName = 'base';
    } else if (chainId == ChainIds.POLYGON_ZK_EVM) {
      networkName = 'zkevm';
    } else if (chainId == ChainIds.GNOSIS) {
      networkName = 'gnosis';
    } else if (chainId == ChainIds.SCROLL) {
      networkName = 'scroll';
    } else if (chainId == ChainIds.CELO) {
      networkName = 'celo';
    } else if (chainId == ChainIds.ZKSYNC) {
      networkName = 'zksync';
    } else if (chainId == ChainIds.LINEA) {
      networkName = 'linea';
    } else if (chainId == ChainIds.SONIC) {
      networkName = 'sonic';
    } else if (chainId == ChainIds.MANTLE) {
      networkName = 'mantle';
    } else if (chainId == ChainIds.INK) {
      networkName = 'ink';
    } else if (chainId == ChainIds.SONEIUM) {
      networkName = 'soneium';
    }
    // testnets
    else if (chainId == TestNetChainIds.ETHEREUM_SEPOLIA) {
      networkName = 'ethereum_sepolia';
    } else if (chainId == TestNetChainIds.POLYGON_AMOY) {
      networkName = 'polygon_amoy';
    } else if (chainId == TestNetChainIds.AVALANCHE_FUJI) {
      networkName = 'avalanche_fuji';
    } else if (chainId == TestNetChainIds.ARBITRUM_SEPOLIA) {
      networkName = 'arbitrum_sepolia';
    } else if (chainId == TestNetChainIds.OPTIMISM_SEPOLIA) {
      networkName = 'optimism_sepolia';
    } else if (chainId == TestNetChainIds.METIS_TESTNET) {
      networkName = 'metis_test';
    } else if (chainId == TestNetChainIds.BNB_TESTNET) {
      networkName = 'binance_testnet';
    } else if (chainId == TestNetChainIds.BASE_SEPOLIA) {
      networkName = 'base_sepolia';
    } else if (chainId == TestNetChainIds.GNOSIS_CHIADO) {
      networkName = 'gno_chiado';
    } else if (chainId == TestNetChainIds.SCROLL_SEPOLIA) {
      networkName = 'scroll_sepolia';
    } else if (chainId == TestNetChainIds.CELO_ALFAJORES) {
      networkName = 'celo_alfajores';
    } else if (chainId == TestNetChainIds.ZKSYNC_SEPOLIA) {
      networkName = 'zksync_sepolia';
    } else if (chainId == TestNetChainIds.LINEA_SEPOLIA) {
      networkName = 'linea_sepolia';
    } else if (chainId == TestNetChainIds.SONIC_BLAZE) {
      networkName = 'sonic_blaze';
    } else if (chainId == TestNetChainIds.MANTLE_SEPOLIA) {
      networkName = 'mantle_sepolia';
    } else if (chainId == TestNetChainIds.SONEIUM_MINATO) {
      networkName = 'soneium_minato';
    } else {
      revert('chain id is not supported');
    }

    return networkName;
  }
}
