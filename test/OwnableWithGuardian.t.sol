// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {OwnableWithGuardian} from '../src/contracts/access-control/OwnableWithGuardian.sol';

contract ImplOwnableWithGuardian is OwnableWithGuardian {
  function mock_onlyGuardian() external onlyGuardian {}

  function mock_onlyOwnerOrGuardian() external onlyOwnerOrGuardian {}
}

contract TestOfOwnableWithGuardian is Test {
  ImplOwnableWithGuardian public withGuardian;

  address owner = makeAddr('owner');
  address guardian = makeAddr('guardian');

  function setUp() public {
    withGuardian = new ImplOwnableWithGuardian();
    assertEq(withGuardian.owner(), address(this));
    assertEq(withGuardian.guardian(), address(this));
    withGuardian.transferOwnership(owner);
    withGuardian.updateGuardian(guardian);
  }

  function testConstructorLogic() external view {
    assertEq(withGuardian.owner(), owner);
    assertEq(withGuardian.guardian(), guardian);
  }

  function testGuardianUpdateViaGuardian(address newGuardian) external {
    vm.startPrank(guardian);
    withGuardian.updateGuardian(newGuardian);
  }

  function testGuardianUpdateViaOwner(address newGuardian) external {
    vm.prank(owner);
    withGuardian.updateGuardian(newGuardian);
  }

  function testGuardianUpdateNoAccess() external {
    vm.expectRevert('ONLY_BY_OWNER_OR_GUARDIAN');
    withGuardian.updateGuardian(guardian);
  }

  function test_onlyGuardianGuard() external {
    vm.prank(guardian);
    withGuardian.mock_onlyGuardian();
  }

  function test_onlyGuardianGuard_shouldRevert() external {
    vm.expectRevert('ONLY_BY_GUARDIAN');
    withGuardian.mock_onlyGuardian();
  }
}
