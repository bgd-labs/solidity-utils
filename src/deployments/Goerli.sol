// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

import {ITransparentProxyFactory} from '../contracts/transparent-proxy/interfaces/ITransparentProxyFactory.sol';

library Goerli {
  ITransparentProxyFactory constant TRANSPARENT_PROXY_FACTORY =
    ITransparentProxyFactory(0x323b732DB732ac1316A77345A360Fb2751b3BAfD);
}
