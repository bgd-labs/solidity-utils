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
  function createDeterministicWithProxyAdmin(
    address logic,
    address proxyOwner,
    bytes calldata data,
    bytes32 salt,
    bytes32 adminSalt
  ) external returns (address, address) {
    address proxyAdmin = address(new ProxyAdmin{salt: adminSalt}());
    IOwnable(proxyAdmin).transferOwnership(proxyOwner);

    address proxy = address(new TransparentUpgradeableProxy{salt: salt}(logic, proxyAdmin, data));

    emit ProxyDeterministicCreatedWithOwner(proxy, logic, proxyAdmin, proxyOwner, salt);
    return (proxy, proxyAdmin);
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
  function predictCreateDeterministicWithDeterministicProxyAdmin(
    address logic,
    bytes calldata data,
    bytes32 adminSalt,
    bytes32 salt
  ) public view returns (address, address) {
    address proxyAdmin = _predictCreate2Address(
      address(this),
      adminSalt,
      type(ProxyAdmin).creationCode,
      abi.encode()
    );

    address proxy = _predictCreate2Address(
      address(this),
      salt,
      type(TransparentUpgradeableProxy).creationCode,
      abi.encode(logic, proxyAdmin, data)
    );

    return (proxy, proxyAdmin);
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

  function _predictCreate2Address(
    address creator,
    bytes32 salt,
    bytes memory creationCode,
    bytes memory contructorArgs
  ) internal pure returns (address) {
    bytes32 hash = keccak256(
      abi.encodePacked(
        bytes1(0xff),
        creator,
        salt,
        keccak256(abi.encodePacked(creationCode, contructorArgs))
      )
    );

    return address(uint160(uint256(hash)));
  }
}
