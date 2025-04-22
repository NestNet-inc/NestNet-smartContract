
# 🏗️ NestNet Cairo Contracts

**Smart Contracts for NestNet – A Decentralized Real Estate Co-Ownership Platform**

NestNet transforms real estate by enabling shared home ownership through tokenized contributions. These Cairo smart contracts handle everything from secure token issuance and rental income distribution to progress tracking and co-ownership enforcement on StarkNet.

---

## ✨ Smart Contract Features

- 🪙 **Tokenized Ownership**: Ownership shares issued based on user contributions  
- 💸 **Rental Income Logic**: Automated rental distribution to investors  
- 🛠 **Milestone & Construction Tracking**: Fund release only after verified progress  
- 🔄 **Share Tradability**: Enable secondary market support for ownership tokens  
- 🔐 **Cairo/StarkNet Security**: Zero-knowledge proof-based architecture for scalability and transparency  
- 🧾 **NFT Identity & Reputation**: Link profiles to trustworthy creators and funders  

---

## 🧱 Tech Stack

- **Cairo** – Smart contract language for StarkNet
- **StarkNet** – Layer 2 ZK-Rollup for secure scalability
- **Scarb** – Cairo package manager and build tool
- **snforge** – Testing framework for StarkNet smart contracts
- **Starkli** – CLI for StarkNet interactions

---

## 📦 Project Structure

```
nestnet-contracts/
├── src/
│   ├── main.cairo           # Entry point
│   ├── ownership.cairo      # Logic for token shares and co-ownership
│   ├── rental.cairo         # Income and rent sharing logic
│   └── utils.cairo          # Helper functions and common logic
├── tests/
│   └── ownership_test.cairo # Unit and integration tests
├── Scarb.toml               # Project manifest
```

---

## ⚙️ Getting Started

### 1. Install Dependencies

Install [Scarb](https://docs.swmansion.com/scarb/) and [Starknet CLI](https://book.starknet.io/ch01-01-installation.html) first.

Then, clone the project:
```bash
git clone https://github.com/your-username/nestnet-contracts.git
cd nestnet-contracts
```

---

## 🔨 Common Commands

### 🧱 Build the Contracts
```bash
scarb build
```

### 🎯 Run Tests
```bash
snforge test
```

### 🧹 Format the Code
```bash
scarb fmt
```

### 📦 Add Dependencies
```bash
scarb add <package-name>
```

---

## 🧪 Example Test Run Output

```bash
[PASS] test_token_minting
[PASS] test_rent_distribution
[SUCCESS] All tests passed.
```

---

## 🧰 Useful Cairo/StarkNet Tools

- [Scarb Documentation](https://docs.swmansion.com/scarb/)
- [Cairo Book](https://book.cairo-lang.org/)
- [StarkNet Book](https://book.starknet.io/)
- [snforge](https://github.com/foundry-rs/starknet-foundry)

---

## 🤝 Contributing

We welcome contributors! Open issues, suggest improvements, or create pull requests to enhance the logic and test coverage.

---

## 📄 License

MIT License © 2025 NestNet Labs

---

> **Built with Cairo. Powered by Community. Nest your future in code.**

