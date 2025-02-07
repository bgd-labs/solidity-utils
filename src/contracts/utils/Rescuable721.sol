// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {IRescuable721, IERC721} from './interfaces/IRescuable721.sol';
import {Rescuable} from './Rescuable.sol';

/**
 * @title Rescuable721
 * @author defijesus.eth
 * @notice abstract contract that extend Rescuable with the methods to rescue ERC721 tokens from a contract
 */
abstract contract Rescuable721 is Rescuable, IRescuable721 {
  /// @inheritdoc IRescuable721
  function emergency721TokenTransfer(
    address erc721Token,
    address to,
    uint256 tokenId
  ) external virtual onlyRescueGuardian {
    IERC721(erc721Token).transferFrom(address(this), to, tokenId);

    emit ERC721Rescued(msg.sender, erc721Token, to, tokenId);
  }
}
