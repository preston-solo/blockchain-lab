EXERCISE 2.1.1– SHA-256 Hash Exploration
    
RECORDED TERMINAL OUTPUT

EXPERIMENT 1 OUTPUT 
Hash 1: 2ed29dfd82729a6e133d527e02598be695b
23267568571cdcb6de2d26fdfdf0a

Hash 2: bca87b0805fa5f9923ed10959828d09f7a5
cb3b0ea97115af9aa786c738e4a9e

Same?  False

EXPERIMENT 2 OUTPUT 

Block Hash: ad7b9dfd10121aef71cd93e00598ee895b1
12267568571bdcb6de1d26fdfbb11


  EXERCISE 2.1.2 -Proof of Work Simulation 

# Difficulty 3 Target Requirements: 

* Nonce discovered: 1120

*Resulting block hash: 000477110bcbb95a
73090bc80ef6b065eb79adee85bfcaaa85e5cca39cc2014

Processing duration: 0.009

# Difficulty 5 Target Requirements:

* Nonce found: 273175

*Resulting hash: 00004ab82f1ccada4ff6b2e86b
 dd372facb6cc62479d043ff5fee5

*Time Elapsed: 0.4476s

# EXERCISE 2.3 Consensus Mechanisms Discussion 

Q1: What is the primary security tradeoff between Proof of Work 
and Proof of Stake?

Answer: Proof of Work offers exceptional, time-tested security 
because restricting history requires an attacker to control more 
physical computing power than the rest of the network combined. 
However, its primary resource waste is its massive energy consumption 
of the miners, which updates code dynamically. While Proof of Stake eliminates 
this resource waste by replacing computational power with financial collateral, 
networks with PoS face the risk where the wealth commands the highest amount of 
influence over governance and block creation.

Q2: In a 5-node network, how many nodes must be
compromised for a 51% attack?

Answer: An attacker requires control over a minimum of 3 nodes. Distributed systems 
use Byzantine ledger replication protocols where consensus rules demand a simple majority
to validate structural network state transitions. Hijacking 3 out of 5 network nodes 
gives an adversary an explicit 60% authority stake, clearing the 51% majority boundary 
necessary to successfully rewrite past block details.

Q3: Why is finality important for
financial transactions on a blockchain?

Answer: Settlement finality provides an absolute mathematical guarantee
that once a transaction entry is written into the 
distributed ledger, it becomes permanently immutable and
cannot be canceled, unlinked, or dropped by future blockchain re-organizations.
Without a firm finality boundary, malicious actors could perform double-spend vectors
where they transfer currency to a merchant, wait to claim their items, and then mines 
a longer, alternative private branch link that clears out the original transaction records.





Day 2 ROLE ROTATION CONFIGURATION

As mandated by the laboratory deployment rules, the group roles have been rotated clockwise for Day 2:

| Day 1 Role | Day 2 Role | Assigned Team Member (GitHub Username / Name) |
| :--- | :--- | :--- |
| Security Analyst |  Scribe / Documenter | Nkembeni Dabrat |
| Scribe / Documenter |  Lead Developer |Neba Precious Sirri|
| Lead Developer |  QA Tester | Preston |
| QA Tester |  Network Engineer| Mordepet |
| Network Engineer |  Security Analyst| Loise|


Operational Baseline & Environment Audit.

Prior to initializing Day 2 smart contract execution sequences, the team conducted a full administrative environment configuration audit to stabilize our development workstation, yielding the following validated operational profile:

Operating System Node: Ubuntu 20.04+ running inside a Windows Subsystem for Linux (WSL2) container environment.

Node.js Environment Run-layer: Upgraded to v22.2.3 (Note: Upgraded from the baseline Day 1 manual recommendation of v20 to resolve active runtime module execution exceptions and library orchestration conflicts).  

Local Blockchain Node Simulator: Ganache CLI actively serving as the target network execution pipeline on local host RPC Port 8545. 

Compiler Setup Verification: Hardhat framework successfully configured to parse, execute, and pass complete npx hardhat compile actions cleanly without structural warnings.  

Session 4: Reentrancy Vulnerability Lab

Section 4.1: Vulnerability Overview & Environment Setup

1. Objective
The objective of this session is to analyze, exploit, and subsequently mitigate a critical Reentrancy Vulnerability within a decentralized banking context. Reentrancy represents one of the most destructive smart contract flaws, famously responsible for the historic DAO hack.

2. The Mechanics of Reentrancy
The flaw occurs when a smart contract transfers ether to an untrusted external address before updating its internal state balance ledger. In Ethereum, sending ether transfers transaction control to the receiving contract's fallback or receive() function. If that receiving contract is malicious, it can recursively call the withdrawal function again before the first invocation completes, draining the contract's entire liquidity pool.


3. Environment Initialization
To set up the lab environment, the project workspace was verified to ensure the Hardhat network suite was ready to deploy and test local contracts using Solidity compiler version ^0.8.19.


Section 4.2: Creating the Insecure Contract (VulnerableBank.sol)

1. Source Code Implementation
A deliberately insecure banking contract was created in the local directory at contracts/VulnerableBank.sol. The implementation utilizes a state mapping to track user deposits and exposes a flawed withdrawal mechanism.



...
contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // THE VULNERABLE FUNCTION (Prone to Reentrancy)
    function withdraw() public {
        uint256 bal = balances[msg.sender];
        require(bal > 0, "Insufficient balance");

        // Vulnerable external call made BEFORE updating the state balance
        (bool success, ) = msg.sender.call{value: bal}("");
        require(success, "Transfer failed");

        // CRITICAL FLAW: This state update is never reached during an attack
        balances[msg.sender] = 0; 
    }
}
...


1. Technical Flaw Analysis (Why it is Vulnerable)
The code violates the foundational Checks-Effects-Interactions security pattern:

Checks: The contract correctly checks the balance condition (require(bal > 0)).

Interactions: The contract interacts with the external world by sending ether (msg.sender.call).

Effects: The contract attempts to apply its state effect (balances[msg.sender] = 0) after the interaction. Because control is handed over to an external attacker during the interaction step, the state effect is suspended in mid-execution, leaving the attacker's balance fully intact for recursive draining.

3. Compilation Verification
The workspace environment successfully compiled the insecure contract using the Hardhat framework:

Command: npx hardhat compile

Output: Compilation successful. Artifacts and ABI binaries safely generated inside the artifacts/contracts/VulnerableBank.sol/ directory.




Section: 4.2.1 – Identify & Fix (VulnerableBank.sol vs SecureBank.sol)

1. Compilation Confirmation
The deliberately insecure contract VulnerableBank.sol was verified using the Hardhat compilation framework.

Execution Command: npx hardhat compile

Output Status: Successful compilation. Artifact binaries and contract ABIs were safely generated in the workspace build folder.

2. Vulnerable Line Identification and Exploitation Analysis
The state-draining security vulnerability inside VulnerableBank.sol resides entirely within the following implementation block:


```
function withdraw() public {
        uint256 bal = balances[msg.sender];
        rrequirebal > 0, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: bal}("");  // <--- CRITICAL VULNERABILITY LINK
        require(success, "Transfer failed");

        balances[msg.sender] = 0; 
    }
```

The vulnerability is exploitable because VulnerableBank transfers funds to an external contract BEFORE updating its balance record. This allows a malicious contract to trigger its fallback function and recursively call withdraw() again. Because the line that zeroes out the balance has not been reached, the bank reads the attacker's balance as fully intact and sends funds repeatedly, spinning in a loop until the contract is completely drained.

3. Patched Source Code (contracts/SecureBank.sol)
To securely resolve this reentrancy vulnerability, the code was refactored to prioritize state effect adjustments before executing external transfers.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SecureBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        // 1. CHECK
        uint256 bal = balances[msg.sender];
        require(bal > 0, "Insufficient balance");

        // 2. EFFECT (State balance is zeroed out BEFORE external interaction)
        balances[msg.sender] = 0;

        // 3. INTERACTION
        (bool success, ) = msg.sender.call{value: bal}("");
        require(success, "Transfer failed");
    }
}
 ```

4. Comparative Analysis
The difference is the execution order of state updates and external transfers. VulnerableBank risks asset theft because it initiates an external ether transfer before zeroing out the sender's balance mapping. Conversely, SecureBank strictly follows the Checks-Effects-Interactions pattern by modifying the internal ledger balance to zero before sending any funds. This structure stops reentrancy because any recursive attack loop will instantly fail at the initial balance check.

Section 4.3: Access Control Hardening (SecureStorage.sol

1. Dependency Installation
To integrate industry-standard, audited security modules, the OpenZeppelin Contracts package was added to the project local workspace directory.

Execution Command:
npm install @openzeppelin/contracts

2. Hardened Source Code (contracts/SecureStorage.sol)
The baseline storage contract was refactored to inherit standardized access restrictions and emergency circuit-breaker protocols.


...
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

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
...

 3. Compilation, Deployment, and Hardhat Console Testing
Compilation Command:

npx hardhat compile

Status: Successful. OpenZeppelin dependencies resolved and artifact files generated.

Hardhat Console Interaction & Pause Functionality Validation:
To verify the circuit-breaker runtime constraints, the following execution sequence was performed inside the interactive environment:

```
// 1. Get contract instance and deploy
const SecureStorage = await ethers.getContractFactory("SecureStorage");
const secureStorage = await SecureStorage.deploy();

// 2. Test standard functionality while active
await secureStorage.setValue(100); 
console.log(await secureStorage.getValue()); // Output: 100

// 3. Trigger Emergency Circuit-Breaker (Pause)
await secureStorage.pause();

// 4. Attempt state modification while contract is paused
await secureStorage.setValue(200); 
// CRITICAL ERROR RESULT: Transaction reverted with OpenZeppelin error: "EnforcedPause()"
```
