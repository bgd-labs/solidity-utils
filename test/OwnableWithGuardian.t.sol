// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {OwnableWithGuardian} from '../src/contracts/access-control/OwnableWithGuardian.sol';

contract ImplOwnableWithGuardian is OwnableWithGuardian {}

contract TestOfOwnableWithGuardian is Test {
  OwnableWithGuardian public withGuardian;

  function setUp() public {
    withGuardian = new ImplOwnableWithGuardian();
  }

  function testConstructorLogic() external {
    assertEq(withGuardian.owner(), address(this));
    assertEq(withGuardian.guardian(), address(this));
  }

  function testGuardianUpdate() external {
    withGuardian.updateGuardian(0x0000000000000000000000000000000000000001);
  }

  function testGuardianUpdateNoAccess() external {
    vm.prank(0x0000000000000000000000000000000000000001);
    vm.expectRevert('ONLY_BY_GUARDIAN');
    withGuardian.updateGuardian(0x0000000000000000000000000000000000000001);
  }
}
