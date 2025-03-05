// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {Address} from 'openzeppelin-contracts/contracts/utils/Address.sol';
import {ERC20} from './mocks/ERC20.sol';
import {RescuableACL as AbstractRescuableACL, IRescuable} from '../src/contracts/utils/RescuableACL.sol';
import {RescuableBase, IRescuableBase} from '../src/contracts/utils/RescuableBase.sol';

contract RescuableACL is AbstractRescuableACL {
  address public immutable ALLOWED;

  constructor(address allowedAddress) {
    ALLOWED = allowedAddress;
  }

  function _checkRescueGuardian() internal view override {
    if (msg.sender != ALLOWED) {
      revert OnlyRescueGuardian();
    }
  }

  function maxRescue(
    address
  ) public pure override(RescuableBase, IRescuableBase) returns (uint256) {
    return type(uint256).max;
  }

  receive() external payable {}
}

contract RescueACLTest is Test {
  address public constant ALLOWED = address(1023579);

  IERC20 public testToken;
  RescuableACL public tokensReceiver;

  event ERC20Rescued(
    address indexed caller,
    address indexed token,
    address indexed to,
    uint256 amount
  );
  event NativeTokensRescued(address indexed caller, address indexed to, uint256 amount);

  function setUp() public {
    testToken = new ERC20('Test', 'TST');
    tokensReceiver = new RescuableACL(ALLOWED);
  }

  function testEmergencyEtherTransfer() public {
    address randomWallet = address(1239516);
    hoax(randomWallet, 50 ether);
    Address.sendValue(payable(address(tokensReceiver)), 5 ether);

    assertEq(address(tokensReceiver).balance, 5 ether);

    address recipient = address(1230123519);

    hoax(ALLOWED);
    vm.expectEmit(true, true, false, true);
    emit NativeTokensRescued(ALLOWED, recipient, 5 ether);
    tokensReceiver.emergencyEtherTransfer(recipient, 5 ether);

    assertEq(address(tokensReceiver).balance, 0 ether);
    assertEq(address(recipient).balance, 5 ether);
  }

  function testEmergencyEtherTransferWhenNotOwner() public {
    address randomWallet = address(1239516);

    hoax(randomWallet, 50 ether);
    Address.sendValue(payable(address(tokensReceiver)), 5 ether);

    assertEq(address(tokensReceiver).balance, 5 ether);

    address recipient = address(1230123519);

    vm.expectRevert(abi.encodeWithSelector(IRescuable.OnlyRescueGuardian.selector));
    tokensReceiver.emergencyEtherTransfer(recipient, 5 ether);
  }

  function testEmergencyTokenTransfer() public {
    address randomWallet = address(1239516);
    deal(address(testToken), randomWallet, 10 ether);
    hoax(randomWallet);
    testToken.transfer(address(tokensReceiver), 3 ether);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 3 ether);

    address recipient = address(1230123519);

    hoax(ALLOWED);
    vm.expectEmit(true, true, false, true);
    emit ERC20Rescued(ALLOWED, address(testToken), recipient, 3 ether);
    tokensReceiver.emergencyTokenTransfer(address(testToken), recipient, 3 ether);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 0);
    assertEq(testToken.balanceOf(address(recipient)), 3 ether);
  }

  function testEmergencyTokenTransferWhenNotOwner() public {
    address randomWallet = address(1239516);
    deal(address(testToken), randomWallet, 10 ether);
    hoax(randomWallet);
    testToken.transfer(address(tokensReceiver), 3 ether);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 3 ether);

    address recipient = address(1230123519);

    vm.expectRevert(abi.encodeWithSelector(IRescuable.OnlyRescueGuardian.selector));
    tokensReceiver.emergencyTokenTransfer(address(testToken), recipient, 3 ether);
  }
}
