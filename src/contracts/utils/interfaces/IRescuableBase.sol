// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/**
 * @title IRescuableBase
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the RescuableBase contract
 */
interface IRescuableBase {
  /**
   * @notice emitted when erc20 tokens get rescued
   * @param caller address that triggers the rescue
   * @param token address of the rescued token
   * @param to address that will receive the rescued tokens
   * @param amount quantity of tokens rescued
   */
  event ERC20Rescued(
    address indexed caller,
    address indexed token,
    address indexed to,
    uint256 amount
  );

  /**
   * @notice emitted when native tokens get rescued
   * @param caller address that triggers the rescue
   * @param to address that will receive the rescued tokens
   * @param amount quantity of tokens rescued
   */
  event NativeTokensRescued(address indexed caller, address indexed to, uint256 amount);
}
