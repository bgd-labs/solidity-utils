// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Ownable} from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import {ProxyAdmin} from 'openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol';
import {TransparentProxyFactory} from '../src/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {MockImpl} from './mocks/MockImpl.sol';

contract TestTransparentProxyFactory is Test {
  TransparentProxyFactory internal factory;
  MockImpl internal mockImpl;

  function setUp() public {
    factory = new TransparentProxyFactory();
    mockImpl = new MockImpl();
  }

  function test_createProxy() external {
    address owner = makeAddr('admin');
    uint256 FOO = 2;
    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);
    {
      address proxy = factory.create(address(mockImpl), owner, data);

      address proxyAdmin = factory.getProxyAdmin(proxy);
      assertEq(ProxyAdmin(proxyAdmin).owner(), owner);
    }
    {
      address proxy = factory.create(address(mockImpl), owner, data);

      address proxyAdmin = factory.getProxyAdmin(proxy);
      assertEq(ProxyAdmin(proxyAdmin).owner(), owner);
    }
  }

  function test_createDeterministicProxy(address initialOwner, bytes32 salt) public {
    // we know that this is covered at the ERC1967Upgrade
    vm.assume(initialOwner != address(0) && initialOwner != address(this));

    uint256 FOO = 2;
    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    address predictedAddress1 = factory.predictCreateDeterministic(
      address(mockImpl),
      initialOwner,
      data,
      salt
    );

    address proxy1 = factory.createDeterministic(address(mockImpl), initialOwner, data, salt);

    assertEq(predictedAddress1, proxy1);
    assertEq(MockImpl(proxy1).getFoo(), FOO);
    address proxyAdmin = factory.getProxyAdmin(proxy1);
    assertEq(ProxyAdmin(proxyAdmin).owner(), initialOwner);
  }

  function testCreateDeterministicWithDeterministicProxy(
    bytes32 proxyAdminSalt,
    bytes32 proxySalt
  ) public {
    address owner = makeAddr('owner');
    uint256 FOO = 2;
    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    address predictedAddress1 = factory.predictCreateDeterministic(
      address(mockImpl),
      owner,
      data,
      proxySalt
    );

    address proxy1 = factory.createDeterministic(address(mockImpl), owner, data, proxySalt);

    assertEq(predictedAddress1, proxy1);
    assertEq(MockImpl(proxy1).getFoo(), FOO);
  }

  function testCreateDeterministicProxyAdmin(
    address proxyAdminOwner,
    bytes32 proxyAdminSalt
  ) public {
    // we know that this is covered at the ProxyAdmin contract
    vm.assume(proxyAdminOwner != address(0));

    address proxyAdmin = factory.createDeterministicProxyAdmin(proxyAdminOwner, proxyAdminSalt);

    address predictedProxyAdmin = factory.predictCreateDeterministicProxyAdmin(
      proxyAdminSalt,
      proxyAdminOwner
    );

    address proxyOwner = Ownable(proxyAdmin).owner();

    assertEq(predictedProxyAdmin, proxyAdmin);
    assertEq(proxyOwner, proxyAdminOwner);
  }

  function testCreateProxyAdmin(address proxyAdminOwner, bytes32 proxyAdminSalt) public {
    // we know that this is covered at the ProxyAdmin contract
    vm.assume(proxyAdminOwner != address(0));

    address proxyAdmin = factory.createDeterministicProxyAdmin(proxyAdminOwner, proxyAdminSalt);
    assertEq(Ownable(proxyAdmin).owner(), proxyAdminOwner);
  }
}
