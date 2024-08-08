// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import 'forge-std/Test.sol';
import {IStatelessOwnableWithGuardian} from '../src/contracts/access-control/interfaces/IStatelessOwnableWithGuardian.sol';
import {StatelessOwnableWithGuardian} from '../src/contracts/access-control/StatelessOwnableWithGuardian.sol';

contract ImplStatlessOwnableWithGuardian is StatelessOwnableWithGuardian {
  address private _owner;
  address private _guardian;

  constructor(address owner, address guardian) {
    _owner = owner;
    _guardian = guardian;
  }

  function owner() public view override returns (address) {
    return _owner;
  }

  function guardian() public view override returns (address) {
    return _guardian;
  }

  function mock_onlyGuardian() external onlyGuardian {}

  function mock_onlyOwnerOrGuardian() external onlyOwnerOrGuardian {}
}

contract TestOfUpgradableOwnableWithGuardian is Test {
  ImplStatlessOwnableWithGuardian public withGuardian;

  address owner = address(0x4);
  address guardian = address(0x8);

  function setUp() public {
    withGuardian = new ImplStatlessOwnableWithGuardian(owner, guardian);
  }

  function test_getters() external {
    assertEq(withGuardian.owner(), owner);
    assertEq(withGuardian.guardian(), guardian);
  }

  function test_onlyGuardian() external {
    vm.expectRevert(
      abi.encodeWithSelector(
        IStatelessOwnableWithGuardian.OnlyGuardianInvalidCaller.selector,
        address(this)
      )
    );
    withGuardian.mock_onlyGuardian();
  }

  function test_onlyOwnerOrGuardian() external {
    vm.expectRevert(
      abi.encodeWithSelector(
        IStatelessOwnableWithGuardian.OnlyGuardianOrOwnerInvalidCaller.selector,
        address(this)
      )
    );
    withGuardian.mock_onlyOwnerOrGuardian();
  }
}
