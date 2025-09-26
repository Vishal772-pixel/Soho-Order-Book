# SohoLite Orderbook Protocol

## Overview
SohoLite is a lightweight decentralized orderbook protocol for ERC20 token trading. Users deposit tokens into a secure Vault and submit signed orders. Off-chain matching engine finds mirrored orders, and SohoLite settles trades on-chain safely.

## Features
- Vault for secure token storage
- Order validation & settlement with SohoLite.sol
- EIP712 signature verification for gasless order signing
- Fee management with configurable fee recipient
- Event-driven updates for frontend integration
- Compatible with off-chain order matching engines

## Tech Stack
- Solidity (0.8.x)
- Foundry (smart contract development & testing)
- OpenZeppelin Contracts (`IERC20`, `Ownable`, `ReentrancyGuard`)
- React + TypeScript (frontend)
- Ethers.js (web3 interaction)
- Node.js / TypeScript (off-chain matching engine)

## Folder Structure
