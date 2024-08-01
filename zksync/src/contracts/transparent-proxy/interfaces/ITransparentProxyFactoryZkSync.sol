// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ITransparentProxyFactoryZkSync {
  /**
   * @notice method to get the zksync create2 prefix used for create2 address derivation in zksync
   * @return create2 prefix used for create2 address derivation
   */
  function ZKSYNC_CREATE2_PREFIX() external returns (bytes32);
}
