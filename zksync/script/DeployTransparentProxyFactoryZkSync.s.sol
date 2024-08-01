// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {TransparentProxyFactoryZkSync} from '../src/contracts/transparent-proxy/TransparentProxyFactoryZkSync.sol';

contract DeployZkSync is Script {
  function run() external {
    vm.startBroadcast();
    new TransparentProxyFactoryZkSync();
    vm.stopBroadcast();
  }
}
