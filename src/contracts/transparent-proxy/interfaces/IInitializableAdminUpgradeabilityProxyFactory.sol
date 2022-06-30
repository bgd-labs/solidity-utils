// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface IInitializableAdminUpgradeabilityProxyFactory {
  event ProxyCreated(address proxy, address logic, address admin);

  function create(
    address logic,
    address admin,
    bytes memory data
  ) external returns (address);
}
