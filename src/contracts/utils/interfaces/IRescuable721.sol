// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

/**
 * @title IRescuable
 * @author defijesus.eth
 * @notice interface containing the objects, events and methods definitions of the Rescuable721 contract
 */
interface IRescuable721 {
  /**
   * @notice emitted when erc20 tokens get rescued
   * @param caller address that triggers the rescue
   * @param token address of the rescued token
   * @param to address that will receive the rescued tokens
   * @param tokenId quantity of tokens rescued
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
  function emergencyTokenTransfer(address erc721Token, address to, uint256 tokenId) external;

  /**
   * @notice method that defines the address that is allowed to rescue tokens
   * @return the allowed address
   */
  function whoCanRescue() external view returns (address);
}
