// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IRescuable721} from './interfaces/IRescuable721.sol';

interface IERC721 {
  function transferFrom(address from, address to, uint256 tokenId) external;
}

/**
 * @title Rescuable721
 * @author defijesus.eth
 * @notice abstract contract with the methods to rescue ERC721 tokens from a contract
 */
abstract contract Rescuable721 is IRescuable721 {

  error ONLY_RESCUE_GUARDIAN();

  /// @notice modifier that checks that caller is allowed address
  modifier onlyRescueGuardian() {
    if(msg.sender != whoCanRescue()) revert ONLY_RESCUE_GUARDIAN();
    _;
  }

  /// @inheritdoc IRescuable721
  function emergencyTokenTransfer(
    address erc721Token,
    address to,
    uint256 tokenId
  ) external virtual onlyRescueGuardian {
    IERC721(erc721Token).transferFrom(address(this), to, tokenId);

    emit ERC721Rescued(msg.sender, erc721Token, to, tokenId);
  }

  /// @inheritdoc IRescuable721
  function whoCanRescue() public view virtual returns (address);
}
