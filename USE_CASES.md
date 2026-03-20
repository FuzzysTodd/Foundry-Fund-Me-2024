# FundMe Contract Use Cases

This document provides detailed use cases for the FundMe smart contract, including standard operations, edge cases, and error scenarios.

## Table of Contents

1. [User Funding Use Cases](#user-funding-use-cases)
2. [Owner Withdrawal Use Cases](#owner-withdrawal-use-cases)
3. [Query and View Use Cases](#query-and-view-use-cases)
4. [Edge Cases and Error Handling](#edge-cases-and-error-handling)
5. [Integration Use Cases](#integration-use-cases)

---

## User Funding Use Cases

### UC-1: First-Time User Funding

**Actor:** Regular User  
**Goal:** Contribute ETH to the FundMe contract for the first time  
**Preconditions:**
- User has an Ethereum wallet with sufficient ETH
- User has at least $5 USD equivalent in ETH plus gas fees
- Contract is deployed and operational

**Main Flow:**
1. User connects wallet to DApp or prepares transaction
2. User calls `fund()` function with 0.1 ETH
3. Contract converts 0.1 ETH to USD using Chainlink price feed
4. Contract validates amount is ≥ $5 USD
5. Contract adds user's address to funders array
6. Contract records 0.1 ETH in user's funding mapping
7. Transaction succeeds and emits success

**Postconditions:**
- User is added to `s_funders` array at index 0
- `s_addressToAmountFunded[user]` = 0.1 ETH
- Contract balance increases by 0.1 ETH
- User's wallet balance decreases by 0.1 ETH + gas

**Success Probability:** High (assuming sufficient funds and valid price feed)

---

### UC-2: Repeat User Funding

**Actor:** Existing Funder  
**Goal:** Make additional contributions to the contract  
**Preconditions:**
- User has previously funded the contract
- User has sufficient ETH for additional contribution
- Contribution meets minimum USD requirement

**Main Flow:**
1. User calls `fund()` function with 0.05 ETH (second contribution)
2. Contract validates the new contribution meets minimum
3. Contract adds user's address to funders array again
4. Contract increments existing mapping: `s_addressToAmountFunded[user] += 0.05 ETH`
5. Transaction succeeds

**Postconditions:**
- User appears multiple times in `s_funders` array
- `s_addressToAmountFunded[user]` = 0.15 ETH (cumulative)
- Contract balance increases by 0.05 ETH

**Note:** The array tracks each funding event, while the mapping tracks cumulative amounts.

---

### UC-3: Funding via Direct ETH Transfer (receive)

**Actor:** Regular User  
**Goal:** Send ETH directly to contract without calling function  
**Preconditions:**
- User knows the contract address
- User sends ETH via wallet transfer (no function call data)

**Main Flow:**
1. User sends 0.1 ETH directly to contract address
2. Contract's `receive()` function is automatically triggered
3. `receive()` internally calls `fund()`
4. Standard funding logic executes (validation, recording, etc.)
5. Transaction succeeds

**Postconditions:**
- Same as UC-1 (First-Time User Funding)
- User successfully funded despite not calling `fund()` directly

---

### UC-4: Funding via Interaction Script

**Actor:** Developer/Power User  
**Goal:** Fund contract using Foundry interaction script  
**Preconditions:**
- Foundry is installed
- Contract is deployed
- Script has access to funded account

**Main Flow:**
1. Developer runs: `forge script script/Interactions.s.sol:FundFundMe`
2. Script identifies most recently deployed FundMe contract
3. Script calls `fund()` with 0.01 ETH
4. Contract processes funding normally
5. Console logs confirmation

**Postconditions:**
- Contract funded with 0.01 ETH
- Script account becomes a funder
- Transaction logged and confirmed

---

## Owner Withdrawal Use Cases

### UC-5: Owner Withdraws with Single Funder

**Actor:** Contract Owner  
**Goal:** Withdraw all funds when only one user has contributed  
**Preconditions:**
- Owner has deployment private key
- Contract has balance > 0
- Only one funder in array

**Main Flow:**
1. Owner calls `withdraw()` function
2. Contract validates caller is owner via modifier
3. Contract loops through funders array (1 iteration)
4. Contract sets `s_addressToAmountFunded[funder]` = 0
5. Contract resets `s_funders` array to empty
6. Contract transfers entire balance to owner using `call`
7. Transaction succeeds

**Postconditions:**
- Contract balance = 0 ETH
- Owner balance increased by withdrawn amount
- All funder mappings reset to 0
- Funders array is empty
- Funders can fund again if desired

**Gas Cost:** Lower (only one iteration in loop)

---

### UC-6: Owner Withdraws with Multiple Funders

**Actor:** Contract Owner  
**Goal:** Withdraw all funds when multiple users have contributed  
**Preconditions:**
- Contract has 10+ funders
- Total balance accumulated from multiple contributions
- Owner has sufficient gas

**Main Flow:**
1. Owner calls `cheaperWithdraw()` for gas optimization
2. Contract validates owner authorization
3. Contract caches funders array length in memory
4. Contract loops through all 10 funders
5. Contract resets each funder's mapping to 0
6. Contract resets funders array
7. Contract transfers entire balance to owner
8. Transaction succeeds with optimized gas usage

**Postconditions:**
- All funds transferred to owner
- All funder records cleared
- Contract ready for new funding cycle
- Gas costs optimized vs. standard `withdraw()`

**Alternative Flow:**
- Owner could use `withdraw()` instead, with slightly higher gas cost

---

### UC-7: Owner Withdraws via Interaction Script

**Actor:** Contract Owner  
**Goal:** Withdraw funds using Foundry script  
**Preconditions:**
- Owner has private key configured
- Foundry is installed
- Contract has funds to withdraw

**Main Flow:**
1. Owner runs: `forge script script/Interactions.s.sol:WithdrawFundMe`
2. Script identifies most recently deployed contract
3. Script calls `withdraw()` on behalf of owner
4. Withdrawal executes normally
5. Success logged to console

**Postconditions:**
- Funds transferred to owner account
- Contract state reset
- Transaction confirmed on-chain

---

## Query and View Use Cases

### UC-8: Check User's Total Contribution

**Actor:** Anyone (User, DApp, Owner)  
**Goal:** Query how much a specific address has funded  
**Preconditions:**
- User address is known
- Contract is deployed

**Main Flow:**
1. Caller invokes `getAddressToAmountFunded(userAddress)`
2. Contract returns cumulative amount from mapping
3. Caller receives result

**Example:**
```solidity
uint256 amount = fundMe.getAddressToAmountFunded(0x123...);
// Returns: 0.15 ETH (if user funded twice: 0.1 + 0.05)
```

---

### UC-9: Retrieve Funder by Index

**Actor:** DApp Developer, Analyst  
**Goal:** Get funder address at specific array position  
**Preconditions:**
- Index is within array bounds
- Contract has at least one funder

**Main Flow:**
1. Caller invokes `getFunder(0)` to get first funder
2. Contract returns address at index 0
3. Caller can iterate through all funders

**Example:**
```solidity
address firstFunder = fundMe.getFunder(0);
address secondFunder = fundMe.getFunder(1);
```

**Error Case:** Index out of bounds → transaction reverts

---

### UC-10: Verify Contract Owner

**Actor:** Anyone  
**Goal:** Confirm who owns the contract  
**Preconditions:**
- Contract is deployed

**Main Flow:**
1. Caller invokes `getOwner()`
2. Contract returns `i_ownerOfFundMeContract` (immutable)
3. Caller verifies ownership

**Use Cases:**
- DApp displays owner address
- Verification before trusting contract
- Audit and transparency

---

### UC-11: Check Price Feed Version

**Actor:** Developer, Auditor  
**Goal:** Verify Chainlink price feed is operational  
**Preconditions:**
- Contract is deployed with valid price feed

**Main Flow:**
1. Caller invokes `getVersion()`
2. Contract queries Chainlink price feed
3. Returns version number (expected: 4)

**Postconditions:**
- Version confirmed
- Price feed validated as operational

---

## Edge Cases and Error Handling

### UC-12: Insufficient Funding Amount

**Actor:** User  
**Scenario:** User attempts to fund with less than $5 USD worth of ETH  
**Preconditions:**
- User sends 0.001 ETH (below minimum)
- Current ETH price makes this < $5 USD

**Flow:**
1. User calls `fund()` with 0.001 ETH
2. Contract calculates USD value using price feed
3. Validation fails: `msg.value.getConversionRate() < MINIMUM_USD`
4. Transaction reverts with error message
5. User's ETH is not spent (except gas for failed transaction)

**Error Message:**
```
"It is required to send at least 5 USD worth of ETH."
```

**Resolution:** User must send more ETH to meet minimum requirement

---

### UC-13: Unauthorized Withdrawal Attempt

**Actor:** Non-Owner User  
**Scenario:** Regular user tries to withdraw funds  
**Preconditions:**
- User is not the contract owner
- User attempts to call `withdraw()`

**Flow:**
1. Non-owner calls `withdraw()`
2. Modifier `onlyOwnerCanCallThisFunction` checks `msg.sender`
3. Check fails: `msg.sender != i_ownerOfFundMeContract`
4. Contract reverts with custom error
5. Transaction fails

**Error:**
```solidity
FundMe__NotOwner()
```

**Resolution:** Only owner can withdraw; user should not attempt this

---

### UC-14: Withdrawal with Zero Balance

**Actor:** Contract Owner  
**Scenario:** Owner attempts withdrawal when contract has no funds  
**Preconditions:**
- Contract balance = 0 ETH
- Owner calls `withdraw()`

**Flow:**
1. Owner calls `withdraw()`
2. Authorization passes
3. Loop executes (possibly over empty array)
4. Transfer attempted with 0 value
5. Transfer succeeds (transferring 0 ETH is valid)
6. Transaction succeeds with no effect

**Postconditions:**
- No state changes (already empty)
- Gas consumed for transaction

**Note:** This is not an error; contract handles it gracefully

---

### UC-15: Price Feed Failure

**Actor:** User  
**Scenario:** Chainlink price feed is unavailable or returns invalid data  
**Preconditions:**
- Price feed oracle is down or malfunctioning
- User attempts to fund

**Flow:**
1. User calls `fund()` with sufficient ETH
2. Contract calls `getConversionRate(s_priceFeed)`
3. Price feed call fails or returns invalid data
4. Transaction reverts at price feed level
5. Funding fails

**Impact:** Contract is temporarily unusable until price feed recovers

**Mitigation:** 
- Use reliable Chainlink feeds
- Monitor feed health
- Consider implementing fallback price sources in future versions

---

### UC-16: Fallback Function Triggered

**Actor:** User or Smart Contract  
**Scenario:** ETH sent to contract with unrecognized function call  
**Preconditions:**
- Sender calls invalid function or sends data that doesn't match any function

**Flow:**
1. Sender calls non-existent function with ETH
2. Contract's `fallback()` function is triggered
3. `fallback()` redirects to `fund()`
4. Normal funding logic executes
5. Transaction succeeds if amount is sufficient

**Postconditions:**
- User successfully funded despite calling wrong function
- Contract is forgiving of incorrect function calls

---

### UC-17: Reentrancy Attack Attempt

**Actor:** Malicious Contract  
**Scenario:** Attacker tries to exploit withdrawal via reentrancy  
**Preconditions:**
- Attacker has a malicious contract as a funder
- Attacker's contract has malicious `receive()` or `fallback()`

**Flow:**
1. Owner calls `withdraw()`
2. Contract clears funder mappings and array
3. Contract calls `attacker.call{value: ...}()`
4. Attacker's `receive()` tries to call `withdraw()` again
5. Second withdrawal attempt finds 0 balance
6. Attack fails

**Why It's Safe:**
- State is cleared BEFORE external call
- CEI pattern (Checks-Effects-Interactions) partially followed
- Balance is already transferred

**Note:** Contract could be improved by fully following CEI pattern

---

## Integration Use Cases

### UC-18: DApp Integration

**Actor:** Frontend Developer  
**Goal:** Integrate FundMe with web3 DApp  
**Flow:**
1. DApp connects to user's MetaMask wallet
2. DApp displays contract balance and funders
3. User clicks "Fund" button
4. DApp calls `fund()` with user-specified amount
5. Transaction prompt appears in MetaMask
6. User confirms and transaction executes
7. DApp updates UI with new balance

**Required Functions:**
- `fund()` for contributions
- `getAddressToAmountFunded()` to display user's total
- Contract balance to show total raised

---

### UC-19: Multi-Network Deployment

**Actor:** DevOps Engineer  
**Goal:** Deploy contract to multiple networks  
**Preconditions:**
- HelperConfig properly configured
- RPC URLs and private keys available

**Flow:**
1. Deploy to local Anvil for testing
2. Run tests to verify functionality
3. Deploy to Sepolia testnet with real price feed
4. Verify deployment and test transactions
5. Deploy to mainnet with production price feed
6. Monitor and verify production deployment

**Configurations:**
- Local: Mock price feed
- Sepolia: 0x694AA1769357215DE4FAC081bf1f309aDC325306
- Mainnet: Production Chainlink feed

---

### UC-20: Continuous Monitoring

**Actor:** Contract Owner/Maintainer  
**Goal:** Monitor contract health and usage  
**Metrics to Track:**
- Total funds raised
- Number of unique funders
- Average contribution size
- Withdrawal history
- Price feed accuracy
- Gas costs for operations

**Tools:**
- Block explorer (Etherscan)
- Custom monitoring scripts
- Chainlink feed monitoring
- Gas price trackers

---

## Test Case Summary

Based on existing test suite:

✅ **Covered Use Cases:**
- UC-1: First-time funding (testFundUpdatesFundedDataStructure)
- UC-2: Repeat funding (testFunderIsAddedToArrayOfFunders)
- UC-5: Single funder withdrawal (testWithdrawWithASingleFunder)
- UC-6: Multiple funder withdrawal (testWithdrawFromMultipleFunders)
- UC-8: Query contributions (implicit in tests)
- UC-10: Verify owner (testOwnerIsMsgSender)
- UC-11: Price feed version (testPriceFeedVersionIsAccurate)
- UC-12: Insufficient funding (testFundFailsWhenNotEnoughEthIsSent)
- UC-13: Unauthorized withdrawal (testOnlyOwnerCanWithdraw)
- UC-18: DApp integration (testUserCanFundInteractions)

✅ **Gas Optimization:**
- cheaperWithdraw tested and verified

---

## Future Enhancements

Potential use cases for future versions:

1. **UC-21: Partial Withdrawals**
   - Allow owner to withdraw specific amounts instead of all funds

2. **UC-22: Funder Refunds**
   - Allow funders to request refunds before owner withdrawal

3. **UC-23: Multiple Owners**
   - Support multi-signature wallet ownership

4. **UC-24: Funding Deadlines**
   - Time-based fundraising campaigns

5. **UC-25: Funding Goals**
   - Target amounts with refund if not reached

6. **UC-26: Emergency Pause**
   - Circuit breaker for emergency situations

---

## Conclusion

This use case document covers all standard operations, edge cases, and error scenarios for the FundMe contract. It serves as a reference for developers, testers, auditors, and users to understand the contract's behavior in various situations.

For implementation details, refer to:
- Source code: `src/FundMe.sol`
- Tests: `test/UnitTest/FundMeTest.t.sol`
- Integration: `test/IntegrationTest/FundMeTestIntegration.t.sol`
- Processes: `PROCESSES.md`
