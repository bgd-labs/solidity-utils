// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Ownable} from '../src/contracts/oz-common/Ownable.sol';
import {EmergencyConsumer} from '../src/contracts/emergency/EmergencyConsumer.sol';
import {IEmergencyConsumer} from '../src/contracts/emergency/interfaces/IEmergencyConsumer.sol';
import {ICLEmergencyOracle} from '../src/contracts/emergency/interfaces/ICLEmergencyOracle.sol';

contract MockConsumer is EmergencyConsumer, Ownable {
  constructor(address oracle, address owner) EmergencyConsumer(oracle) {
    _transferOwnership(owner);
  }

  function testEmergencyMethod() external onlyInEmergency {

  }

  function updateCLEmergencyOracle(address newChainlinkEmergencyOracle) onlyOwner external override {
    _updateCLEmergencyOracle(newChainlinkEmergencyOracle);
  }
}

contract EmergencyConsumerTest is Test, EmergencyConsumer {
  address public constant OWNER = address(123);
  address public constant CL_EMERGENCY_ORACLE = address(1234);

  IEmergencyConsumer public emergencyConsumer;
  MockConsumer public mockConsumer;

//  event CLEmergencyOracleUpdated(address indexed newChainlinkEmergencyOracle);
//  event EmergencySolved(int256 emergencyCount);

  constructor() EmergencyConsumer(CL_EMERGENCY_ORACLE) {}

  function setUp() public {
//    emergencyConsumer = new EmergencyConsumer(CL_EMERGENCY_ORACLE);
    mockConsumer = new MockConsumer(CL_EMERGENCY_ORACLE, OWNER);
  }

  function updateCLEmergencyOracle(address newChainlinkEmergencyOracle) external override {}

  function testGetEmergencyCount() public {
    assertEq(emergencyCount, int256(0));
  }

  function testGetChainlinkEmergencyOracle() public {
    assertEq(chainlinkEmergencyOracle, CL_EMERGENCY_ORACLE);
  }

  function testUpdateCLEmergencyOracleInernal() public {
    address newChainlinkEmergencyOracle = address(1234);

    vm.expectEmit(true, false, false, true);
    emit CLEmergencyOracleUpdated( newChainlinkEmergencyOracle);
    _updateCLEmergencyOracle(newChainlinkEmergencyOracle);

    assertEq(chainlinkEmergencyOracle, newChainlinkEmergencyOracle);
  }

  function testUpdateCLEmergencyOracle() public {
    address newChainlinkEmergencyOracle = address(1234);

    hoax(OWNER);
    vm.expectEmit(true, false, false, true);
    emit CLEmergencyOracleUpdated( newChainlinkEmergencyOracle);
    mockConsumer.updateCLEmergencyOracle(newChainlinkEmergencyOracle);

    assertEq(mockConsumer.chainlinkEmergencyOracle(), newChainlinkEmergencyOracle);
  }

  function testUpdateCLEmergencyOracleWhenNotOwner() public {
    address newChainlinkEmergencyOracle = address(1234);

    vm.expectRevert(bytes('Ownable: caller is not the owner'));
    mockConsumer.updateCLEmergencyOracle(newChainlinkEmergencyOracle);

    assertEq(mockConsumer.chainlinkEmergencyOracle(), CL_EMERGENCY_ORACLE);

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
