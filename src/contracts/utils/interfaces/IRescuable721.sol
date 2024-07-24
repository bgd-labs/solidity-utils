// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/**
 * @title IRescuable721
 * @author defijesus.eth
 * @notice interface containing the objects, events and methods definitions of the Rescuable721 contract
 */
interface IRescuable721 {
  /**
   * @notice emitted when erc721 tokens get rescued
   * @param caller address that triggers the rescue
   * @param token address of the rescued token
   * @param to address that will receive the rescued tokens
   * @param tokenId the id of the token rescued
   */
  event ERC721Rescued(
    address indexed caller,
    address indexed token,
    address indexed to,
    uint256 tokenId
  );

  /**
   * @notice method called to rescue a ERC721 token sent erroneously to the contract. Only callable by owner
   * @param erc721Token address of the token to rescue
   * @param to address to send the token
   * @param tokenId of token to rescue
   */
  function emergency721TokenTransfer(address erc721Token, address to, uint256 tokenId) external;
}

interface IERC721 {
  function transferFrom(address from, address to, uint256 tokenId) external;
}
