// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from 'forge-std/Test.sol';
import {TransparentProxyFactoryZkSync} from '../src/contracts/transparent-proxy/TransparentProxyFactoryZkSync.sol';
import {TransparentUpgradeableProxy} from '../../src/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {Ownable} from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import {ProxyAdmin} from '../../src/contracts/transparent-proxy/ProxyAdmin.sol';
import {MockImpl} from '../../src/mocks/MockImpl.sol';

contract TestTransparentProxyFactoryZkSync is Test {
  TransparentProxyFactoryZkSync internal factory;
  MockImpl internal mockImpl;
  ProxyAdmin internal proxyAdmin;
  address internal owner = makeAddr('owner');

  function setUp() public {
    factory = new TransparentProxyFactoryZkSync();
    mockImpl = new MockImpl();
    proxyAdmin = new ProxyAdmin(owner);
  }

  function testCreate() public {
    uint256 FOO = 2;
    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    address proxy = factory.create(address(mockImpl), proxyAdmin, data);
    assertTrue(proxy.code.length != 0);
  }

  function testCreateDeterministic(bytes32 salt) public {
    uint256 FOO = 2;
    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    address predictedAddress1 = factory.predictCreateDeterministic(
      address(mockImpl),
      proxyAdmin,
      data,
      salt
    );

    address proxy1 = factory.createDeterministic(address(mockImpl), proxyAdmin, data, salt);

    assertEq(predictedAddress1, proxy1);
    assertTrue(proxy1.code.length != 0);
    assertEq(MockImpl(proxy1).getFoo(), FOO);
  }

  function testCreateDeterministicWithDeterministicProxy(
    bytes32 proxyAdminSalt,
    bytes32 proxySalt
  ) public {
    address deterministicProxyAdmin = factory.predictCreateDeterministicProxyAdmin(
      proxyAdminSalt,
      address(owner)
    );

    uint256 FOO = 2;

    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    address predictedAddress1 = factory.predictCreateDeterministic(
      address(mockImpl),
      ProxyAdmin(deterministicProxyAdmin),
      data,
      proxySalt
    );

    address proxy1 = factory.createDeterministic(
      address(mockImpl),
      ProxyAdmin(deterministicProxyAdmin),
      data,
      proxySalt
    );

    assertEq(predictedAddress1, proxy1);
    assertEq(MockImpl(proxy1).getFoo(), FOO);
    assertTrue(predictedAddress1.code.length != 0);
  }

  function testCreateDeterministicProxyAdmin(
    address proxyAdminOwner,
    bytes32 proxyAdminSalt
  ) public {
    // we know that this is covered at the ProxyAdmin contract
    vm.assume(proxyAdminOwner != address(0) && proxyAdminOwner != address(this));

    address proxyAdmin = factory.createDeterministicProxyAdmin(proxyAdminOwner, proxyAdminSalt);

    address predictedProxyAdmin = factory.predictCreateDeterministicProxyAdmin(
      proxyAdminSalt,
      proxyAdminOwner
    );

    address proxyOwner = Ownable(proxyAdmin).owner();

    assertEq(predictedProxyAdmin, proxyAdmin);
    assertEq(proxyOwner, proxyAdminOwner);
    assertTrue(predictedProxyAdmin.code.length != 0);
  }

  function testCreateProxyAdmin(address proxyAdminOwner, bytes32 proxyAdminSalt) public {
    // we know that this is covered at the ProxyAdmin contract
    vm.assume(proxyAdminOwner != address(0) && proxyAdminOwner != address(this));

    address proxyAdmin = factory.createDeterministicProxyAdmin(proxyAdminOwner, proxyAdminSalt);
    assertTrue(proxyAdmin.code.length != 0);
    assertEq(Ownable(proxyAdmin).owner(), proxyAdminOwner);
  }
}
