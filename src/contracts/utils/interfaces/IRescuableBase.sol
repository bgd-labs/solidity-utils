// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/**
 * @title IRescuableBase
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the RescuableBase contract
 */
interface IRescuableBase {
  error EthTransferFailed();
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

  /**
   * @notice method that defined the maximum amount rescuable for any given asset.
   * @dev there's currently no way to limit the rescuable "native asset", as we assume erc20s as intended underlying.
   * @return the maximum amount of
   */
  function maxRescue(address erc20Token) external view returns (uint256);
}
