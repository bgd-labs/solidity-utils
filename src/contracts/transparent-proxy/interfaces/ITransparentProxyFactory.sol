// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ITransparentProxyFactory {
  event ProxyCreated(address proxy, address logic, address proxyAdmin);
  event ProxyDeterministicCreated(address proxy, address logic, address admin, bytes32 salt);

  /**
   * @notice Creates a transparent proxy instance, doing the first initialization in construction
   * @dev Version using CREATE
   * @param logic The address of the implementation contract
   * @param admin The admin of the proxy. Highly recommended to pass the address of a ProxyAdmin
   * @param data abi encoded call to the function with `initializer` (or `reinitializer`) modifier.
   *             E.g. `abi.encodeWithSelector(mockImpl.initialize.selector, 2)`
   *             for an `initialize` function being `function initialize(uint256 foo) external initializer;`
   * @return address The address of the proxy deployed
   **/
  function create(
    address logic,
    address admin,
    bytes memory data
  ) external returns (address);

  /**
   * @notice Creates a transparent proxy instance, doing the first initialization in construction
   * @dev Version using CREATE2, so deterministic
   * @param logic The address of the implementation contract
   * @param admin The admin of the proxy. Highly recommended to pass the address of a ProxyAdmin
   * @param data abi encoded call to the function with `initializer` (or `reinitializer`) modifier.
   *             E.g. `abi.encodeWithSelector(mockImpl.initialize.selector, 2)`
   *             for an `initialize` function being `function initialize(uint256 foo) external initializer;`
   * @param salt Value to be used in the address calculation, to be chosen by the account calling this function
   * @return address The address of the proxy deployed
   **/
  function createDeterministic(
    address logic,
    address admin,
    bytes memory data,
    bytes32 salt
  ) external returns (address);

  /**
   * @notice Pre-calculates and return the address on which `createDeterministic` will deploy a proxy
   * @param logic The address of the implementation contract
   * @param admin The admin of the proxy
   * @param data abi encoded call to the function with `initializer` (or `reinitializer`) modifier.
   *             E.g. `abi.encodeWithSelector(mockImpl.initialize.selector, 2)`
   *             for an `initialize` function being `function initialize(uint256 foo) external initializer;`
   * @param salt Value to be used in the address calculation, to be chosen by the account calling this function
   * @return address The pre-calculated address
   **/
  function predictCreateDeterministic(
    address logic,
    address admin,
    bytes calldata data,
    bytes32 salt
  ) external view returns (address);
}
