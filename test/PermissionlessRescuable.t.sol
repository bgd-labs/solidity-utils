// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {Address} from 'openzeppelin-contracts/contracts/utils/Address.sol';
import {ERC20} from './mocks/ERC20.sol';
import {PermissionlessRescuable as AbstractPermissionlessRescuable, IPermissionlessRescuable} from '../src/contracts/utils/PermissionlessRescuable.sol';
import {RescuableBase, IRescuableBase} from '../src/contracts/utils/RescuableBase.sol';

// Concrete implementation of PermissionlessRescuable for testing
contract PermissionlessRescuable is AbstractPermissionlessRescuable {
  address public fundsReceiver;
  address public restrictedErc20;

  constructor(address _fundsReceiver, address _restrictedErc20) {
    fundsReceiver = _fundsReceiver;
    restrictedErc20 = _restrictedErc20;
  }

  function whoShouldReceiveFunds() public view override returns (address) {
    return fundsReceiver;
  }

  /**
   * Mock implementation forcing 10 wei leftover
   */
  function maxRescue(
    address erc20
  ) public view override(RescuableBase, IRescuableBase) returns (uint256) {
    if (erc20 == restrictedErc20) {
      uint256 balance = ERC20(erc20).balanceOf(address(this));
      return balance > 10 ? balance - 10 : 0;
    }
    return type(uint256).max;
  }

  // Function to receive Ether
  receive() external payable {}
}

contract PermissionlessRescuableTest is Test {
  PermissionlessRescuable public rescuable;
  ERC20 public mockToken;
  ERC20 public restrictedMockToken;
  address public fundsReceiver;

  event ERC20Rescued(
    address indexed caller,
    address indexed token,
    address indexed to,
    uint256 amount
  );
  event NativeTokensRescued(address indexed caller, address indexed to, uint256 amount);

  function setUp() public {
    fundsReceiver = address(0x123);
    mockToken = new ERC20('Test', 'TST');
    restrictedMockToken = new ERC20('Test', 'TST');
    rescuable = new PermissionlessRescuable(fundsReceiver, address(restrictedMockToken));
  }

  function test_whoShouldReceiveFunds() public view {
    assertEq(rescuable.whoShouldReceiveFunds(), fundsReceiver);
  }

  function test_emergencyTokenTransfer() public {
    uint256 amount = 100;
    mockToken.mint(address(rescuable), amount);

    vm.expectEmit(true, true, true, true);
    emit ERC20Rescued(address(this), address(mockToken), fundsReceiver, amount);

    rescuable.emergencyTokenTransfer(address(mockToken), amount);

    assertEq(mockToken.balanceOf(fundsReceiver), amount);
    assertEq(mockToken.balanceOf(address(rescuable)), 0);
  }

  function test_emergencyTokenTransfer_withTransferRestriction() public {
    uint256 amount = 100;

    restrictedMockToken.mint(address(rescuable), amount);

    vm.expectEmit(true, true, true, true);
    emit ERC20Rescued(address(this), address(restrictedMockToken), fundsReceiver, amount - 10);

    rescuable.emergencyTokenTransfer(address(restrictedMockToken), amount - 10);

    assertEq(restrictedMockToken.balanceOf(fundsReceiver), amount - 10);
    assertEq(restrictedMockToken.balanceOf(address(rescuable)), 10);

    // we don't revert on zero to prevent griefing, so this will just pass but doing nothing
    vm.expectEmit(true, true, true, true);
    emit ERC20Rescued(address(this), address(restrictedMockToken), fundsReceiver, 0);

    rescuable.emergencyTokenTransfer(address(restrictedMockToken), 10);
    assertEq(restrictedMockToken.balanceOf(address(rescuable)), 10);
  }

  function test_emergencyEtherTransfer() public {
    uint256 amount = 1 ether;
    payable(address(rescuable)).transfer(amount);

    vm.expectEmit(true, true, true, true);
    emit NativeTokensRescued(address(this), fundsReceiver, amount);

    rescuable.emergencyEtherTransfer(amount);

    assertEq(address(rescuable).balance, 0);
    assertEq(fundsReceiver.balance, amount);
  }

  function test_emergencyTokenTransferInsufficientBalance_shouldRevert() public {
    uint256 amount = 100;
    // Not minting any tokens to the contract
    vm.expectRevert();
    rescuable.emergencyTokenTransfer(address(mockToken), amount);
  }

  function test_emergencyEtherTransferInsufficientBalance_shouldRevert() public {
    uint256 amount = 1 ether;
    // Not sending any Ether to the contract
    vm.expectRevert(abi.encodeWithSelector(IRescuableBase.EthTransferFailed.selector));
    rescuable.emergencyEtherTransfer(amount);
  }
}
