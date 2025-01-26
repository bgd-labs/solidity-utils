// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {TransparentProxyFactoryBase} from '../../../../src/contracts/transparent-proxy/TransparentProxyFactoryBase.sol';
import {ITransparentProxyFactoryZkSync} from './interfaces/ITransparentProxyFactoryZkSync.sol';

/**
 * @title TransparentProxyFactoryZkSync
 * @author BGD Labs
 * @notice Factory contract specific to zkSync to create transparent proxies, both with CREATE and CREATE2
 * @dev `create()` and `createDeterministic()` are not unified for clearer interface, and at the same
 * time allowing `createDeterministic()` with salt == 0
 **/
contract TransparentProxyFactoryZkSync is
  TransparentProxyFactoryBase,
  ITransparentProxyFactoryZkSync
{
  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant ZKSYNC_CREATE2_PREFIX = keccak256('zksyncCreate2');
  bytes32 public constant ZKSYNC_CREATE_PREFIX = keccak256('zksyncCreate');

  function _predictCreate2Address(
    address sender,
    bytes32 salt,
    bytes memory creationCode,
    bytes memory constructorInput
  ) internal pure override returns (address) {
    bytes32 addressHash = keccak256(
      bytes.concat(
        ZKSYNC_CREATE2_PREFIX,
        bytes32(uint256(uint160(sender))),
        salt,
        bytes32(_sliceBytes(creationCode, 36, 32)),
        keccak256(constructorInput)
      )
    );

    return address(uint160(uint256(addressHash)));
  }

  function _sliceBytes(
    bytes memory data,
    uint256 start,
    uint256 length
  ) internal pure returns (bytes memory) {
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

  // on zksync nonces start with 0 https://docs.zksync.io/zksync-protocol/differences/nonces
  function _predictProxyAdminAddress(address proxy) internal pure override returns (address) {
    bytes32 addressHash = keccak256(
      bytes.concat(ZKSYNC_CREATE_PREFIX, bytes32(uint256(uint160(proxy))), bytes32(uint256(0)))
    );

    return address(uint160(uint256(addressHash)));
  }
}
