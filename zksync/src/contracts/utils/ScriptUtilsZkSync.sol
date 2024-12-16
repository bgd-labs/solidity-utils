// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICreate2Factory} from './interfaces/ICreate2Factory.sol';

library Create2UtilsZkSync {
  // https://github.com/matter-labs/era-contracts/blob/main/system-contracts/contracts/Create2Factory.sol
  address public constant CREATE2_FACTORY = 0x0000000000000000000000000000000000010000;

  function create2Deploy(
    bytes32 salt,
    bytes32 bytecodeHash,
    bytes memory arguments
  ) internal returns (address) {
    if (isContractDeployed(CREATE2_FACTORY) == false) {
      revert('MISSING_CREATE2_FACTORY');
    }
    address computed = computeCreate2Address(salt, bytecodeHash, arguments);

    if (isContractDeployed(computed)) {
      return computed;
    } else {
      address deployedAt = ICreate2Factory(CREATE2_FACTORY).create2(
        salt,
        bytecodeHash,
        arguments
      );

      require(deployedAt == computed, 'failure at create2 address derivation');
      return deployedAt;
    }
  }

  function create2Deploy(bytes32 salt, bytes32 bytecodeHash) internal returns (address) {
    if (isContractDeployed(CREATE2_FACTORY) == false) {
      revert('MISSING_CREATE2_FACTORY');
    }
    address computed = computeCreate2Address(salt, bytecodeHash);

    if (isContractDeployed(computed)) {
      return computed;
    } else {
      address deployedAt = ICreate2Factory(CREATE2_FACTORY).create2(
        salt,
        bytecodeHash,
        ''
      );

      require(deployedAt == computed, 'failure at create2 address derivation');
      return deployedAt;
    }
  }

  function computeCreate2Address(
    bytes32 salt,
    bytes32 bytecodeHash
  ) internal pure returns (address) {
    return computeCreate2Address(salt, bytecodeHash, '');
  }

  function computeCreate2Address(
    bytes32 salt,
    bytes32 bytecodeHash,
    bytes memory arguments
  ) internal pure returns (address) {
    bytes32 addressHash = keccak256(
      bytes.concat(
        keccak256('zksyncCreate2'), // zkSync create2 prefix
        bytes32(uint256(uint160(CREATE2_FACTORY))),
        salt,
        bytecodeHash,
        keccak256(arguments)
      )
    );

    return address(uint160(uint256(addressHash)));
  }

  function isContractDeployed(address _addr) internal view returns (bool isContract) {
    return (_addr.code.length > 0);
  }
}
