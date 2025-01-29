// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from 'openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol';
import {IWithGuardian} from './interfaces/IWithGuardian.sol';

/**
 * Forked version of https://github.com/bgd-labs/solidity-utils/blob/main/src/contracts/access-control/OwnableWithGuardian.sol
 * Relying on UpgradableOwnable & moving the storage to 7201
 */
abstract contract UpgradeableOwnableWithGuardian is OwnableUpgradeable, IWithGuardian {
  /// @custom:storage-location erc7201:aave.storage.OwnableWithGuardian
  struct OwnableWithGuardian {
    address _guardian;
  }

  // keccak256(abi.encode(uint256(keccak256("aave.storage.OwnableWithGuardian")) - 1)) & ~bytes32(uint256(0xff))
  bytes32 private constant OwnableWithGuardianStorageLocation =
    0xdc8016945fab92f4608d8f23802ef36d865b35bd839402e24dec05cd76049e00;

  function _getOwnableWithGuardianStorage() private pure returns (OwnableWithGuardian storage $) {
    assembly {
      $.slot := OwnableWithGuardianStorageLocation
    }
  }

  /**
   * @dev Initializes the contract setting the address provided by the deployer as the initial owner & guardian.
   * @param initialOwner The address of the initial owner
   * @param initialGuardian The address of the initial guardian
   */
  function __Ownable_With_Guardian_init(
    address initialOwner,
    address initialGuardian
  ) internal onlyInitializing {
    __Ownable_init_unchained(initialOwner);
    __Ownable_With_Guardian_init_unchained(initialGuardian);
  }

  function __Ownable_With_Guardian_init_unchained(
    address initialGuardian
  ) internal onlyInitializing {
    _updateGuardian(initialGuardian);
  }

  modifier onlyGuardian() {
    _checkGuardian();
    _;
  }

  modifier onlyOwnerOrGuardian() {
    _checkOwnerOrGuardian();
    _;
  }

  function guardian() public view override returns (address) {
    OwnableWithGuardian storage $ = _getOwnableWithGuardianStorage();
    return $._guardian;
  }

  /// @inheritdoc IWithGuardian
  function updateGuardian(address newGuardian) external override onlyOwnerOrGuardian {
    _updateGuardian(newGuardian);
  }

  /**
   * @dev method to update the guardian
   * @param newGuardian the new guardian address
   */
  function _updateGuardian(address newGuardian) internal {
    OwnableWithGuardian storage $ = _getOwnableWithGuardianStorage();
    address oldGuardian = $._guardian;
    $._guardian = newGuardian;
    emit GuardianUpdated(oldGuardian, newGuardian);
  }

  function _checkGuardian() internal view {
    if (guardian() != _msgSender()) revert OnlyGuardianInvalidCaller(_msgSender());
  }

  function _checkOwnerOrGuardian() internal view {
    if (_msgSender() != owner() && _msgSender() != guardian())
      revert OnlyGuardianOrOwnerInvalidCaller(_msgSender());
  }
}
