// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {OwnableWithGuardian, IWithGuardian} from '../src/contracts/access-control/OwnableWithGuardian.sol';

contract ImplOwnableWithGuardian is OwnableWithGuardian {
  constructor(address initialOwner, address guardian) OwnableWithGuardian(initialOwner, guardian) {}

  function mock_onlyGuardian() external onlyGuardian {}

  function mock_onlyOwnerOrGuardian() external onlyOwnerOrGuardian {}
}

contract TestOfOwnableWithGuardian is Test {
  ImplOwnableWithGuardian public withGuardian;

  address owner = makeAddr('owner');
  address guardian = makeAddr('guardian');

  function setUp() public {
    withGuardian = new ImplOwnableWithGuardian(address(this), address(this));
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
    vm.expectRevert(
      abi.encodeWithSelector(IWithGuardian.OnlyGuardianOrOwnerInvalidCaller.selector, address(this))
    );
    withGuardian.updateGuardian(guardian);
  }

  function test_onlyGuardianGuard() external {
    vm.prank(guardian);
    withGuardian.mock_onlyGuardian();
  }

  function test_onlyGuardianGuard_shouldRevert() external {
    vm.expectRevert(
      abi.encodeWithSelector(IWithGuardian.OnlyGuardianInvalidCaller.selector, address(this))
    );
    withGuardian.mock_onlyGuardian();
  }
}
