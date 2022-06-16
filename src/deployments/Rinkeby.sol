// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
  IInitializableAdminUpgradeabilityProxyFactory
} from '../contracts/transparent-proxy/interfaces/IInitializableAdminUpgradeabilityProxyFactory.sol';

library Rinkeby {
  IInitializableAdminUpgradeabilityProxyFactory constant TRANSPARENT_PROXY_FACTORY =
    IInitializableAdminUpgradeabilityProxyFactory(0x9f01009e9D1164c45d749FEBb70A1Fe00077246E);
}
