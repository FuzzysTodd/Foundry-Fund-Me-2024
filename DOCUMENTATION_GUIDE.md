# FundMe Documentation Quick Reference

This quick reference guide helps you navigate the FundMe contract documentation and find what you need quickly.

## 📚 Documentation Files

| Document | Purpose | Best For |
|----------|---------|----------|
| **PROCESSES.md** | Detailed operational procedures and workflows | Developers, DevOps, Operators |
| **USE_CASES.md** | Comprehensive use cases and scenarios | Testers, Auditors, Product Managers |
| **README.md** | Project overview and setup | Getting started, Quick reference |
| **This file** | Navigation and quick lookup | Everyone |

---

## 🚀 Quick Start Guide

### For New Developers
1. Read `README.md` for project overview
2. Review `PROCESSES.md` → "Contract Deployment Process"
3. Study `src/FundMe.sol` to understand the code
4. Run tests: `forge test`
5. Review `USE_CASES.md` for behavior examples

### For Testers
1. Review `USE_CASES.md` → "Test Case Summary"
2. Check edge cases in `USE_CASES.md` → "Edge Cases and Error Handling"
3. Run test suite: `forge test`
4. Generate coverage: `forge coverage`

### For Auditors
1. Review `PROCESSES.md` → "Security Considerations"
2. Study `USE_CASES.md` → "Edge Cases and Error Handling"
3. Check `USE_CASES.md` → UC-17 (Reentrancy)
4. Verify test coverage in `test/` directory
5. Review gas optimization strategies in `PROCESSES.md`

### For Users
1. Read `USE_CASES.md` → "User Funding Use Cases"
2. Understand minimum funding requirement ($5 USD)
3. Review error scenarios to avoid common mistakes
4. Check your contributions: Call `getAddressToAmountFunded(yourAddress)`

### For Contract Owners
1. Review `PROCESSES.md` → "Withdrawal Process"
2. Read `USE_CASES.md` → "Owner Withdrawal Use Cases"
3. Understand the difference between `withdraw()` and `cheaperWithdraw()`
4. Follow deployment checklist before production deployment
5. Set up monitoring per `PROCESSES.md` → "Maintenance and Monitoring"

---

## 🔍 Common Tasks - Quick Lookup

### How do I...

**Fund the contract?**
- Process: `PROCESSES.md` → "Funding Process"
- Use Cases: `USE_CASES.md` → UC-1, UC-2, UC-3
- Code: `src/FundMe.sol` → `fund()` function (line 27)

**Withdraw funds?**
- Process: `PROCESSES.md` → "Withdrawal Process"
- Use Cases: `USE_CASES.md` → UC-5, UC-6
- Code: `src/FundMe.sol` → `withdraw()` or `cheaperWithdraw()` (lines 42, 55)

**Check someone's contribution?**
- Process: `PROCESSES.md` → "Data Query Processes"
- Use Case: `USE_CASES.md` → UC-8
- Code: Call `getAddressToAmountFunded(address)`

**Deploy the contract?**
- Process: `PROCESSES.md` → "Contract Deployment Process"
- Script: `script/DeployFundMe.s.sol`
- Command: `forge script script/DeployFundMe.s.sol`

**Run tests?**
- Process: `PROCESSES.md` → "Testing Procedures"
- Tests: `test/UnitTest/FundMeTest.t.sol`
- Command: `forge test`

**Optimize gas costs?**
- Process: `PROCESSES.md` → "Gas Optimization Notes"
- Use: `cheaperWithdraw()` instead of `withdraw()`
- Savings: ~200-500 gas per funder

---

## 🔑 Key Functions Reference

| Function | Access | Purpose | Documentation |
|----------|--------|---------|---------------|
| `fund()` | Public | Send ETH to contract | PROCESSES.md (Funding Process) |
| `withdraw()` | Owner only | Withdraw all funds | PROCESSES.md (Withdrawal Process) |
| `cheaperWithdraw()` | Owner only | Gas-optimized withdrawal | PROCESSES.md (Withdrawal Process) |
| `getVersion()` | Public | Get price feed version | PROCESSES.md (Price Feed Query) |
| `getAddressToAmountFunded()` | Public | Get funder's total | USE_CASES.md (UC-8) |
| `getFunder()` | Public | Get funder by index | USE_CASES.md (UC-9) |
| `getOwner()` | Public | Get contract owner | USE_CASES.md (UC-10) |
| `receive()` | External | Auto-redirect to fund() | USE_CASES.md (UC-3) |
| `fallback()` | External | Auto-redirect to fund() | USE_CASES.md (UC-16) |

---

## ⚠️ Common Errors & Solutions

| Error | Cause | Solution | Reference |
|-------|-------|----------|-----------|
| "It is required to send at least 5 USD worth of ETH." | Insufficient funding amount | Send more ETH (≥$5 USD) | USE_CASES.md (UC-12) |
| `FundMe__NotOwner()` | Non-owner tried to withdraw | Only owner can withdraw | USE_CASES.md (UC-13) |
| "Call failed." | Transfer failed during withdrawal | Check contract balance and gas | PROCESSES.md (Withdrawal Process) |
| Transaction reverts (no message) | Price feed failure | Wait for oracle recovery | USE_CASES.md (UC-15) |

---

## 📊 Contract Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `MINIMUM_USD` | 5e18 (5 USD) | Minimum funding requirement |
| Price Feed Version | 4 | Expected Chainlink version |
| Solidity Version | ^0.8.18 | Compiler version |

---

## 🛠️ Development Commands

```bash
# Build the project
forge build

# Run all tests
forge test

# Run specific test
forge test --mt testFunctionName

# Generate coverage report
forge coverage

# Generate gas snapshot
forge snapshot

# Deploy to local Anvil
forge script script/DeployFundMe.s.sol

# Deploy to testnet (requires .env setup)
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast

# Fund contract using script
forge script script/Interactions.s.sol:FundFundMe

# Withdraw using script
forge script script/Interactions.s.sol:WithdrawFundMe
```

---

## 🔐 Security Checklist

Before deploying to production, verify:

- [ ] Price feed address is correct for target network
- [ ] Owner private key is secure and backed up
- [ ] All tests pass: `forge test`
- [ ] Gas costs reviewed: `forge snapshot`
- [ ] Security considerations reviewed (PROCESSES.md)
- [ ] Edge cases understood (USE_CASES.md)
- [ ] Reentrancy protection verified (USE_CASES.md UC-17)
- [ ] Error handling tested (USE_CASES.md UC-12 to UC-17)

---

## 📖 Learning Path

**Beginner:**
1. README.md → Project overview
2. PROCESSES.md → Contract Deployment
3. PROCESSES.md → Funding Process
4. Run local tests to see it in action

**Intermediate:**
1. USE_CASES.md → All user funding scenarios
2. USE_CASES.md → Owner withdrawal scenarios
3. Study test files to understand validation
4. Try interaction scripts

**Advanced:**
1. PROCESSES.md → Gas Optimization
2. USE_CASES.md → Edge Cases (UC-12 to UC-17)
3. PROCESSES.md → Security Considerations
4. Review multi-network deployment (USE_CASES.md UC-19)

**Expert:**
1. Audit the entire codebase
2. Review all security considerations
3. Propose improvements (USE_CASES.md → Future Enhancements)
4. Implement and test enhancements

---

## 🌐 External Resources

- **Foundry Documentation:** https://book.getfoundry.sh/
- **Chainlink Price Feeds:** https://docs.chain.link/data-feeds
- **Solidity Documentation:** https://docs.soliditylang.org/
- **Ethereum Development:** https://ethereum.org/developers

---

## 💡 Tips & Best Practices

1. **Always test on testnet first** before mainnet deployment
2. **Use `cheaperWithdraw()`** when withdrawing from many funders
3. **Monitor price feed health** regularly
4. **Keep private keys secure** and never commit them to Git
5. **Run coverage tests** to ensure comprehensive testing
6. **Document any modifications** if you extend the contract
7. **Follow CEI pattern** (Checks-Effects-Interactions) for security
8. **Use `.env` files** for sensitive configuration (add to .gitignore)

---

## 🤝 Contributing

When contributing to this project:

1. Read all documentation first
2. Follow existing code style
3. Add tests for new features
4. Update documentation for any changes
5. Run full test suite before submitting
6. Include gas optimization considerations

---

## 📞 Support

For questions or issues:

1. Check this quick reference first
2. Review relevant sections in PROCESSES.md or USE_CASES.md
3. Check test files for examples
4. Refer to Foundry documentation
5. Review Chainlink documentation for price feed issues

---

## 📝 Document Version

- **Last Updated:** 2026-02-04
- **FundMe Contract Version:** 0.8.18
- **Documentation Status:** Complete and verified

---

**Navigation:**
- 📋 [Process Documentation](PROCESSES.md)
- 📚 [Use Cases](USE_CASES.md)  
- 📖 [Project README](README.md)
- 💻 [Source Code](src/FundMe.sol)
- 🧪 [Tests](test/)
