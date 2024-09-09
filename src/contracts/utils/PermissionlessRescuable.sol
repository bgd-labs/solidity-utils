// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from '../oz-common/interfaces/IERC20.sol';
import {RescuableBase} from './RescuableBase.sol';
import {IPermissionlessRescuable} from './interfaces/IPermissionlessRescuable.sol';

abstract contract PermissionlessRescuable is RescuableBase, IPermissionlessRescuable {
  /// @inheritdoc IPermissionlessRescuable
  function whoShouldReceiveFunds() public view virtual returns (address);

  /// @inheritdoc IPermissionlessRescuable
  function emergencyTokenTransfer(address erc20Token, uint256 amount) external virtual {
    uint256 max = maxRescue(erc20Token);
    _emergencyTokenTransfer(erc20Token, whoShouldReceiveFunds(), max > amount ? amount : max);
  }

  /// @inheritdoc IPermissionlessRescuable
  function emergencyEtherTransfer(uint256 amount) external virtual {
    _emergencyEtherTransfer(whoShouldReceiveFunds(), amount);
  }

  /// @inheritdoc IPermissionlessRescuable
  function maxRescue(address erc20Token) public view virtual returns (uint256);
}
