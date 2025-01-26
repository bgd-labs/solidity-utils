// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {TransparentProxyFactoryBase} from './TransparentProxyFactoryBase.sol';

/**
 * @title TransparentProxyFactory
 * @author BGD Labs
 * @notice Factory contract to create transparent proxies, both with CREATE and CREATE2
 * @dev `create()` and `createDeterministic()` are not unified for clearer interface, and at the same
 * time allowing `createDeterministic()` with salt == 0
 **/
contract TransparentProxyFactory is TransparentProxyFactoryBase {
  function _predictCreate2Address(
    address creator,
    bytes32 salt,
    bytes memory creationCode,
    bytes memory constructorArgs
  ) internal pure override returns (address) {
    bytes32 hash = keccak256(
      abi.encodePacked(
        bytes1(0xff),
        creator,
        salt,
        keccak256(abi.encodePacked(creationCode, constructorArgs))
      )
    );

    return address(uint160(uint256(hash)));
  }
}
