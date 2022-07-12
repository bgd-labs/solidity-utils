// SPDX-License-Identifier: MIT
// Inspired by OpenZeppelin  (access/Ownable.sol)
// From commit https://github.com/OpenZeppelin/openzeppelin-contracts/commit/8b778fa20d6d76340c5fac1ed66c80273f05b95a

pragma solidity ^0.8.0;

import {Context} from '../oz-common/Context.sol';
import {IERC721} from '../oz-common/IERC721.sol';

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner of some NFT) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
  address private _nftContract;
  uint256 private _nftToOwn;

  event OwnershipTransferred(
    address indexed oldNftContract,
    address indexed newNftContract,
    uint256 oldNftToOwn,
    uint256 newNFTToOwn
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor(address nftContract, uint256 nftToOwn) {
    _transferOwnership(nftContract, nftToOwn);
    _checkOwner();
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    _checkOwner();
    _;
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view virtual returns (address) {
    return IERC721(_nftContract).ownerOf(_nftToOwn);
  }

  /**
   * @dev Throws if the sender is not the owner.
   */
  function _checkOwner() internal view virtual {
    require(owner() == _msgSender(), 'NFTOwnable: caller is not the owner');
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    _transferOwnership(address(0), 0);
  }

  /**
   * @dev Transfers ownership of the contract to a new NFT (`newNFT`) located at a new NFT contract (newNftContract).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newNftContract, uint256 newNFT) public virtual onlyOwner {
    require(newNftContract != address(0), 'NFTOwnable: new owner NFT contract is the zero address');
    require(
      IERC721(_nftContract).ownerOf(_nftToOwn) != address(0),
      'NFTOwnable: new NFT to own owner is the zero address'
    );
    _transferOwnership(newNftContract, newNFT);
  }

  /**
   * @dev Transfers ownership of the contract to a new nft (`newNFTToOwn`) located at a new NFT contract (newNftContract).
   * Internal function without access restriction.
   */
  function _transferOwnership(address newNftContract, uint256 newNFTToOwn) internal virtual {
    address oldNftContract = _nftContract;
    uint256 oldNftToOwn = _nftToOwn;

    _nftContract = newNftContract;
    _nftToOwn = newNFTToOwn;

    emit OwnershipTransferred(oldNftContract, newNftContract, oldNftToOwn, newNFTToOwn);
  }
}
