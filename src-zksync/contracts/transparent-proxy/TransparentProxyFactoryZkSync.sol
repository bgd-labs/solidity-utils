// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IOwnable} from '../../../src/contracts/transparent-proxy/interfaces/IOwnable.sol';
import {ITransparentProxyFactoryZkSync} from './interfaces/ITransparentProxyFactoryZkSync.sol';
import {TransparentUpgradeableProxy} from '../../../src/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from '../../../src/contracts/transparent-proxy/ProxyAdmin.sol';

/**
 * @title TransparentProxyFactoryZkSync
 * @author BGD Labs
 * @notice Factory contract to create transparent proxies, both with CREATE and CREATE2
 * @dev `create()` and `createDeterministic()` are not unified for clearer interface, and at the same
 * time allowing `createDeterministic()` with salt == 0
 * @dev Highly recommended to pass as `admin` on creation an OZ ProxyAdmin instance
 * @dev This contract needs solc=0.8.19 and zksolc=1.4.1 as codeHashes are specifically made for those versions
 **/
contract TransparentProxyFactoryZkSync is ITransparentProxyFactoryZkSync {
  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH =
    0x010001b73fa7f2c39ea2d9c597a419e15436fc9d3e00e032410072fb94ad95e1;

  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant PROXY_ADMIN_INIT_CODE_HASH =
    0x010000e7f9a8b61da13fe7e27804d9f641f5f8db05b07df720973af749a01ac1;

  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant ZKSYNC_CREATE2_PREFIX = keccak256('zksyncCreate2');

  /// @inheritdoc ITransparentProxyFactoryZkSync
  function create(address logic, address admin, bytes calldata data) external returns (address) {
    address proxy = address(new TransparentUpgradeableProxy(logic, admin, data));

    emit ProxyCreated(proxy, logic, admin);
    return proxy;
  }

  /// @inheritdoc ITransparentProxyFactoryZkSync
  function createProxyAdmin(address adminOwner) external returns (address) {
    address proxyAdmin = address(new ProxyAdmin());
    IOwnable(proxyAdmin).transferOwnership(adminOwner);

    emit ProxyAdminCreated(proxyAdmin, adminOwner);
    return proxyAdmin;
  }

  /// @inheritdoc ITransparentProxyFactoryZkSync
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

  /// @inheritdoc ITransparentProxyFactoryZkSync
  function createDeterministicProxyAdmin(
    address adminOwner,
    bytes32 salt
  ) external returns (address) {
    address proxyAdmin = address(new ProxyAdmin{salt: salt}());
    IOwnable(proxyAdmin).transferOwnership(adminOwner);

    emit ProxyAdminDeterministicCreated(proxyAdmin, adminOwner, salt);
    return proxyAdmin;
  }

  /// @inheritdoc ITransparentProxyFactoryZkSync
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
        TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH,
        abi.encode(logic, admin, data)
      );
  }

  /// @inheritdoc ITransparentProxyFactoryZkSync
  function predictCreateDeterministicProxyAdmin(bytes32 salt) public view returns (address) {
    return _predictCreate2Address(address(this), salt, PROXY_ADMIN_INIT_CODE_HASH, abi.encode());
  }

  function _predictCreate2Address(
    address sender,
    bytes32 salt,
    bytes32 creationCodeHash,
    bytes memory constructorInput
  ) internal pure returns (address) {
    bytes32 addressHash = keccak256(
      bytes.concat(
        ZKSYNC_CREATE2_PREFIX,
        bytes32(uint256(uint160(sender))),
        salt,
        creationCodeHash,
        keccak256(constructorInput)
      )
    );

    return address(uint160(uint256(addressHash)));
  }
}
