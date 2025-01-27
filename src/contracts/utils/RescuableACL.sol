// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {RescuableBase} from './RescuableBase.sol';
import {IRescuable} from './interfaces/IRescuable.sol';

/**
 * @title Rescuable specially for ACL models
 * @author BGD Labs
 * @notice abstract contract with the methods to rescue tokens (ERC20 and native) from a contract
 */
abstract contract RescuableACL is RescuableBase, IRescuable {
  /// @notice modifier that checks that caller is allowed address
  modifier onlyRescueGuardian() {
    _checkRescueGuardian();
    _;
  }

  /// @inheritdoc IRescuable
  function emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) external onlyRescueGuardian {
    _emergencyTokenTransfer(erc20Token, to, amount);
  }

  /// @inheritdoc IRescuable
  function emergencyEtherTransfer(address to, uint256 amount) external onlyRescueGuardian {
    _emergencyEtherTransfer(to, amount);
  }

  /// @notice function, that should revert if `msg.sender` isn't allowed to rescue funds
  function _checkRescueGuardian() internal view virtual;
}
