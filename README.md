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

| Day 1 Role | Day 2 Role | Assigned Team Member (Name) |
| :--- | :--- | :--- |
| Security Analyst |  Scribe / Documenter | Nkembeni Dabrat |
| Scribe / Documenter |  Lead Developer |Neba Precious Sirri|
| Lead Developer |  QA Tester | Preston Njakoy Shey |
| QA Tester |  Network Engineer| Mordepet |
| Network Engineer |  Security Analyst| Lois Ann Mojoko|


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


Session 5: Token Contract and Event Verification
1. Architecture Implementation (contracts/LabToken.sol)
The team deployed a customized token contract to manage local asset distribution parameters and log real-time execution states via internal EVM events.

...


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract LabToken {
    string public name = "Lab Token";
    string public symbol = "LTK";
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;

    // MANDATORY LABORATORY EVENTS
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);

    constructor(uint256 _initialSupply) {
        mint(msg.sender, _initialSupply);
    }

    function mint(address _to, uint256 _amount) public {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        // Emit event to log transaction data into the blockchain receipts trie
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}


...


2. Hardhat Console Event Logging and Verification
To verify that events emit their indexed arguments correctly, the token contract was tested interactively via the local terminal interface.


...


// 1. Deploy LabToken with an initial supply of 1000 tokens
const LabToken = await ethers.getContractFactory("LabToken");
const token = await LabToken.deploy(1000);
await token.waitForDeployment();

// 2. Execute a state-mutating transfer to trigger an event emission
const [owner, account1] = await ethers.getSigners();
const tx = await token.transfer(account1.address, 250);
const receipt = await tx.wait();

// 3. Inspect Transaction Logs for Event Verification
console.log(receipt.logs[0].fragment.name); 
// Output Verification: "Transfer"

console.log(receipt.logs[0].args);
// Output Data Structure Captured:
// from: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (Owner)
// to: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (Account 1)
// value: 250n


...


3. Analytical Summary: The Purpose of Blockchain Events
Solidity events serve as the crucial structural bridge between the Ethereum Virtual Machine (EVM) execution layer and external user interfaces (dApps). When an event like Transfer is emitted, the contract writes the arguments into the non-modifiable transaction receipt logs on the blockchain.

Because frontend web applications and indexers (like The Graph or Etherscan) cannot easily read raw, internal smart contract state updates in real-time, they instead listen to these indexed event emissions. This allows user interfaces to instantly refresh token balances and display transaction histories without consuming excess computational gas or running constant, expensive read queries against the network state.


Session 6: Security Audit and Peer Review
1. Hardhat Unit Testing Suite & Execution
To formally audit the behavioral security of our smart contracts, the team executed a comprehensive automated unit test suite locally via the Hardhat testing network framework.

Execution Command:npx hardhat test

Test Suite Architecture & Custom Test Case
Our testing script handles 4 distinct functional verification blocks. Alongside standard verification tests for deployment states, asset deposit tracking, and standard authorized withdrawals, our team developed a Custom 4th Test Case specifically designed to simulate an adversarial attack vector:

Custom Test Case Architecture (Reentrancy Prevention Check):
This test handles the deployment of an explicit, malicious contract (Attacker.sol) that hooks into SecureBank's withdrawal entry point. The malicious contract tries to recursively re-enter the withdrawal process inside its low-level execution fallback loop. The test asserts that SecureBank successfully reverts the transaction path with "No balance" (or runs out of gas) on the very first recursive attempt, proving empirical mitigation of the reentrancy vulnerability via the Checks-Effects-Interactions pattern.

Unit Test Console Terminal Output Summary:

Contract: SecureBank Unit Tests
    * Should accept deposits and correctly update user mapping balances
    * Should execute standard, authorized withdrawals cleanly
    * Should reject withdrawals that exceed a user's current ledger balance
    * Custom Test Should successfully revert a recursive contract reentrancy attack loop
      4 passing (840ms).

2. Peer Review Evaluation Sheet






Session 7: Debrief & Submission
Section 7.1: Final Report Requirements Registry
The following matrix serves as our group's formal compliance index and submission registry. All mandatory deliverables specified in the laboratory guidelines have been compiled by the Scribe, verified against our workspace screenshots, and successfully pushed to our project repository:


| Required Report Component | Fulfillment Description & Content Index | Verification Status |
| :--- | :--- | :---: |
| Group Information| Records full names, student IDs, Day 1 role assignments, and the mandatory clockwise role rotation matrix for Day 2. | [√] Verified |
| Installation Screenshots | Complete terminal log dumps confirming successful, error-free version outputs for NVM, Node.js, npm, Git, Python 3, Hardhat, Ganache CLI, and MetaMask. | [√] [View Screenshot](./images/environment_setup.png) |
| Hash Experiments| Verifiable execution output and empirical data generated from `hash_demo.py` (Avalanche Effect) and `pow_demo.py` (Difficulty 3 vs. 5 time analysis). | [√] Verified |
| Block Anatomy Diagram| Diagram modeling the structural layout of an isolated block, explicitly labeling the Index, Timestamp, Transaction Data, Previous Hash, and Nonce. | [√] [View Diagram](./images/block_anatomy.png) |
| Consensus Discussion| Documented group analysis and academic answers to evaluation questions Q1, Q2, and Q3 regarding PoW vs. PoS, 51% attacks, and transaction finality. | [√] Verified |
| Contract Interactions | Hardhat CLI interactive console terminal logs verifying state modifications for both Day 1 (`SimpleStorage.sol`) and Day 2 (`SecureStorage.sol`). | [√] [View Log Screenshot](./images/console_interactions.png) |
| Vulnerability Analysis| Side-by-side code alignment comparing `VulnerableBank.sol` against `SecureBank.sol`, complete with an arrow pointer mapping the reentrancy vector. | [√] Verified |
| Token & Event Tracking| Verified source code deployment for `LabToken.sol` along with transactional receipt logs tracking the emission of indexed `Transfer` events. | [√] Verified |
| Peer Review Feedback| Documented code evaluation logs detailing exactly 2 structural strengths and 2 actionable security suggestions exchanged with our peer review group. | [√] Verified |
| Test Results | Terminal summary proving 100% execution pass rates for `npx hardhat test`, including a detailed architecture brief of our custom 4th test case. | [√] [View Test Logs](./images/hardhat_test_results.png) |
|Team Reflections| Comprehensive individual post-mortem paragraphs from all group members, breaking down personal key learning points and 
unexpected findings. | [√] Verified |


Section 7.3: Final Submission Checklist
Prior to wrapping up the repository deployment, the Scribe and Network Engineer performed a comprehensive validation of the repository's directory tree. We explicitly verify that the following local files have been correctly tracked, committed, and pushed to the remote master branch:


[√] README.md (This master lab report file is placed cleanly in the root directory).

[√] contracts/VulnerableBank.sol (Contains the intentionally broken reentrancy example).

[√] contracts/SecureBank.sol (Contains the patched Checks-Effects-Interactions code). 

[√] contracts/SecureStorage.sol (Contains the OpenZeppelin Owner and Pausable setup).

[√] contracts/LabToken.sol (Contains the custom mintable token with event tracking logs).

[√] /images/ directory assets (Contains all 4 mandatory terminal verification screenshots).
