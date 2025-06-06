// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {ChainIds} from './ChainHelpers.sol';

/**
 * Helper contract to enforce correct chain selection in scripts
 */
abstract contract WithChainIdValidation is Script {
  constructor(uint256 chainId) {
    require(block.chainid == chainId, 'CHAIN_ID_MISMATCH');
  }

  modifier broadcast() {
    vm.startBroadcast();
    _;
    vm.stopBroadcast();
  }
}

abstract contract EthereumScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.MAINNET) {}
}

abstract contract OptimismScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.OPTIMISM) {}
}

abstract contract ArbitrumScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.ARBITRUM) {}
}

abstract contract PolygonScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.POLYGON) {}
}

abstract contract AvalancheScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.AVALANCHE) {}
}

abstract contract FantomScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.FANTOM) {}
}

abstract contract HarmonyScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.HARMONY) {}
}

abstract contract MetisScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.METIS) {}
}

abstract contract BaseScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.BASE) {}
}

abstract contract BNBScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.BNB) {}
}

abstract contract GnosisScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.GNOSIS) {}
}

abstract contract ScrollScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.SCROLL) {}
}

abstract contract PolygonZkEvmScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.ZK_EVM) {}
}

abstract contract ZkSyncScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.ZKSYNC) {}
}

abstract contract LineaScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.LINEA) {}
}

abstract contract CeloScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.CELO) {}
}

abstract contract SonicScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.SONIC) {}
}

abstract contract InkScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.INK) {}
}

abstract contract SoneiumScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.SONEIUM) {}
}

abstract contract BobScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.BOB) {}
}

abstract contract MantleScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.MANTLE) {}
}

abstract contract SepoliaScript is WithChainIdValidation {
  constructor() WithChainIdValidation(ChainIds.SEPOLIA) {}
}

library Create2Utils {
  // https://github.com/safe-global/safe-singleton-factory
  address public constant CREATE2_FACTORY = 0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7;

  function create2Deploy(
    bytes32 salt,
    bytes memory bytecode,
    bytes memory arguments
  ) internal returns (address) {
    if (isContractDeployed(CREATE2_FACTORY) == false) {
      revert('MISSING_CREATE2_FACTORY');
    }
    address computed = computeCreate2Address(salt, bytecode, arguments);

    if (isContractDeployed(computed)) {
      return computed;
    } else {
      bytes memory creationBytecode = abi.encodePacked(salt, abi.encodePacked(bytecode, arguments));
      bytes memory returnData;
      (, returnData) = CREATE2_FACTORY.call(creationBytecode);
      address deployedAt = address(uint160(bytes20(returnData)));
      require(deployedAt == computed, 'failure at create2 address derivation');
      return deployedAt;
    }
  }

  function create2Deploy(bytes32 salt, bytes memory bytecode) internal returns (address) {
    if (isContractDeployed(CREATE2_FACTORY) == false) {
      revert('MISSING_CREATE2_FACTORY');
    }
    address computed = computeCreate2Address(salt, bytecode);

    if (isContractDeployed(computed)) {
      return computed;
    } else {
      bytes memory creationBytecode = abi.encodePacked(salt, bytecode);
      bytes memory returnData;
      (, returnData) = CREATE2_FACTORY.call(creationBytecode);
      address deployedAt = address(uint160(bytes20(returnData)));
      require(deployedAt == computed, 'failure at create2 address derivation');
      return deployedAt;
    }
  }

  function isContractDeployed(address _addr) internal view returns (bool isContract) {
    return (_addr.code.length > 0);
  }

  function computeCreate2Address(
    bytes32 salt,
    bytes32 initcodeHash
  ) internal pure returns (address) {
    return
      addressFromLast20Bytes(
        keccak256(abi.encodePacked(bytes1(0xff), CREATE2_FACTORY, salt, initcodeHash))
      );
  }

  function computeCreate2Address(
    bytes32 salt,
    bytes memory bytecode
  ) internal pure returns (address) {
    return computeCreate2Address(salt, keccak256(abi.encodePacked(bytecode)));
  }

  function computeCreate2Address(
    bytes32 salt,
    bytes memory bytecode,
    bytes memory arguments
  ) internal pure returns (address) {
    return computeCreate2Address(salt, keccak256(abi.encodePacked(bytecode, arguments)));
  }

  function addressFromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {
    return address(uint160(uint256(bytesValue)));
  }
}
