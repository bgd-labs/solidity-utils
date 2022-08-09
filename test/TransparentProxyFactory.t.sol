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

  function testCreateDeterministicWithProxyAdmin() public {
    uint256 FOO = 2;
    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    (address proxy1, address proxyAdmin) = factory.createDeterministicWithProxyAdmin(
      address(mockImpl),
      address(2),
      data,
      bytes32(uint256(1)),
      bytes32(uint256(2))
    );

    (address predictedProxy, address predictedProxyAdmin) = factory.predictCreateDeterministicWithDeterministicProxyAdmin(
      address(mockImpl),
      data,
      bytes32(uint256(2)),
      bytes32(uint256(1))
    );

    address proxyOwner = IOwnable(proxyAdmin).owner();

    assertEq(predictedProxy, proxy1);
    assertEq(predictedProxyAdmin, proxyAdmin);
    assertEq(MockImpl(proxy1).getFoo(), FOO);
    assertEq(proxyOwner, address(2));

    hoax(proxyAdmin);
    address checkAdmin = TransparentUpgradeableProxy(payable(proxy1)).admin();
    assertEq(checkAdmin, proxyAdmin);
  }
}
