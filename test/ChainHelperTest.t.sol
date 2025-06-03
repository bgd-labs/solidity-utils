// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {ChainHelpers} from '../src/contracts/utils/ChainHelpers.sol';

/// forge-config: default.allow_internal_expect_revert = true
contract TestChainHelpers is Test {
  function test_selectChain_shouldRevert() external {
    vm.createSelectFork(vm.rpcUrl('optimism'));
    vm.expectRevert(ChainHelpers.UnknownChainId.selector);
    ChainHelpers.selectChain(vm, 0);
  }
}
