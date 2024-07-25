// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ITransparentProxyFactoryZkSync {
  /**
   * @notice method to get the hash of creation bytecode of the TransparentUpgradableProxy contract
   * @return hashed of creation bytecode of the TransparentUpgradableProxy contract
   */
  function TRANSPARENT_UPGRADABLE_PROXY_INIT_CODE_HASH() external returns (bytes32);

  /**
   * @notice method to get the hash of creation bytecode of the ProxyAdmin contract
   * @return hashed of creation bytecode of the ProxyAdmin contract
   */
  function PROXY_ADMIN_INIT_CODE_HASH() external returns (bytes32);

  /**
   * @notice method to get the zksync create2 prefix used for create2 address derivation in zksync
   * @return create2 prefix used for create2 address derivation
   */
  function ZKSYNC_CREATE2_PREFIX() external returns (bytes32);
}
