# LoanMachine Smart Contract

The `LoanMachine` contract is a simple smart contract that simulates a loan agreement between a borrower and a lender. It involves the following key features:

## Contract Overview

- **States:** The contract has three possible states for the loan:
  - `PENDING`: The loan has been initiated but not funded yet.
  - `ACTIVE`: The loan has been funded by the lender and is now live.
  - `CLOSED`: The loan has been repaid by the borrower, completing the agreement.

- **Key Variables:**
  - `amount`: The principal amount of the loan.
  - `borrower`: The address of the person borrowing money.
  - `lender`: The address of the person lending money.
  - `interest`: The interest to be paid by the borrower along with the loan amount.
  - `duration`: The loan duration in seconds.
  - `end`: The timestamp indicating when the loan is due (calculated as the current time + loan duration).

## Constructor

The constructor is called when the contract is deployed. It initializes the loan details:
- `_amount`: The loan principal.
- `_borrower`: The address of the borrower.
- `_lender`: The address of the lender.
- `_interest`: The interest rate (in wei).
- `_duration`: The loan duration in seconds.

The `end` timestamp is calculated based on the duration, and the contract is initially in the `PENDING` state.

## Functions

### `fund()`

This function allows the lender to fund the loan. The lender sends the exact loan amount to the contract:
- **Conditions:**
  - Only the lender can call this function.
  - The contract's balance must match the loan amount.
- Once these conditions are met, the contract transitions to the `ACTIVE` state, and the loan amount is transferred to the borrower.

### `reimburse()`

This function allows the borrower to repay the loan:
- **Conditions:**
  - Only the borrower can call this function.
  - The borrower must repay the exact loan amount plus interest.
- After the payment is made, the contract transitions to the `CLOSED` state, and the lender receives the amount plus interest.

### `_transitionTo(State to)`

This internal function handles state transitions:
- Ensures that the contract doesn't revert to a previous state (i.e., you can't go from `ACTIVE` back to `PENDING`).
- Handles the logic for moving from `PENDING` to `ACTIVE` or from `ACTIVE` to `CLOSED`.
- The `ACTIVE` state can only be reached from `PENDING`, and the `CLOSED` state can only be reached from `ACTIVE`. Additionally, the loan must be matured (i.e., the current timestamp must be greater than or equal to the `end` timestamp) before it can be closed.

## Usage Flow

1. **Deployment:** The contract is deployed with the loan details.
2. **Funding:** The lender calls `fund()` to send the loan amount to the borrower, transitioning the contract to the `ACTIVE` state.
3. **Repayment:** The borrower repays the loan (loan amount + interest) by calling `reimburse()`, transitioning the contract to the `CLOSED` state.

## Example

```solidity
LoanMachine loan = new LoanMachine(1000, borrowerAddress, lenderAddress, 50, 3600); // Loan of 1000, 50 interest, 1 hour duration
loan.fund(); // Lender funds the loan
loan.reimburse{value: 1050}(); // Borrower repays the loan + interest
