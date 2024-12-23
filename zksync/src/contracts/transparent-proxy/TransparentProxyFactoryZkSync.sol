// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import {TransparentProxyFactoryBase} from '../../../../src/contracts/transparent-proxy/TransparentProxyFactoryBase.sol';
import {Create2UtilsZkSync} from '../utils/ScriptUtilsZkSync.sol';

/**
 * @title TransparentProxyFactoryZkSync
 * @author BGD Labs
 * @notice Factory contract specific to zkSync to create transparent proxies, both with CREATE and CREATE2
 * @dev `create()` and `createDeterministic()` are not unified for clearer interface, and at the same
 * time allowing `createDeterministic()` with salt == 0
 * @dev Highly recommended to pass as `admin` on creation an OZ ProxyAdmin instance
 **/
contract TransparentProxyFactoryZkSync is TransparentProxyFactoryBase {
  function _predictCreate2Address(
    address sender,
    bytes32 salt,
    bytes memory creationCode,
    bytes memory constructorInput
  ) internal pure override returns (address) {
    bytes32 addressHash = keccak256(
      bytes.concat(
        Create2UtilsZkSync.ZKSYNC_CREATE2_PREFIX,
        bytes32(uint256(uint160(sender))),
        salt,
        Create2UtilsZkSync.getBytecodeHashFromBytecode(creationCode),
        keccak256(constructorInput)
      )
    );

    return address(uint160(uint256(addressHash)));
  }
}
