// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * The package relies on OZ-v5, some legacy contracts rely on the oz v4 versions of `TransparentUpgradeableProxy` and `ProxyAdmin`.
 * While we no longer recommend deploying new instances of these, we expose the interface to allow interacting with existing contracts.
 */

interface IProxyAdminOzV4 {
  function changeProxyAdmin(address proxy, address newAdmin) external;

  function upgrade(address proxy, address implementation) external;

  function upgradeAndCall(address proxy, address implementation, bytes memory data) external;
}
