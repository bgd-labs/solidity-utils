// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {ChainHelpers} from '../src/contracts/utils/ChainHelpers.sol';

contract TestChainHelpers is Test {
  function test_selectChain_shouldRevert() external {
    vm.expectRevert();
    ChainHelpers.selectChain(vm, 0);
  }
}
