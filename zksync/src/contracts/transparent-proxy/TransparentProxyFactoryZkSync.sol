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
 * @dev Highly recommended to pass as `admin` on creation an OZ ProxyAdmin instance
 **/
contract TransparentProxyFactoryZkSync is
  TransparentProxyFactoryBase,
  ITransparentProxyFactoryZkSync
{
  /// @inheritdoc ITransparentProxyFactoryZkSync
  bytes32 public constant ZKSYNC_CREATE2_PREFIX = keccak256('zksyncCreate2');

  function _predictCreate2Address(
    address sender,
    bytes32 salt,
    bytes memory bytecodeHash,
    bytes memory constructorInput
  ) internal pure override returns (address) {
    bytes32 addressHash = keccak256(
      bytes.concat(
        ZKSYNC_CREATE2_PREFIX,
        bytes32(uint256(uint160(sender))),
        salt,
        abi.decode(bytecodeHash, (bytes32)),
        keccak256(constructorInput)
      )
    );

    return address(uint160(uint256(addressHash)));
  }
}
