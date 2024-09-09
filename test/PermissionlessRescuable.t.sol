// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {IERC20} from '../src/contracts/oz-common/interfaces/IERC20.sol';
import {Address} from '../src/contracts/oz-common/Address.sol';
import {ERC20} from '../src/mocks/ERC20.sol';
import {PermissionlessRescuable, IPermissionlessRescuable} from '../src/contracts/utils/PermissionlessRescuable.sol';

// Concrete implementation of PermissionlessRescuable for testing
contract TestPermissionlessRescuable is PermissionlessRescuable {
  address public fundsReceiver;

  constructor(address _fundsReceiver) {
    fundsReceiver = _fundsReceiver;
  }

  function whoShouldReceiveFunds() public view override returns (address) {
    return fundsReceiver;
  }

  // Function to receive Ether
  receive() external payable {}
}

contract PermissionlessRescuableTest is Test {
  TestPermissionlessRescuable public rescuable;
  ERC20 public mockToken;
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
    rescuable = new TestPermissionlessRescuable(fundsReceiver);
    mockToken = new ERC20('Test', 'TST');
  }

  function test_whoShouldReceiveFunds() public {
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
    vm.expectRevert(bytes('ETH_TRANSFER_FAIL'));
    rescuable.emergencyEtherTransfer(amount);
  }
}
