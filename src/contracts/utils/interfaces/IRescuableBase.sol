// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/**
 * @title IRescuableBase
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the RescuableBase contract
 */
interface IRescuableBase {
  error EthTransferFailed();
  error OnlyAuthorizedUser(address user);
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
   * @notice method called to rescue tokens sent erroneously to the contract. Only callable by owner
   * @param erc20Token address of the token to rescue
   * @param to address to send the tokens
   * @param amount of tokens to rescue
   */
  function emergencyTokenTransfer(address erc20Token, address to, uint256 amount) external;

  /**
   * @notice method called to rescue ether sent erroneously to the contract. Only callable by owner
   * @param to address to send the eth
   * @param amount of eth to rescue
   */
  function emergencyEtherTransfer(address to, uint256 amount) external;

  /**
   * @notice Checks whether a given address is authorized to perform rescue operations.
   * @param user address to check for rescue authorization
   * @return true if the user is allowed to rescue tokens, false otherwise
   */
  function whoCanResque(address user) external view returns (bool);

  /**
   * @notice method that defined the maximum amount rescuable for any given asset.
   * @dev there's currently no way to limit the rescuable "native asset", as we assume erc20s as intended underlying.
   * @return the maximum amount of
   */
  function maxRescue(address erc20Token) external view returns (uint256);
}
