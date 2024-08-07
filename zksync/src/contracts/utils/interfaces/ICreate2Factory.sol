// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICreate2Factory {
  function create2(
    bytes32 _salt,
    bytes32 _bytecodeHash,
    bytes memory _input
  ) external payable returns (address);
}
