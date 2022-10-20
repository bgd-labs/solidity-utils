// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Ownable} from '../src/contracts/oz-common/Ownable.sol';
import {EmergencyConsumer} from '../src/contracts/emergency/EmergencyConsumer.sol';
import {IEmergencyConsumer} from '../src/contracts/emergency/interfaces/IEmergencyConsumer.sol';
import {ICLEmergencyOracle} from '../src/contracts/emergency/interfaces/ICLEmergencyOracle.sol';

contract MockConsumer is EmergencyConsumer {
  constructor(address oracle) EmergencyConsumer(oracle) {}
  function testEmergencyMethod() external onlyInEmergency {
    _solveEmergency();
  }
}

contract EmergencyConsumerTest is Test {
  address public constant CL_EMERGENCY_ORACLE = address(1234);

  IEmergencyConsumer public emergencyConsumer;
  MockConsumer public mockConsumer;

  event CLEmergencyOracleUpdated(address indexed newChainlinkEmergencyOracle);
  event EmergencySolved(int256 emergencyCount);

  function setUp() public {
    emergencyConsumer = new EmergencyConsumer(CL_EMERGENCY_ORACLE);
    mockConsumer = new MockConsumer(CL_EMERGENCY_ORACLE);
  }

  function testSetUp() public {
    assertEq(Ownable(address(emergencyConsumer)).owner(), address(this));
  }

  function testGetEmergencyCount() public {
    assertEq(emergencyConsumer.emergencyCount(), int256(0));
  }

  function testGetChainlinkEmergencyOracle() public {
    assertEq(emergencyConsumer.chainlinkEmergencyOracle(), CL_EMERGENCY_ORACLE);
  }

  function testUpdateCLEmergencyOracle() public {
    address newChainlinkEmergencyOracle = address(1234);

    vm.expectEmit(true, false, false, true);
    emit CLEmergencyOracleUpdated( newChainlinkEmergencyOracle);
    emergencyConsumer.updateCLEmergencyOracle(newChainlinkEmergencyOracle);

    assertEq(emergencyConsumer.chainlinkEmergencyOracle(), newChainlinkEmergencyOracle);

  }
  function testUpdateCLEmergencyOracleWhenNotOwner() public {
    address newChainlinkEmergencyOracle = address(1234);

    hoax(address(1258));
    vm.expectRevert(bytes('Ownable: caller is not the owner'));
    emergencyConsumer.updateCLEmergencyOracle(newChainlinkEmergencyOracle);

    assertEq(emergencyConsumer.chainlinkEmergencyOracle(), CL_EMERGENCY_ORACLE);

  }

  function testEmergency() public {
    uint80 roundId = uint80(0);
    int256 answer = int256(1);
    uint256 startedAt = 0;
    uint256 updatedAt = 0;
    uint80 answeredInRound = uint80(0);


    assertEq(mockConsumer.emergencyCount(), int256(0));

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
    emit EmergencySolved(int256(0));
    mockConsumer.testEmergencyMethod();

    assertEq(mockConsumer.emergencyCount(), int256(1));
  }

}
