// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {TransparentUpgradeableProxy} from 'openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from 'openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol';
import {ITransparentProxyFactory} from './interfaces/ITransparentProxyFactory.sol';

/**
 * @title TransparentProxyFactory
 * @author BGD Labs
 * @notice Factory contract to create transparent proxies, both with CREATE and CREATE2
 * @dev `create()` and `createDeterministic()` are not unified for clearer interface, and at the same
 * time allowing `createDeterministic()` with salt == 0
 * @dev Highly recommended to pass as `admin` on creation an OZ ProxyAdmin instance
 **/
abstract contract TransparentProxyFactoryBase is ITransparentProxyFactory {
  mapping(address proxy => address admin) internal _proxyToAdmin;

  function getProxyAdmin(address proxy) external view returns (address) {
    return _proxyToAdmin[proxy];
  }

  /// @inheritdoc ITransparentProxyFactory
  function create(
    address logic,
    address adminOwner,
    bytes calldata data
  ) external returns (address) {
    address proxy = address(new TransparentUpgradeableProxy(logic, adminOwner, data));
    _storeProxyInRegistry(proxy);

    emit ProxyCreated(proxy, logic, address(adminOwner));

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
    address adminOwner,
    bytes calldata data,
    bytes32 salt
  ) external returns (address) {
    address proxy = address(new TransparentUpgradeableProxy{salt: salt}(logic, adminOwner, data));
    _storeProxyInRegistry(proxy);

    emit ProxyDeterministicCreated(proxy, logic, address(adminOwner), salt);
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
    address admin,
    bytes calldata data,
    bytes32 salt
  ) public view returns (address) {
    return
      _predictCreate2Address(
        address(this),
        salt,
        type(TransparentUpgradeableProxy).creationCode,
        abi.encode(logic, admin, data)
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

  function _storeProxyInRegistry(address proxy) internal {
    _proxyToAdmin[proxy] = _predictProxyAdminAddress(proxy);
  }

  /**
   * @dev the prediction only depends on the address of the proxy.
   * The admin is always the first and only contract deployed by the proxy.
   */
  function _predictProxyAdminAddress(address proxy) internal pure virtual returns (address) {
    return
      address(
        uint160(
          uint256(
            keccak256(
              abi.encodePacked(
                bytes1(0xd6), // RLP prefix for a list with total length 22
                bytes1(0x94), // RLP prefix for an address (20 bytes)
                proxy, // 20-byte address
                uint8(1) // 1-byte nonce
              )
            )
          )
        )
      );
  }
}
