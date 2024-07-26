// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IOwnable} from './interfaces/IOwnable.sol';
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
  function create(
    address logic,
    address admin,
    bytes calldata data
  ) external returns (address) {
    address proxy = address(new TransparentUpgradeableProxy(logic, admin, data));

    emit ProxyCreated(proxy, logic, admin);
    return proxy;
  }

  /// @inheritdoc ITransparentProxyFactory
  function createProxyAdmin(address adminOwner) external returns (address) {
    address proxyAdmin = address(new ProxyAdmin());
    IOwnable(proxyAdmin).transferOwnership(adminOwner);

    emit ProxyAdminCreated(proxyAdmin, adminOwner);
    return proxyAdmin;
  }

  /// @inheritdoc ITransparentProxyFactory
  function createDeterministic(
    address logic,
    address admin,
    bytes calldata data,
    bytes32 salt
  ) external returns (address) {
    address proxy = address(new TransparentUpgradeableProxy{salt: salt}(logic, admin, data));

    emit ProxyDeterministicCreated(proxy, logic, admin, salt);
    return proxy;
  }

  /// @inheritdoc ITransparentProxyFactory
  function createDeterministicProxyAdmin(address adminOwner, bytes32 salt)
    external
    returns (address)
  {
    address proxyAdmin = address(new ProxyAdmin{salt: salt}());
    IOwnable(proxyAdmin).transferOwnership(adminOwner);

    emit ProxyAdminDeterministicCreated(proxyAdmin, adminOwner, salt);
    return proxyAdmin;
  }

  /// @inheritdoc ITransparentProxyFactory
  function predictCreateDeterministic(
    address logic,
    address admin,
    bytes calldata data,
    bytes32 salt
  ) public view override returns (address) {
    return
      _predictCreate2Address(
        address(this),
        salt,
        type(TransparentUpgradeableProxy).creationCode,
        abi.encode(logic, admin, data)
      );
  }

  /// @inheritdoc ITransparentProxyFactory
  function predictCreateDeterministicProxyAdmin(bytes32 salt)
    public
    view
    override
    returns (address)
  {
    return _predictCreate2Address(address(this), salt, type(ProxyAdmin).creationCode, abi.encode());
  }

  function _predictCreate2Address(
    address creator,
    bytes32 salt,
    bytes memory creationCode,
    bytes memory constructorArgs
  ) internal pure virtual returns (address);
}
