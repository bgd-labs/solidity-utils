// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {IRescuableBase} from './interfaces/IRescuableBase.sol';

/**
 * @title RescuableBase
 * @author BGD Labs
 * @notice Abstract contract providing emergency rescue functionality for ERC20 tokens and native ETH
 * accidentally sent to a contract. Implements access control via `whoCanResque` and
 * rescue amount limits via `maxRescue`, both of which must be defined by inheriting contracts.
 */
abstract contract RescuableBase is IRescuableBase {
  using SafeERC20 for IERC20;

  /// @notice modifier that checks that caller is allowed address
  modifier onlyWhoCanResque() {
    require(whoCanResque(msg.sender), OnlyAuthorizedUser(msg.sender));
    _;
  }

  /// @inheritdoc IRescuableBase
  function maxRescue(address erc20Token) public view virtual returns (uint256);

  /// @inheritdoc IRescuableBase
  function whoCanResque(address user) public view virtual returns (bool);

  /// @inheritdoc IRescuableBase
  function emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) external onlyWhoCanResque {
    _emergencyTokenTransfer(erc20Token, to, amount);
  }

  /// @inheritdoc IRescuableBase
  function emergencyEtherTransfer(address to, uint256 amount) external onlyWhoCanResque {
    _emergencyEtherTransfer(to, amount);
  }

  function _emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) internal virtual {
    uint256 max = maxRescue(erc20Token);
    amount = max > amount ? amount : max;
    IERC20(erc20Token).safeTransfer(to, amount);

    emit ERC20Rescued(msg.sender, erc20Token, to, amount);
  }

  function _emergencyEtherTransfer(address to, uint256 amount) internal virtual {
    (bool success, ) = to.call{value: amount}(new bytes(0));
    if (!success) {
      revert EthTransferFailed();
    }

    emit NativeTokensRescued(msg.sender, to, amount);
  }
}
