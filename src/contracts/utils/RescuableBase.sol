// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';
import {IRescuableBase} from './interfaces/IRescuableBase.sol';

abstract contract RescuableBase is IRescuableBase {
  using SafeERC20 for IERC20;

  /// @inheritdoc IRescuableBase
  function maxRescue(address erc20Token) public view virtual returns (uint256);

  function _emergencyTokenTransfer(address erc20Token, address to, uint256 amount) internal {
    uint256 max = maxRescue(erc20Token);
    amount = max > amount ? amount : max;
    IERC20(erc20Token).safeTransfer(to, amount);

    emit ERC20Rescued(msg.sender, erc20Token, to, amount);
  }

  function _emergencyEtherTransfer(address to, uint256 amount) internal {
    (bool success, ) = to.call{value: amount}(new bytes(0));
    if (!success) {
      revert EthTransferFailed();
    }

    emit NativeTokensRescued(msg.sender, to, amount);
  }
}
