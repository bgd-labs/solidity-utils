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
contract TransparentProxyFactory is ITransparentProxyFactory {
  /// @inheritdoc ITransparentProxyFactory
  bytes32 public constant TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH = 0x010001a582e065e38c95d4ec6c9229a4d3f4dbc80f9a0e5a4f5e441916a8711a;

  /// @inheritdoc ITransparentProxyFactory
  bytes32 public constant PROXY_ADMIN_INIT_CODE_HASH = 0x010000e1d9100f670e623a066ebe76f10276fc5cd0119e0cc60191d920633af8;

  /// @inheritdoc ITransparentProxyFactory
  bytes32 public constant ZKSYNC_CREATE2_PREFIX = keccak256("zksyncCreate2");

  /// @inheritdoc ITransparentProxyFactory
  function create(address logic, address admin, bytes calldata data) external returns (address) {
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
  function createDeterministicProxyAdmin(
    address adminOwner,
    bytes32 salt
  ) external returns (address) {
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
  ) public view returns (address) {
    return
      _predictCreate2Address(
        address(this),
        salt,
        TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH,
        abi.encode(logic, admin, data)
      );
  }

  /// @inheritdoc ITransparentProxyFactory
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
