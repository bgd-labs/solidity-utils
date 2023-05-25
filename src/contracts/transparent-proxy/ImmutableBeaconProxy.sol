// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IBeacon} from './interfaces/IBeacon.sol';
import {Proxy} from './Proxy.sol';
import {Address} from '../oz-common/Address.sol';

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from an {UpgradeableBeacon}.
 * The beacon address is immutable. The purpose of it, is to be able to access this proxy via delegatecall

 * !!! IMPORTANT CONSIDERATION !!!
 * We expect that that implementation will not have any storage associated,
 * because it will not be accessible via delegatecall, and will not work as expected
 */
contract ImmutableBeaconProxy is Proxy {
  address internal immutable _beacon;

  constructor(address beacon) {
    require(Address.isContract(beacon), 'beacon is not a contract');
    require(
      Address.isContract(IBeacon(beacon).implementation()),
      'beacon implementation is not a contract'
    );

    // there is no initialization call, because we expect that implementation should have no storage
    _beacon = beacon;
  }

  /**
   * @dev Returns the current implementation address of the associated beacon.
   */
  function _implementation() internal view virtual override returns (address) {
    return IBeacon(_beacon).implementation();
  }
}
