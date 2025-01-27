// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {RescuableBase} from './RescuableBase.sol';
import {IRescuable} from './interfaces/IRescuable.sol';

/**
 * @title Rescuable
 * @author BGD Labs
 * @notice abstract contract with the methods to rescue tokens (ERC20 and native)  from a contract
 */
abstract contract Rescuable is RescuableBase, IRescuable {
  /// @notice modifier that checks that caller is allowed address
  modifier onlyRescueGuardian() {
    if (msg.sender != whoCanRescue()) {
      revert OnlyRescueGuardian();
    }
    _;
  }

  /// @inheritdoc IRescuable
  function emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) external virtual onlyRescueGuardian {
    _emergencyTokenTransfer(erc20Token, to, amount);
  }

  /// @inheritdoc IRescuable
  function emergencyEtherTransfer(address to, uint256 amount) external virtual onlyRescueGuardian {
    _emergencyEtherTransfer(to, amount);
  }

  function whoCanRescue() public view virtual returns (address);
}
