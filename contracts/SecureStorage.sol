// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract SecureStorage is Ownable, Pausable {
  uint256 private storedValue;

  event ValueUpdated(address indexed updater, uint256 newValue);

  constructor() Ownable(msg.sender) {}

  function setValue(uint256 _val) public onlyOwner whenNotPaused {
    storedValue = _val;
    emit ValueUpdated(msg.sender, _val);
  }

  function getValue() public view returns (uint256) {
    return storedValue;
  }

  function pause() public onlyOwner { _pause(); }
  function unpause() public onlyOwner { _unpause(); }
}
