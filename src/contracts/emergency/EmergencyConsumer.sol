// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IEmergencyConsumer} from './interfaces/IEmergencyConsumer.sol';
import {ICLEmergencyOracle} from './interfaces/ICLEmergencyOracle.sol';

abstract contract EmergencyConsumer is IEmergencyConsumer {
  address internal _chainlinkEmergencyOracle;

  uint256 internal _emergencyCount;

  /// @dev modifier that checks if the oracle emergency is greater than the last resolved one, and if so
  ///      lets execution pass
  modifier onlyInEmergency() {
    require(address(_chainlinkEmergencyOracle) != address(0), 'CL_EMERGENCY_ORACLE_NOT_SET');

    (, int256 answer, , , ) = ICLEmergencyOracle(_chainlinkEmergencyOracle).latestRoundData();

    uint256 nextEmergencyCount = ++_emergencyCount;
    require(answer == int256(nextEmergencyCount), 'NOT_IN_EMERGENCY');
    _;

    emit EmergencySolved(nextEmergencyCount);
  }

  /**
   * @param chainlinkEmergencyOracle address of the new chainlink emergency mode oracle
   */
  constructor(address chainlinkEmergencyOracle) {
    _updateCLEmergencyOracle(chainlinkEmergencyOracle);
  }

  /// @dev This method is made virtual as it is expected to have access control, but this way it is delegated to implementation.
  function _validateEmergencyAdmin() internal virtual;

  /// @inheritdoc IEmergencyConsumer
  function updateCLEmergencyOracle(address chainlinkEmergencyOracle) external {
    _validateEmergencyAdmin();
    _updateCLEmergencyOracle(chainlinkEmergencyOracle);
  }

  /// @inheritdoc IEmergencyConsumer
  function getChainlinkEmergencyOracle() public view returns (address) {
    return _chainlinkEmergencyOracle;
  }

  /// @inheritdoc IEmergencyConsumer
  function getEmergencyCount() public view returns (uint256) {
    return _emergencyCount;
  }

  /**
   * @dev method to update the chainlink emergency oracle
   * @param chainlinkEmergencyOracle address of the new oracle
   */
  function _updateCLEmergencyOracle(address chainlinkEmergencyOracle) internal {
    _chainlinkEmergencyOracle = chainlinkEmergencyOracle;

    emit CLEmergencyOracleUpdated(chainlinkEmergencyOracle);
  }
}
