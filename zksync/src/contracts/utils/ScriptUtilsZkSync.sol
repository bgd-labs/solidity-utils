// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICreate2Factory} from './interfaces/ICreate2Factory.sol';

/***
 * @title Create2UtilsZkSync
 * @author BGD Labs
 * @notice Script utilities to create smart contracts with deterministic addresses on the zkSync network.
 * @dev Deployment on the zkSync network with Foundry differs from the Ethereum network. To deploy a contract
 * on the zkSync network using the CREATE2 opcode, you need to either use the Solidity structure: `new Contract{salt: salt}()` or
 * use the Create2Factory contract from the era-contracts repository. When using the Create2Factory to deploy a smart contract with
 * a deterministic address, you need to provide not the contract creation code, but the hash of the contract bytecode.
 * Then zkSync tries to match the provided bytecode hash with contracts that already exist on the network. If it finds one,
 * the contract will be deployed. 
 *   So if you deploy the contract that  already exists in zksync network, you simply need to call the
 * deploy function with a valid bytecode hash(check below). Otherwise, consider using the factory method. You'll need to write
 * a factory contract like this:
 * 
 * contract Factory {
 *   address public immutable IMPL;
 *   
 *   constructor(bytes32 salt, bytes memory arguments) {
 *     IMPL = Create2UtilsZkSync.create2Deploy(type(Contract).creationCode, arguments); 
 *   }
 * }
 * 
 *   This approach will force foundry-zksync to create EIP-712 transaction and pass your contract's full bytecode 
 * in `factory_deps` field of the transaction. It can be handled by zksync network and you'll be able to
 * deploy contract in deterministic address even if it wasn't deployed before.
 * @dev This library uses the contract's creation code to compute the bytecode hash.
 * You can get the creation code using `type(Contract).creationCode`.
 * IMPORTANT: There might be a bug while compiling and executing tests or scripts with the --zksync flag.
 * If you simply use `type(Contract).creationCode`, it will return the solc compiler bytecode. However, if
 * `type(Contract).creationCode` is used in a deployed contract, it will return the correct (zksolc) bytecode.
 * So, if you want to use a function with creation code, you need to get it from the contract like this:
 *
 * contract ContractBytecodeRetriever {
 *    function getCreationCode() external view returns (bytes memory) {
 *       return type(Contract).creationCode;
 *    }
 * }
 *
 */
library Create2UtilsZkSync {
  // https://github.com/matter-labs/era-contracts/blob/main/system-contracts/contracts/Create2Factory.sol
  address public constant CREATE2_FACTORY = 0x0000000000000000000000000000000000010000;

  bytes32 public constant ZKSYNC_CREATE2_PREFIX = keccak256('zksyncCreate2');

  /**
   * @dev Deploys a contract using the CREATE2 opcode.
   * @param salt A salt to influence the address of the deployed contract.
   * @param creationCode The creation bytecode of the contract to be deployed. IMPORTANT: Check the library description
   * @param arguments The constructor arguments for the contract.
   * @return The address of the deployed contract.
   */
  function create2Deploy(
    bytes32 salt,
    bytes memory creationCode,
    bytes memory arguments
  ) internal returns (address) {
    return create2Deploy(salt, getBytecodeHashFromBytecode(creationCode), arguments);
  }

  /**
   * @dev Deploys a contract using the CREATE2 opcode.
   * @param salt A salt to influence the address of the deployed contract.
   * @param creationCode The bytecode of the contract to be deployed. IMPORTANT: Check the library description
   * @return The address of the deployed contract.
   */
  function create2Deploy(bytes32 salt, bytes memory creationCode) internal returns (address) {
    return create2Deploy(salt, getBytecodeHashFromBytecode(creationCode));
  }

  /**
   * @dev Deploys a contract using the CREATE2 opcode.
   * @param salt A salt to influence the address of the deployed contract.
   * @param bytecodeHash The bytecode hash of the contract to be deployed.
   * @return The address of the deployed contract.
   */
  function create2Deploy(bytes32 salt, bytes32 bytecodeHash) internal returns (address) {
    return create2Deploy(salt, bytecodeHash, '');
  }

  /**
   * @dev Deploys a contract using the CREATE2 opcode.
   * @param salt A salt to influence the address of the deployed contract.
   * @param bytecodeHash The bytecode hash of the contract to be deployed.
   * @param arguments The constructor arguments for the contract.
   * @return The address of the deployed contract.
   */
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
      address deployedAt = ICreate2Factory(CREATE2_FACTORY).create2(salt, bytecodeHash, arguments);

      require(deployedAt == computed, 'failure at create2 address derivation');
      return deployedAt;
    }
  }

  /**
   * @dev Checks if a contract is deployed at the given address.
   * @param _addr The address to check.
   * @return isContract True if a contract is deployed at the address, false otherwise.
   */
  function isContractDeployed(address _addr) internal view returns (bool isContract) {
    return (_addr.code.length > 0);
  }

  /**
   * @dev Computes the CREATE2 address for a contract deployment.
   * @param salt A salt to ensure unique addresses.
   * @param creationCode The bytecode of the contract to be deployed. IMPORTANT: Check the library description
   * @return The computed CREATE2 address.
   */
  function computeCreate2Address(
    bytes32 salt,
    bytes memory creationCode
  ) internal pure returns (address) {
    return computeCreate2Address(salt, getBytecodeHashFromBytecode(creationCode));
  }

  /**
   * @dev Computes the CREATE2 address for a contract deployment with constructor arguments.
   * @param salt A salt to ensure unique addresses.
   * @param creationCode The bytecode of the contract to be deployed. IMPORTANT: Check the library description
   * @param arguments The constructor arguments for the contract.
   * @return The computed CREATE2 address.
   */
  function computeCreate2Address(
    bytes32 salt,
    bytes memory creationCode,
    bytes memory arguments
  ) internal pure returns (address) {
    return computeCreate2Address(salt, getBytecodeHashFromBytecode(creationCode), arguments);
  }

  /**
   * @dev Computes the CREATE2 address for a contract deployment using a bytecode hash.
   * @param salt A salt to ensure unique addresses.
   * @param bytecodeHash The hash of the contract bytecode.
   * @return The computed CREATE2 address.
   */
  function computeCreate2Address(
    bytes32 salt,
    bytes32 bytecodeHash
  ) internal pure returns (address) {
    return computeCreate2Address(salt, bytecodeHash, '');
  }

  /**
   * @dev Computes the CREATE2 address for a contract deployment using a bytecode hash and constructor arguments.
   * @param salt A salt to ensure unique addresses.
   * @param bytecodeHash The hash of the contract bytecode.
   * @param arguments The constructor arguments for the contract.
   * @return The computed CREATE2 address.
   */
  function computeCreate2Address(
    bytes32 salt,
    bytes32 bytecodeHash,
    bytes memory arguments
  ) internal pure returns (address) {
    bytes32 addressHash = keccak256(
      bytes.concat(
        ZKSYNC_CREATE2_PREFIX,
        bytes32(uint256(uint160(CREATE2_FACTORY))),
        salt,
        bytecodeHash,
        keccak256(arguments)
      )
    );

    return address(uint160(uint256(addressHash)));
  }

  /**
   * @dev Extracts a 32-byte hash from the given bytecode.
   * To deploy smart contracts on the zkSync network, you need to provide
   * the zkSync contract bytecode hash. This is a specific hash for the zkSync network.
   * This hash is stored in the contract creation bytecode, starting from
   * the 36th byte and has a length of 32 bytes. This function extracts this hash.
   * @param data The bytecode from which to extract the hash.
   * @return The extracted 32-byte hash.
   */
  function getBytecodeHashFromBytecode(bytes memory data) internal pure returns (bytes32) {
    uint256 start = 36;
    uint256 length = 32;
    require(start + length <= data.length, 'Invalid bytecode');

    bytes memory result = new bytes(length);
    assembly {
      let dataPtr := add(data, 32)
      let resultPtr := add(result, 32)

      // Copy the slice
      let words := div(add(length, 31), 32)
      let srcPtr := add(dataPtr, start)

      for { let i := 0 } lt(i, words) { i := add(i, 1) } {
        mstore(add(resultPtr, mul(i, 32)), mload(add(srcPtr, mul(i, 32))))
      }

      mstore(result, length)
    }
    return bytes32(result);
  }
}
