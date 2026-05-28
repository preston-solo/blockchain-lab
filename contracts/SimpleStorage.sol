// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleStorage {
    uint256 private storedValue;
    address public owner;

    event ValueUpdated(address indexed updater, uint256 newValue);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorised");
        _;
    }

    function setValue(uint256 _val) public onlyOwner {
        storedValue = _val;
        emit ValueUpdated(msg.sender, _val);
    }

    function getValue() public view returns (uint256) {
        return storedValue;
    }
}
