// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ITransparentProxyFactory} from './interfaces/ITransparentProxyFactory.sol';
import {TransparentUpgradeableProxy} from './TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from './ProxyAdmin.sol';

/**
 * @title TransparentProxyFactory
 * @author BGD Labs
 * @notice Factory contract to create transparent proxies, both with CREATE and CREATE2
 * @dev `create()` and `createDeterministic()` are not unified for clearer interface, and at the same
 * time allowing `createDeterministic()` with salt == 0
 * @dev Highly recommended to pass as `admin` on creation an OZ ProxyAdmin instance
 **/
abstract contract TransparentProxyFactoryBase is ITransparentProxyFactory {
  /// @inheritdoc ITransparentProxyFactory
  function create(address logic, ProxyAdmin admin, bytes calldata data) external returns (address) {
    return _create(logic, address(admin), data, true);
  }

  /// @inheritdoc ITransparentProxyFactory
  function createAndDeployNewAdmin(
    address logic,
    address initialOwner,
    bytes calldata data
  ) external returns (address) {
    return _create(logic, initialOwner, data, false);
  }

  function _create(
    address logic,
    address admin,
    bytes calldata data,
    bool reuseAdmin
  ) internal returns (address) {
    address proxy = address(new TransparentUpgradeableProxy(logic, admin, data, reuseAdmin));

    emit ProxyCreated(proxy, logic, address(admin));
    return proxy;
  }

  /// @inheritdoc ITransparentProxyFactory
  function createProxyAdmin(address adminOwner) external returns (address) {
    address proxyAdmin = address(new ProxyAdmin(adminOwner));

    emit ProxyAdminCreated(proxyAdmin, adminOwner);
    return proxyAdmin;
  }

  /// @inheritdoc ITransparentProxyFactory
  function createDeterministic(
    address logic,
    ProxyAdmin admin,
    bytes calldata data,
    bytes32 salt
  ) external returns (address) {
    return _createDeterministic(logic, address(admin), data, true, salt);
  }

  /// @inheritdoc ITransparentProxyFactory
  function createDeterministicAndDeployNewAdmin(
    address logic,
    address initialOwner,
    bytes calldata data,
    bytes32 salt
  ) external returns (address) {
    return _createDeterministic(logic, initialOwner, data, false, salt);
  }

  function _createDeterministic(
    address logic,
    address ownerOrAdmin,
    bytes calldata data,
    bool reuseAdmin,
    bytes32 salt
  ) internal returns (address) {
    address proxy = address(
      new TransparentUpgradeableProxy{salt: salt}(logic, ownerOrAdmin, data, reuseAdmin)
    );

    emit ProxyDeterministicCreated(proxy, logic, address(ownerOrAdmin), salt);
    return proxy;
  }

  /// @inheritdoc ITransparentProxyFactory
  function createDeterministicProxyAdmin(
    address adminOwner,
    bytes32 salt
  ) external returns (address) {
    address proxyAdmin = address(new ProxyAdmin{salt: salt}(adminOwner));

    emit ProxyAdminDeterministicCreated(proxyAdmin, adminOwner, salt);
    return proxyAdmin;
  }

  /// @inheritdoc ITransparentProxyFactory
  function predictCreateDeterministic(
    address logic,
    ProxyAdmin admin,
    bytes calldata data,
    bytes32 salt
  ) public view returns (address) {
    return
      _predictCreate2Address(
        address(this),
        salt,
        type(TransparentUpgradeableProxy).creationCode,
        abi.encode(logic, address(admin), data, true)
      );
  }

  /// @inheritdoc ITransparentProxyFactory
  function predictCreateDeterministicAndDeployNewAdmin(
    address logic,
    address initialOwner,
    bytes calldata data,
    bytes32 salt
  ) public view returns (address) {
    return
      _predictCreate2Address(
        address(this),
        salt,
        type(TransparentUpgradeableProxy).creationCode,
        abi.encode(logic, address(initialOwner), data, false)
      );
  }

  /// @inheritdoc ITransparentProxyFactory
  function predictCreateDeterministicProxyAdmin(
    bytes32 salt,
    address initialOwner
  ) public view returns (address) {
    return
      _predictCreate2Address(
        address(this),
        salt,
        type(ProxyAdmin).creationCode,
        abi.encode(initialOwner)
      );
  }

  function _predictCreate2Address(
    address creator,
    bytes32 salt,
    bytes memory creationCode,
    bytes memory constructorArgs
  ) internal pure virtual returns (address);
}
