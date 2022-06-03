# Overview
## Label Contract
Label contract is, in essence, the on-chain database of labels for audited NFT collections. It is designed to hold all the NFT collections, the label values of each NFT collection, and the proof of those labels for the NFT collection. For example, it would hold the address of the Vigilante NFT collection, 1 for “Commit-Reveal” Label, and a pointer (ex. an IPFS link) to the proof of commit-reveal for the Vigilante NFT collection.
## Filter Factory Contract
Filter Factory contract is designed to create and hold “filters” or selections of labels that a user will deem relevant for their use case. APIs, users, or other contracts can interact directly with this contract to determine if a NFT collection meets their filter criteria.
## Filter Contract
Filter Contract is where APIs, users, or contracts interact directly with this contract to determine if a NFT collection meets this particular filter’s criteria.
## Overall notes
- Throughout these contracts, you will see the label values and filters in the form of a uint256. This is because we are treating the uint256 as simply an array of booleans, where the 0th place bool pertains to label 0 (let’s say, level of gas fees), the first place bool pertains to label 1 (let’s say, uniformity of rarity map distribution), etc. The label ↔ index assignment follows the order in which label types are added to the label contract.
- v1 does not include the consensus mechanisms (where auditors and agree/disagree, and validators confirm the audit). That will be added later. Ergo, in order to audit an NFT collection through these contracts, you must be a whitelisted auditor (see Label Contract).
