// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IInitializableAdminUpgradeabilityProxyFactory} from '../contracts/transparent-proxy/interfaces/IInitializableAdminUpgradeabilityProxyFactory.sol';

library Polygon {
  IInitializableAdminUpgradeabilityProxyFactory constant TRANSPARENT_PROXY_FACTORY =
    IInitializableAdminUpgradeabilityProxyFactory(0xA86FAeA37c0644ABB2e4Cc9C30CF7656b95F8006);
}
