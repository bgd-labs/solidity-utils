// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from '../oz-common/Ownable.sol';
import {IEmergencyConsumer} from './interfaces/IEmergencyConsumer.sol';
import {ICLEmergencyOracle} from './interfaces/ICLEmergencyOracle.sol';

contract EmergencyConsumer is Ownable, IEmergencyConsumer {
  /// @inheritdoc IEmergencyConsumer
  address public chainlinkEmergencyOracle;

  /// @inheritdoc IEmergencyConsumer
  int256 public emergencyCount;

  /// @dev modifier that checks if the oracle emergency is greater than the last resolved one, and if so
  ///      lets execution pass
  modifier onlyInEmergency {
    require(address(chainlinkEmergencyOracle) != address(0), 'CL_EMERGENCY_ORACLE_NOT_SET');

    (,int256 answer,,,) = ICLEmergencyOracle(chainlinkEmergencyOracle).latestRoundData();

    require(answer > emergencyCount == true, 'NOT_IN_EMERGENCY');
    _;
  }

  /**
  * @param newChainlinkEmergencyOracle address of the new chainlink emergency mode oracle
  */
  constructor(address newChainlinkEmergencyOracle) {
    _updateCLEmergencyOracle(newChainlinkEmergencyOracle);
  }

  /// @inheritdoc IEmergencyConsumer
  function updateCLEmergencyOracle(address newChainlinkEmergencyOracle)
  external onlyOwner
  {
    _updateCLEmergencyOracle(newChainlinkEmergencyOracle);
  }


  /**
  * @dev method that marks the emergency as resolved
  */
  function _solveEmergency() internal onlyInEmergency {
    emergencyCount++;
  }

  /**
   * @dev method to update the chainlink emergency oracle
   * @param newChainlinkEmergencyOracle address of the new oracle
   */
  function _updateCLEmergencyOracle(address newChainlinkEmergencyOracle)
  internal
  {
    chainlinkEmergencyOracle = newChainlinkEmergencyOracle;

    emit CLEmergencyOracleUpdated(newChainlinkEmergencyOracle);
  }
}
