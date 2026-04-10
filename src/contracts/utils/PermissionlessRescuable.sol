// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {RescuableBase} from './RescuableBase.sol';
import {IPermissionlessRescuable} from './interfaces/IPermissionlessRescuable.sol';

abstract contract PermissionlessRescuable is RescuableBase, IPermissionlessRescuable {
  /// @notice modifier that checks that recipient is allowed address
  modifier onlyWhoShouldReceiveFunds(address user) {
    require(user == whoShouldReceiveFunds(), OnlyAuthorizedReceiver(user));
    _;
  }

  /// @inheritdoc IPermissionlessRescuable
  function whoShouldReceiveFunds() public view virtual returns (address);

  function whoCanResque(address user) public view override returns (bool) {
    return true;
  }

  /// @inheritdoc IPermissionlessRescuable
  function emergencyTokenTransfer(address erc20Token, uint256 amount) external virtual {
    _emergencyTokenTransfer(erc20Token, whoShouldReceiveFunds(), amount);
  }

  /// @inheritdoc IPermissionlessRescuable
  function emergencyEtherTransfer(uint256 amount) external virtual {
    _emergencyEtherTransfer(whoShouldReceiveFunds(), amount);
  }

  function _emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) internal override onlyWhoShouldReceiveFunds(to) {
    super._emergencyTokenTransfer(erc20Token, to, amount);
  }

  function _emergencyEtherTransfer(
    address to,
    uint256 amount
  ) internal override onlyWhoShouldReceiveFunds(to) {
    super._emergencyEtherTransfer(to, amount);
  }
}
