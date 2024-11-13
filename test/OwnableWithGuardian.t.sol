// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {OwnableWithGuardian} from '../src/contracts/access-control/OwnableWithGuardian.sol';

contract ImplOwnableWithGuardian is OwnableWithGuardian {
  function mock_onlyGuardian() external onlyGuardian {}

  function mock_onlyOwnerOrGuardian() external onlyOwnerOrGuardian {}
}

contract TestOfOwnableWithGuardian is Test {
  OwnableWithGuardian public withGuardian;

  address owner = makeAddr('owner');

  function setUp() public {
    withGuardian = new ImplOwnableWithGuardian();
  }

  function testConstructorLogic() external {
    assertEq(withGuardian.owner(), address(this));
    assertEq(withGuardian.guardian(), address(this));
  }

  function testGuardianUpdateViaGuardian(address guardian) external {
    withGuardian.transferOwnership(owner);
    withGuardian.updateGuardian(guardian);
  }

  function testGuardianUpdateViaOwner(address guardian) external {
    withGuardian.transferOwnership(owner);
    vm.prank(owner);
    withGuardian.updateGuardian(guardian);
  }

  function testGuardianUpdateNoAccess(address guardian) external {
    vm.assume(guardian != address(this));

    vm.prank(guardian);
    vm.expectRevert('ONLY_BY_OWNER_OR_GUARDIAN');
    withGuardian.updateGuardian(guardian);
  }
}
