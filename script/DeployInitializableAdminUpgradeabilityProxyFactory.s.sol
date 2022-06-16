// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from '../lib/forge-std/src/Script.sol';
import {
  InitializableAdminUpgradeabilityProxyFactory
} from '../src/contracts/transparent-proxy/InitializableAdminUpgradeabilityProxyFactory.sol';

contract Deploy is Script {
  function run() external {
    vm.startBroadcast();
    new InitializableAdminUpgradeabilityProxyFactory();
    vm.stopBroadcast();
  }
}
