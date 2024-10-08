// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Address} from '../src/contracts/oz-common/Address.sol';
import {MockERC721, ERC721} from '../src/mocks/ERC721.sol';
import {Rescuable721} from '../src/contracts/utils/Rescuable721.sol';
import {RescuableBase, IRescuableBase} from '../src/contracts/utils/RescuableBase.sol';

contract MockReceiver721TokensContract is Rescuable721 {
  address public immutable ALLOWED;

  constructor(address allowedAddress) {
    ALLOWED = allowedAddress;
  }

  function whoCanRescue() public view override returns (address) {
    return ALLOWED;
  }

  function maxRescue(
    address
  ) public pure override(RescuableBase, IRescuableBase) returns (uint256) {
    return type(uint256).max;
  }
}

contract Rescue721Test is Test {
  address public constant ALLOWED = address(1023579);

  MockERC721 public testToken;
  MockReceiver721TokensContract public tokensReceiver;

  event ERC721Rescued(
    address indexed caller,
    address indexed token,
    address indexed to,
    uint256 tokenId
  );

  function setUp() public {
    testToken = new MockERC721();
    tokensReceiver = new MockReceiver721TokensContract(ALLOWED);
  }

  function testFuzzEmergencyTokenTransfer(address recipient) public {
    vm.assume(recipient != address(0));
    testToken.mint(address(tokensReceiver), 1);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 1);

    hoax(ALLOWED);
    vm.expectEmit(true, true, false, true);
    emit ERC721Rescued(ALLOWED, address(testToken), recipient, 1);
    tokensReceiver.emergency721TokenTransfer(address(testToken), recipient, 1);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 0);
    assertEq(testToken.balanceOf(address(recipient)), 1);
  }

  function testFuzzEmergencyTokenTransferWhenNotOwner(
    address randomWallet,
    address recipient
  ) public {
    vm.assume(randomWallet != address(0));
    vm.assume(recipient != address(0));
    testToken.mint(randomWallet, 1);
    hoax(randomWallet);
    testToken.transferFrom(randomWallet, address(tokensReceiver), 1);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 1);

    vm.expectRevert();
    tokensReceiver.emergency721TokenTransfer(address(testToken), recipient, 1);
  }
}
