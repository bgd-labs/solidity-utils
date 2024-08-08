// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface IStatelessOwnableWithGuardian {
  /**
   * @dev The caller account is not authorized to perform an operation.
   */
  error OnlyGuardianInvalidCaller(address account);

  /**
   * @dev The caller account is not authorized to perform an operation.
   */
  error OnlyGuardianOrOwnerInvalidCaller(address account);

  /**
   * @dev get guardian address;
   */
  function guardian() external view returns (address);
}
