// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ITransparentProxyFactory {
  event ProxyCreated(address proxy, address indexed logic, address indexed initialOwner);
  event ProxyAdminCreated(address proxyAdmin, address indexed initialOwner);
  event ProxyDeterministicCreated(
    address proxy,
    address indexed logic,
    address indexed initialOwner,
    bytes32 indexed salt
  );
  event ProxyAdminDeterministicCreated(
    address proxyAdmin,
    address indexed initialOwner,
    bytes32 indexed salt
  );

  /**
   * @notice Creates a transparent proxy instance, doing the first initialization in construction
   * @dev Version using CREATE
   * @param logic The address of the implementation contract
   * @param initialOwner The initial owner of the admin of the proxy.
   * @param data abi encoded call to the function with `initializer` (or `reinitializer`) modifier.
   *             E.g. `abi.encodeWithSelector(mockImpl.initialize.selector, 2)`
   *             for an `initialize` function being `function initialize(uint256 foo) external initializer;`
   * @return address The address of the proxy deployed
   **/
  function create(
    address logic,
    address initialOwner,
    bytes memory data
  ) external returns (address);

  /**
   * @notice Creates a proxyAdmin instance, and transfers ownership to provided owner
   * @dev Version using CREATE
   * @param initialOwner The initial owner of the proxyAdmin deployed.
   * @return address The address of the proxyAdmin deployed
   **/
  function createProxyAdmin(address initialOwner) external returns (address);

  /**
   * @notice Creates a transparent proxy instance, doing the first initialization in construction
   * @dev Version using CREATE2, so deterministic
   * @param logic The address of the implementation contract
   * @param initialOwner The initial owner of the admin of the proxy.
   * @param data abi encoded call to the function with `initializer` (or `reinitializer`) modifier.
   *             E.g. `abi.encodeWithSelector(mockImpl.initialize.selector, 2)`
   *             for an `initialize` function being `function initialize(uint256 foo) external initializer;`
   * @param salt Value to be used in the address calculation, to be chosen by the account calling this function
   * @return address The address of the proxy deployed
   **/
  function createDeterministic(
    address logic,
    address initialOwner,
    bytes memory data,
    bytes32 salt
  ) external returns (address);

  /**
   * @notice Deterministically create a proxy admin instance and transfers ownership to provided owner.
   * @dev Version using CREATE2, so deterministic
   * @param adminOwner The owner of the ProxyAdmin deployed.
   * @param salt Value to be used in the address calculation, to be chosen by the account calling this function
   * @return address The address of the proxy admin deployed
   **/
  function createDeterministicProxyAdmin(
    address adminOwner,
    bytes32 salt
  ) external returns (address);

  /**
   * @notice Pre-calculates and return the address on which `createDeterministic` will deploy a proxy
   * @param logic The address of the implementation contract
   * @param initialOwner The initial owner of the admin of the proxy.
   * @param data abi encoded call to the function with `initializer` (or `reinitializer`) modifier.
   *             E.g. `abi.encodeWithSelector(mockImpl.initialize.selector, 2)`
   *             for an `initialize` function being `function initialize(uint256 foo) external initializer;`
   * @param salt Value to be used in the address calculation, to be chosen by the account calling this function
   * @return address The pre-calculated address
   **/
  function predictCreateDeterministic(
    address logic,
    address initialOwner,
    bytes calldata data,
    bytes32 salt
  ) external view returns (address);

  /**
   * @notice Pre-calculates and return the address on which `createDeterministic` will deploy the proxyAdmin
   * @param salt Value to be used in the address calculation, to be chosen by the account calling this function
   * @return address The pre-calculated address
   **/
  function predictCreateDeterministicProxyAdmin(
    bytes32 salt,
    address initialOwner
  ) external view returns (address);

  /**
   * @notice Returns the address of the `ProxyAdmin` associated with a given transparent proxy.
   * @param proxy Address of the transparent proxy
   * @return address Address of the `ProxyAdmin` that was deployed when the proxy was created
   */
  function getProxyAdmin(address proxy) external view returns (address);
}
