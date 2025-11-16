# Blockchain_hack_2025
## Problem
The modern food supply chain involves multiple independent participants—farmers, transporters, distributors, and retailers—making it difficult to ensure data integrity, traceability, and accountability. Traditional databases are prone to tampering and lack transparency.

## Insight
This project proposes a blockchain-based logistics management system that leverages Ethereum smart contracts and batch-specific identifiers to maintain immutable, verifiable records of food batches from production to sale.

## Solution
Each food batch is assigned a unique Batch ID, and all key supply-chain events (origin, storage, transportation, inspection, sale) are recorded as digitally signed blockchain transactions. Event details and digital signatures are hashed and stored on-chain, ensuring verifiability without revealing sensitive business information.

## Design Document
[Link](https://docs.google.com/document/d/1bog2AQui4eShjtS21RO49hxwGk4EKdFZ3NfUJYoxE6Y/edit?usp=sharing)

[Slides](https://docs.google.com/presentation/d/1-g29KdkvxAPHWy9p5nuA1G-1I0eGXRZ4rBQAMgC5JMA/edit?usp=sharing)
# File Structure 


├── README.md

├── contracts # smart contract

└── FrontEnd #html files

└── js folder

    ── abi.js
    ── app.js
└── solidity

    ── contract.sol

