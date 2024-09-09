// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IRescuableBase} from './IRescuableBase.sol';

/**
 * @title IRescuable
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the Rescuable contract
 */
interface IPermissionlessRescuable is IRescuableBase {
  /**
   * @notice method called to rescue tokens sent erroneously to the contract. Only callable by owner
   * @param erc20Token address of the token to rescue
   * @param amount of tokens to rescue
   */
  function emergencyTokenTransfer(address erc20Token, uint256 amount) external;

  /**
   * @notice method called to rescue ether sent erroneously to the contract. Only callable by owner
   * @param amount of eth to rescue
   */
  function emergencyEtherTransfer(uint256 amount) external;

  /**
   * @notice method that defines the address that should receive the rescued tokens
   * @return the receiver address
   */
  function whoShouldReceiveFunds() external view returns (address);
}
