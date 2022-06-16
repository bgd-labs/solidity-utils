// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
  IInitializableAdminUpgradeabilityProxyFactory
} from '../contracts/transparent-proxy/interfaces/IInitializableAdminUpgradeabilityProxyFactory.sol';

library Rinkeby {
  IInitializableAdminUpgradeabilityProxyFactory TRANSPARENT_PROXY_FACTORY =
    0xdb2aba599d0749ba7aec651601d3158c8fd21b8d;
}
