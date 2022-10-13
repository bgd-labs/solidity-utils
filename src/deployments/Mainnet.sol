// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

import {ITransparentProxyFactory} from '../contracts/transparent-proxy/interfaces/ITransparentProxyFactory.sol';

library Mainnet {
  ITransparentProxyFactory constant TRANSPARENT_PROXY_FACTORY =
    ITransparentProxyFactory(0xC354ce29aa85e864e55277eF47Fc6a92532Dd6Ca);
}
