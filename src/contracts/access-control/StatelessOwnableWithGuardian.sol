// SPDX-License-Identifier: MIT
// @dev modified version without storage that is intended to be anchored to a ACL
pragma solidity >=0.7.0;

import {IStatelessOwnableWithGuardian} from './interfaces/IStatelessOwnableWithGuardian.sol';
import {StatelessOwnable} from './StatelessOwnable.sol';

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (a guardian) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyGuardian` and `onlyOwnerOrGuardian, which can be applied to your functions to restrict their use to
 * the guardian or owner & guardian respectively.
 */
abstract contract StatelessOwnableWithGuardian is StatelessOwnable, IStatelessOwnableWithGuardian {
  modifier onlyGuardian() {
    _checkGuardian();
    _;
  }

  modifier onlyOwnerOrGuardian() {
    _checkOwnerOrGuardian();
    _;
  }

  /// @inheritdoc IStatelessOwnableWithGuardian
  function guardian() public view virtual returns (address);

  function _checkGuardian() internal view {
    if (guardian() != _msgSender()) revert OnlyGuardianInvalidCaller(_msgSender());
  }

  function _checkOwnerOrGuardian() internal view {
    if (_msgSender() != owner() && _msgSender() != guardian())
      revert OnlyGuardianOrOwnerInvalidCaller(_msgSender());
  }
}
