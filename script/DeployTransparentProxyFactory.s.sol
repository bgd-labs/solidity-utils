// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {TransparentProxyFactory} from '../src/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {TransparentProxyFactoryZkSync} from '../src-zksync/contracts/transparent-proxy/TransparentProxyFactoryZkSync.sol';

contract Deploy is Script {
  function run() external {
    vm.startBroadcast();
    new TransparentProxyFactory();
    vm.stopBroadcast();
  }
}

contract DeployZkSync is Script {
  function run() external {
    vm.startBroadcast();
    new TransparentProxyFactoryZkSync();
    vm.stopBroadcast();
  }
}
