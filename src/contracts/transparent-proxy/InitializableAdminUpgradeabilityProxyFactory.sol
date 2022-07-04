// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import {IInitializableAdminUpgradeabilityProxyFactory} from './interfaces/IInitializableAdminUpgradeabilityProxyFactory.sol';
import {InitializableAdminUpgradeabilityProxy} from './InitializableAdminUpgradeabilityProxy.sol';

contract InitializableAdminUpgradeabilityProxyFactory is
  IInitializableAdminUpgradeabilityProxyFactory
{
  function create(
    address logic,
    address admin,
    bytes calldata data
  ) external override returns (address) {
    InitializableAdminUpgradeabilityProxy proxy = new InitializableAdminUpgradeabilityProxy();
    proxy.initialize(logic, admin, data);

    emit ProxyCreated(address(proxy), logic, admin);
    return address(proxy);
  }
}
