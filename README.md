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












4.1  Day 2 ROLE ROTATION CONFIGURATION

As mandated by the laboratory deployment rules, the group roles have been rotated clockwise for Day 2:

| Day 1 Role | Day 2 Role | Assigned Team Member (GitHub Username / Name) |
| :--- | :--- | :--- |
| Security Analyst |  Scribe / Documenter | Nkembeni Dabrat |
| Scribe / Documenter |  Lead Developer | Precious |
| Lead Developer |  QA Tester | Preston |
| QA Tester |  Network Engineer| Wells Durk |
| Network Engineer |  Security Analyst| Loise|
  



Session 4.2 - Reentrancy Vulnerability Lab

Exercise 4.2.1 – Vulnerability Identification (`VulnerableBank.sol`)
Scribe Note: This section has been pre-staged by the Scribe to outline the security mechanics of the vulnerability. Real-time compilation and verification metrics will be appended once the Lead Developer deploys the environment.

1. Identified Code Flaw
In the provided `VulnerableBank.sol` contract, the vulnerability resides within the withdrawal tracking logic:
```solidity
// UNSAFE: The external contract call happens BEFORE the balance state is updated
(bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
balances[msg.sender] = 0;

2. Threat Vector Explanation

The Exploit Mechanism: The contract uses msg.sender.call to send Ether back to the user before changing their tracking balance inside the database mapping to 0.

The Attack Path: Because execution control shifts to the calling address before the contract updates its internal storage ledger, a malicious actor can deploy an attacking fallback contract. When the bank sends the funds, the attacker's fallback function intercepts the execution loop and immediately triggers another withdrawal request (withdraw()).

The Result: The bank contract checks the balance again, sees it hasn't been zeroed out yet, and sends more Ether. This recursive reentrancy loop continues back and forth until the entire smart contract balance pool is completely drained.


Exercise 4.2.2 – Security Pattern Implementation (SecureBank.sol)

1. Remediation Strategy
To fix this vulnerability, the team implements the Checks-Effects-Interactions architectural pattern. This pattern mandates that all internal blockchain state modifications must occur before interacting with external addresses.

function withdraw() public {
    // 1. CHECKS: Verify the user has enough collateral
    uint256 amount = balances[msg.sender];
    require(amount > 0, "Insufficient balance.");

    // 2. EFFECTS: Update the state variable internal ledger FIRST
    balances[msg.sender] = 0;

    // 3. INTERACTIONS: Safely perform the external transfer
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed.");
}


2. Architectural Value
By switching the order of execution, if an attacker attempts to call withdraw() recursively during the interaction phase, the execution thread hits the Checks phase first. Because the state Effect already ran and set balances[msg.sender] = 0, the second execution thread immediately reverts, successfully defeating the reentrancy attack vector.


