// SPDX-License-Identifier: AGPL-3.0
// Modified from https://github.com/lifinance/create3-factory/blob/main/src/ICREATE3Factory.sol
pragma solidity >=0.6.0;

/**
 * @title Factory for deploying contracts to deterministic addresses via Create3
 * @author BGD Labs
 * @notice Defines the methods implemented on Create3Factory contract
 */
interface ICreate3Factory {
  /**
   * @notice Deploys a contract using Create3
   * @dev The provided salt is hashed together with msg.sender to generate the final salt
   * @param salt The deployer-specific salt for determining the deployed contract's address
   * @param creationCode The creation code of the contract to deploy
   * @return The address of the deployed contract
   */
  function create(
    bytes32 salt,
    bytes memory creationCode
  ) external payable returns (address);

  /**
   * @notice Creates a transparent proxy instance, doing the first initialization in construction using Create3
   * @param logic The address of the implementation contract
   * @param admin The admin of the proxy.
   * @param data abi encoded call to the function with `initializer` (or `reinitializer`) modifier.
   *             E.g. `abi.encodeWithSelector(mockImpl.initialize.selector, 2)`
   *             for an `initialize` function being `function initialize(uint256 foo) external initializer;`
   * @param salt Value to be used in the address calculation, to be chosen by the account calling this function
   * @return The address of the proxy deployed
   **/
  function createWithTransparentProxy(
    address logic,
    address admin,
    bytes calldata data,
    bytes32 salt
  ) external payable returns (address);

  /**
   * @notice Predicts the address of a deployed contract
   * @dev The provided salt is hashed together with the deployer address to generate the final salt
   * @param deployer The deployer account that will call deploy()
   * @param salt The deployer-specific salt for determining the deployed contract's address
   * @return The address of the contract that will be deployed
   */
  function predictAddress(
    address deployer,
    bytes32 salt
  ) external view returns (address);
}
