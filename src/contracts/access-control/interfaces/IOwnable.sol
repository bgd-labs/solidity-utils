// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface IOwnable {
  /**
   * @dev The caller account is not authorized to perform an operation.
   */
  error OwnableUnauthorizedAccount(address account);

  /**
   * @dev get guardian address;
   */
  function owner() external view returns (address);
}
