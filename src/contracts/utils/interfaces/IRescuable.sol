// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IRescuable {
  event ERC20Rescued(
    address indexed caller,
    address indexed token,
    address indexed to,
    uint256 amount
  );

  event NativeTokensRescued(address indexed caller, address indexed to, uint256 amount);

  function emergencyTokenTransfer(address erc20Token, address to, uint256 amount) external;

  function emergencyEtherTransfer(address to, uint256 amount) external;

  function whoCanRescue() external view returns (address);
}
