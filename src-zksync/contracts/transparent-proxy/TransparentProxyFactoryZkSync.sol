// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {TransparentProxyFactoryBase, ITransparentProxyFactory} from '../../../src/contracts/transparent-proxy/TransparentProxyFactoryBase.sol';
import {TransparentUpgradeableProxy} from '../../../src/contracts/transparent-proxy/TransparentUpgradeableProxy.sol';
import {ProxyAdmin} from '../../../src/contracts/transparent-proxy/ProxyAdmin.sol';
import {ITransparentProxyFactoryZkSync} from './interfaces/ITransparentProxyFactoryZkSync.sol';

/**
 * @title TransparentProxyFactoryZkSync
 * @author BGD Labs
 * @notice Factory contract specific to zkSync to create transparent proxies, both with CREATE and CREATE2
 * @dev `create()` and `createDeterministic()` are not unified for clearer interface, and at the same
 * time allowing `createDeterministic()` with salt == 0
 * @dev Highly recommended to pass as `admin` on creation an OZ ProxyAdmin instance
 **/
contract TransparentProxyFactoryZkSync is
  TransparentProxyFactoryBase,
  ITransparentProxyFactoryZkSync
{
  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public immutable TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH;

  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public immutable PROXY_ADMIN_INIT_CODE_HASH;

  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant ZKSYNC_CREATE2_PREFIX = keccak256('zksyncCreate2');

  constructor() {
    // to get the bytecode-hash in zkSync, we sanatize the bytes returned from the creationCode
    TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH = bytes32(_sliceBytes(type(TransparentUpgradeableProxy).creationCode, 36, 32));
    PROXY_ADMIN_INIT_CODE_HASH = bytes32(_sliceBytes(type(ProxyAdmin).creationCode, 36, 32));
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

  function _sliceBytes(bytes memory data, uint256 start, uint256 length) internal pure returns (bytes memory) {
    require(start + length <= data.length, 'Slice out of bounds');

    bytes memory result = new bytes(length);
    assembly {
      let dataPtr := add(data, 32)
      let resultPtr := add(result, 32)

      // Use mcopy to efficiently copy the slice
      mcopy(resultPtr, add(dataPtr, start), length)

      mstore(result, length)
    }
    return result;
  }
}
