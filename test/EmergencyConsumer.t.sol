// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {EmergencyConsumer} from '../src/contracts/emergency/EmergencyConsumer.sol';
import {IEmergencyConsumer} from '../src/contracts/emergency/interfaces/IEmergencyConsumer.sol';
import {ICLEmergencyOracle} from '../src/contracts/emergency/interfaces/ICLEmergencyOracle.sol';

contract EmergencyConsumerTest is Test, EmergencyConsumer {
  address public constant CL_EMERGENCY_ORACLE = address(1234);

  constructor() EmergencyConsumer(CL_EMERGENCY_ORACLE) {}

  function setUp() public {}

  function _validateEmergencyAdmin() internal override {}

  function emergencyMethod() public onlyInEmergency {}

  function testGetEmergencyCount() public {
    assertEq(getEmergencyCount(), 0);
  }

  function testGetChainlinkEmergencyOracle() public {
    assertEq(getChainlinkEmergencyOracle(), CL_EMERGENCY_ORACLE);
  }

  function testUpdateCLEmergencyOracleInternal() public {
    address newChainlinkEmergencyOracle = address(1234);

    vm.expectEmit(true, false, false, true);
    emit CLEmergencyOracleUpdated(newChainlinkEmergencyOracle);
    _updateCLEmergencyOracle(newChainlinkEmergencyOracle);

    assertEq(_chainlinkEmergencyOracle, newChainlinkEmergencyOracle);
  }

  function testEmergency() public {
    uint80 roundId = uint80(0);
    int256 answer = int256(1);
    uint256 startedAt = 0;
    uint256 updatedAt = 0;
    uint80 answeredInRound = uint80(0);

    assertEq(_emergencyCount, 0);

    vm.mockCall(
      address(CL_EMERGENCY_ORACLE),
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector),
      abi.encode(roundId, answer, startedAt, updatedAt, answeredInRound)
    );
    vm.expectCall(
      address(CL_EMERGENCY_ORACLE),
      abi.encodeWithSelector(ICLEmergencyOracle.latestRoundData.selector)
    );
    vm.expectEmit(false, false, false, true);
    emit EmergencySolved(1);
    emergencyMethod();

    assertEq(_emergencyCount, 1);
  }
}
