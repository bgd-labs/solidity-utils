// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {RescuableBase} from './RescuableBase.sol';
import {IPermissionlessRescuable} from './interfaces/IPermissionlessRescuable.sol';

abstract contract PermissionlessRescuable is RescuableBase, IPermissionlessRescuable {
  /// @inheritdoc IPermissionlessRescuable
  function whoShouldReceiveFunds() public view virtual returns (address);

  /// @inheritdoc IPermissionlessRescuable
  function emergencyTokenTransfer(address erc20Token, uint256 amount) external virtual {
    _emergencyTokenTransfer(erc20Token, whoShouldReceiveFunds(), amount);
  }

  /// @inheritdoc IPermissionlessRescuable
  function emergencyEtherTransfer(uint256 amount) external virtual {
    _emergencyEtherTransfer(whoShouldReceiveFunds(), amount);
  }
}
