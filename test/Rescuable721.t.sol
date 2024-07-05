// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {Address} from '../src/contracts/oz-common/Address.sol';
import {MockERC721, ERC721} from '../src/mocks/ERC721.sol';
import {Rescuable721} from '../src/contracts/utils/Rescuable721.sol';

contract MockReceiver721TokensContract is Rescuable721 {
  address public immutable ALLOWED;
  constructor (address allowedAddress) {
    ALLOWED = allowedAddress;
  }

  function whoCanRescue() public view override returns (address) {
    return ALLOWED;
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

  function testEmergencyTokenTransfer() public {
    address randomWallet = address(1239516);
    testToken.mint(randomWallet, 1);
    hoax(randomWallet);
    testToken.transferFrom(randomWallet, address(tokensReceiver), 1);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 1);

    address recipient = address(1230123519);

    hoax(ALLOWED);
    vm.expectEmit(true, true, false, true);
    emit ERC721Rescued(ALLOWED, address(testToken), recipient, 1);
    tokensReceiver.emergency721TokenTransfer(address(testToken), recipient, 1);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 0);
    assertEq(testToken.balanceOf(address(recipient)), 1);
  }

  function testEmergencyTokenTransferWhenNotOwner() public {
    address randomWallet = address(1239516);
    testToken.mint(randomWallet, 1);
    hoax(randomWallet);
    testToken.transferFrom(randomWallet, address(tokensReceiver), 1);

    assertEq(testToken.balanceOf(address(tokensReceiver)), 1);

    address recipient = address(1230123519);

    vm.expectRevert();
    tokensReceiver.emergency721TokenTransfer(address(testToken), recipient, 1);
  }
}
