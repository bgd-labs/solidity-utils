// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {TransparentProxyFactoryBase, ITransparentProxyFactory} from '../../../src/contracts/transparent-proxy/TransparentProxyFactoryBase.sol';
import {ITransparentProxyFactoryZkSync} from './interfaces/ITransparentProxyFactoryZkSync.sol';

/**
 * @title TransparentProxyFactoryZkSync
 * @author BGD Labs
 * @notice Factory contract to create transparent proxies, both with CREATE and CREATE2
 * @dev `create()` and `createDeterministic()` are not unified for clearer interface, and at the same
 * time allowing `createDeterministic()` with salt == 0
 * @dev Highly recommended to pass as `admin` on creation an OZ ProxyAdmin instance
 * @dev This contract needs solc=0.8.19 and zksolc=1.4.1 as codeHashes are specifically made for those versions
 **/
contract TransparentProxyFactoryZkSync is
  TransparentProxyFactoryBase,
  ITransparentProxyFactoryZkSync
{
  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH =
    0x010001b73fa7f2c39ea2d9c597a419e15436fc9d3e00e032410072fb94ad95e1;

  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant PROXY_ADMIN_INIT_CODE_HASH =
    0x010000e7f9a8b61da13fe7e27804d9f641f5f8db05b07df720973af749a01ac1;

  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant ZKSYNC_CREATE2_PREFIX = keccak256('zksyncCreate2');

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
        TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH,
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
