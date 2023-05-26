// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {ImmutableBeaconProxy, IBeacon} from '../src/contracts/immutable-beacon-proxy/ImmutableBeaconProxy.sol';

contract ImplementationMock {
  function testFunction() external pure returns (uint256) {
    return 1111;
  }
}

contract BeaconMock is IBeacon {
  address public implementation;

  constructor(address newImplementation) {
    implementation = newImplementation;
  }
}

contract Deploy is Script {
  function run() external {
    vm.startBroadcast();
    address impl = address(new ImplementationMock());
    address beacon = address(new BeaconMock(impl));
    new ImmutableBeaconProxy(beacon);
    vm.stopBroadcast();
  }
}
