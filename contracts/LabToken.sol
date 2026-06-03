// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19; 
  
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol"; 
  
contract LabToken is ERC20, Ownable { 
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18; 
  
    constructor() ERC20("LabToken", "LTK") Ownable(msg.sender) { 
        _mint(msg.sender, 100_000 * 10**18);  // Initial supply to deployer 
    } 
  
    function mint(address to, uint256 amount) public onlyOwner { 
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply"); 
        _mint(to, amount); 
    } 
} 