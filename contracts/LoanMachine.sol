// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract LoanMachine {
    enum State {
        PENDING,
        ACTIVE,
        CLOSED
    }

    State public state = State.PENDING;
    uint public amount;
    address payable public borrower;
    address payable public lender;
    uint public interest;
    uint public duration;
    uint public end;

    constructor(
        uint _amount,
        address payable _borrower,
        address payable _lender,
        uint _interest,
        uint _duration
    )
    payable 
    {
        amount = _amount;
        borrower = _borrower;
        lender = _lender;
        interest = _interest;
        duration = _duration;
        end = block.timestamp + duration;
    }

    function fund() public payable {
        require(msg.sender == lender, "Only lender can fund");
        require(address(this).balance == amount, "Amount must match the exact balance");
        _transitionTo(State.ACTIVE);
        borrower.transfer(amount);
    }

    function reimburse() public payable {
        require(msg.sender == borrower, "Only borrower can reimburse");
        require(msg.value == amount + interest, "Borrower must reimburse exactly amount + interest");
        _transitionTo(State.CLOSED);
        lender.transfer(amount + interest);
    }

    function _transitionTo(State to) internal {
        require(to != State.PENDING, "Cannot go back to pending");
        require(to != state, "Cannot transition to the same state");

        if (to == State.ACTIVE) {
            require(state == State.PENDING, "Can only go to active from pending");
            state = State.ACTIVE;
            end = block.timestamp + duration;
        }

        if (to == State.CLOSED) {
            require(state == State.ACTIVE, "Can only go to closed from active");
            require(block.timestamp >= end, "Loan hasn't matured yet");
            state = State.CLOSED;
        }
    }
}
