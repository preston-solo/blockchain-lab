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
