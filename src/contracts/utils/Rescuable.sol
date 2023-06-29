// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IERC20} from '../oz-common/interfaces/IERC20.sol';
import {SafeERC20} from '../oz-common/SafeERC20.sol';

abstract contract Rescuable {
  using SafeERC20 for IERC20;

  event ERC20Rescued(
    address indexed caller,
    address indexed token,
    address indexed to,
    uint256 amount
  );

  event NativeTokensRescued(address indexed caller, address indexed to, uint256 amount);

  modifier onlyRescueGuardian() {
    require(msg.sender == whoCanRescue(), 'ONLY_RESCUE_GUARDIAN');
    _;
  }

  function emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) external onlyRescueGuardian {
    IERC20(erc20Token).safeTransfer(to, amount);

    emit ERC20Rescued(msg.sender, erc20Token, to, amount);
  }

  function emergencyEtherTransfer(address to, uint256 amount) external onlyRescueGuardian {
    (bool success, ) = to.call{value: amount}(new bytes(0));
    require(success, 'ETH_TRANSFER_FAIL');

    emit NativeTokensRescued(msg.sender, to, amount);
  }

  function whoCanRescue() public view virtual returns (address);
}
