// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from '../oz-common/interfaces/IERC20.sol';
import {SafeERC20} from '../oz-common/SafeERC20.sol';
import {IRescuableBase} from './interfaces/IRescuableBase.sol';

abstract contract RescuableBase is IRescuableBase {
  using SafeERC20 for IERC20;

  function _emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) internal virtual {
    IERC20(erc20Token).safeTransfer(to, amount);

    emit ERC20Rescued(msg.sender, erc20Token, to, amount);
  }

  function _emergencyEtherTransfer(address to, uint256 amount) internal virtual {
    (bool success, ) = to.call{value: amount}(new bytes(0));
    require(success, 'ETH_TRANSFER_FAIL');

    emit NativeTokensRescued(msg.sender, to, amount);
  }
}
