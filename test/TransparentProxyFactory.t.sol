// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {TransparentProxyFactory} from '../src/contracts/transparent-proxy/TransparentProxyFactory.sol';
import {MockImpl} from '../src/mocks/MockImpl.sol';

contract TestTransparentProxyFactory is Test {
  function testCreateDeterministic() public {
    TransparentProxyFactory factory = new TransparentProxyFactory();

    MockImpl mockImpl = new MockImpl();

    uint256 FOO = 2;

    bytes memory data = abi.encodeWithSelector(mockImpl.initialize.selector, FOO);

    address predictedAddress1 = factory.predictCreateDeterministic(
      address(mockImpl),
      address(1),
      data,
      bytes32(uint256(1))
    );

    address proxy1 = factory.createDeterministic(
      address(mockImpl),
      address(1),
      data,
      bytes32(uint256(1))
    );

    assertEq(predictedAddress1, proxy1);
    assertEq(MockImpl(proxy1).getFoo(), FOO);
  }
}
