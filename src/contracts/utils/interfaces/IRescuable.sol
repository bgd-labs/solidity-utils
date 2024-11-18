// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IRescuableBase} from './IRescuableBase.sol';

/**
 * @title IRescuable
 * @author BGD Labs
 * @notice interface containing the objects, events and methods definitions of the Rescuable contract
 */
interface IRescuable is IRescuableBase {
  error OnlyRescueGuardian();

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
}
