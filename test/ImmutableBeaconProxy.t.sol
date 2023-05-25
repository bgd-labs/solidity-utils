// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import 'forge-std/Test.sol';
import {ImmutableBeaconProxy, IBeacon} from '../src/contracts/transparent-proxy/ImmutableBeaconProxy.sol';

contract ImplementationMock {}

contract BeaconMock is IBeacon {
  address public implementation;

  constructor(address newImplementation) {
    implementation = newImplementation;
  }
}

contract ImmutableBeaconProxyMock is ImmutableBeaconProxy {
  constructor(address beacon) ImmutableBeaconProxy(beacon) {}

  function implementation() public view returns (address) {
    return _implementation();
  }
}

contract ImmutableBeaconProxyTest is Test {
  function testResolvesImplementationCorrectly() public {
    address implementation = address(new ImplementationMock());
    address beacon = address(new BeaconMock(implementation));

    assertEq(implementation, (new ImmutableBeaconProxyMock(beacon)).implementation());
  }

  function testBeaconNotAContract() public {
    vm.expectRevert(bytes('INVALID_BEACON'));
    new ImmutableBeaconProxy(address(1));
  }

  function testImplementationNotAContract() public {
    address beacon = address(new BeaconMock(address(1)));

    vm.expectRevert(bytes('INVALID_IMPLEMENTATION'));
    new ImmutableBeaconProxy(beacon);
  }
}
