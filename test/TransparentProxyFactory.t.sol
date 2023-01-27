// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {TransparentProxyFactory} from '../src/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {TransparentUpgradeableProxy} from '../src/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {IOwnable} from '../src/contracts/transparent-proxy/interfaces/IOwnable.sol';
import {MockImpl} from '../src/mocks/MockImpl.sol';

contract TestTransparentProxyFactory is Test {
  TransparentProxyFactory factory;
  MockImpl mockImpl;

  function setUp() public {
    factory = new TransparentProxyFactory();
    mockImpl = new MockImpl();
  }

  function testCreateDeterministic() public {
    uint256 FOO = 2;

    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    address predictedAddress1 = factory.predictCreateDeterministic(
      address(mockImpl),
      address(1),
      data,
      bytes32(uint256(1))
    );

    address proxy1 = factory.createDeterministic(
      address(mockImpl),
      address(1),
      data,
      bytes32(uint256(1))
    );

    assertEq(predictedAddress1, proxy1);
    assertEq(MockImpl(proxy1).getFoo(), FOO);
  }

  function testCreateDeterministicWithDeterministicProxy() public {
    address deterministicProxyAdmin = factory.predictCreateDeterministicProxyAdmin(
      bytes32(uint256(2))
    );

    uint256 FOO = 2;

    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    address predictedAddress1 = factory.predictCreateDeterministic(
      address(mockImpl),
      deterministicProxyAdmin,
      data,
      bytes32(uint256(1))
    );

    address proxy1 = factory.createDeterministic(
      address(mockImpl),
      deterministicProxyAdmin,
      data,
      bytes32(uint256(1))
    );

    assertEq(predictedAddress1, proxy1);
    assertEq(MockImpl(proxy1).getFoo(), FOO);
  }

  function testCreateDeterministicProxyAdmin() public {
    address proxyAdmin = factory.createDeterministicProxyAdmin(address(2), bytes32(uint256(2)));

    address predictedProxyAdmin = factory.predictCreateDeterministicProxyAdmin(bytes32(uint256(2)));

    address proxyOwner = IOwnable(proxyAdmin).owner();

    assertEq(predictedProxyAdmin, proxyAdmin);
    assertEq(proxyOwner, address(2));
  }

  function testCreateProxyAdmin() public {
    address proxyAdmin = factory.createDeterministicProxyAdmin(address(2), bytes32(uint256(2)));

    address proxyOwner = IOwnable(proxyAdmin).owner();
    assertEq(proxyOwner, address(2));
  }
}
