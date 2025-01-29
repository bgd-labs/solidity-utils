// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import 'forge-std/Test.sol';
import {UpgradeableOwnableWithGuardian, IWithGuardian} from '../src/contracts/access-control/UpgradeableOwnableWithGuardian.sol';

contract ImplOwnableWithGuardian is UpgradeableOwnableWithGuardian {
  function initialize(address owner, address guardian) public initializer {
    __Ownable_With_Guardian_init(owner, guardian);
  }

  function mock_onlyGuardian() external onlyGuardian {}

  function mock_onlyOwnerOrGuardian() external onlyOwnerOrGuardian {}
}

contract TestOfUpgradableOwnableWithGuardian is Test {
  UpgradeableOwnableWithGuardian public withGuardian;

  address owner = address(0x4);
  address guardian = address(0x8);

  function setUp() public {
    withGuardian = new ImplOwnableWithGuardian();
    ImplOwnableWithGuardian(address(withGuardian)).initialize(owner, guardian);
  }

  function test_initializer() external view {
    assertEq(withGuardian.owner(), owner);
    assertEq(withGuardian.guardian(), guardian);
  }

  function test_onlyGuardian() external {
    vm.expectRevert(
      abi.encodeWithSelector(IWithGuardian.OnlyGuardianInvalidCaller.selector, address(this))
    );
    ImplOwnableWithGuardian(address(withGuardian)).mock_onlyGuardian();
  }

  function test_onlyOwnerOrGuardian() external {
    vm.expectRevert(
      abi.encodeWithSelector(IWithGuardian.OnlyGuardianOrOwnerInvalidCaller.selector, address(this))
    );
    ImplOwnableWithGuardian(address(withGuardian)).mock_onlyOwnerOrGuardian();
  }

  function test_updateGuardian_guardian(address newGuardian) external {
    vm.prank(guardian);
    withGuardian.updateGuardian(newGuardian);
  }

  function test_updateGuardian_owner(address newGuardian) external {
    vm.prank(owner);
    withGuardian.updateGuardian(newGuardian);
  }

  function test_updateGuardian_eoa(address eoa, address newGuardian) external {
    vm.assume(eoa != owner && eoa != guardian);

    vm.prank(eoa);
    vm.expectRevert(
      abi.encodeWithSelector(IWithGuardian.OnlyGuardianOrOwnerInvalidCaller.selector, eoa)
    );
    withGuardian.updateGuardian(newGuardian);
  }
}
