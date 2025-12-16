// SPDX-License-Identifier: MIT

// Be sure to check out solidity-by-example
// https://solidity-by-example.org/delegatecall

pragma solidity ^0.8.19;

// NOTE: Deploy this contract first
contract B {
    // NOTE: storage layout must be the same as contract A
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract A {
    uint256 public num;
    address public sender;
    uint256 public value;

    // We are utilising contract B's setVars(), doing what the function has implemented, but storing the data into contract A's storage slots
    // Think of it as borrowing the function
    // Storage layout must be same, as it stores the values in the same indexed storage slots as contract B's
    // If no variables declared, the values set will be stored in the exact same storage slots
    // If declared variable are not same type, then weird unexpected results will appear
    // eg. If first variable is a boolean, then on calling setVars(), if _num is 0 it will be false, if _num is any other number it will be true
    function setVars(address _contract, uint256 _num) public payable {
        // A's storage is set, B is not modified.
        // (bool success, bytes memory data) = _contract.delegatecall(
        (bool success,) = _contract.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
        if (!success) {
            revert("delegatecall failed");
        }
    }
}
