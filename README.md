## Upgradeable Smart Contracts

- Allows for
  - Smart Contract Upgrade (Protocol enhancements)
  - Bug Fixes
- Consider the philosophy and decentralised implications when choosing a pattern for upgrade
- Should deploy as little as possible, not defaulting as upgradeable SC

## 3 Ways to upgrade
1. Parameterization (Not really upgrading method)
2. Social Migration
3. Proxy


### 1. Parameterization (Not really upgrading method)
- Can't add new logic
- Can't add new state or storage variables
- Parameterizing everything, setter functions for most/all variables

#### Pros
- Simple to deploy

#### Cons
- Centralised (If single person is the one that can change the parameters)
  - However, can be negated with governance contract as the admin of the protocol
- Not flexible
- Missing logic/functionality on deployment, means the SC would not have them

### 2. Social Migration
- Deploy new contract, not related to old contract
- Migrating the utilisation of the old contract to the new one
- Aka. Telling people to use the new contract

#### Pros
- Will always be an immutable Smart Contract
- True to blockchain values

#### Cons
- Lot of work to convince users to move (Eg. Convince exchanges to update your ERC20 token address)
- Different addresses
- Need to move all the state exactly over to the new contract (mapping, txn calls, etc.)
- Ton of social convention work

### 3. Proxy
- Proxies are the truest form of programtic upgrades
- Users can continue interacting with the smart contract via the Proxies without noticing any changes
- Proxies uses alot of low level call functionality
  - delegateCall() - A low level function where the code in the target contract is executed in the context of the calling contract
  - Eg:
  ```
  //Contract A
  function doDelegateCall() {
    callContractB(setValues())
  }

  //Contract B
  uint256 public value;
  function setValue(uint256 _value) {
    value = _value;
  }

  //The value is set in contract A
  ```
  - Does contract B logic in contract A
  - All storage variables are stored in the proxy contract and not the implementation contract
    - There is no need to move storage variables when upgrading the implementation contract
    - On adding new storage variables in implementation contracts, the proxy will pick those variables up and store them on the proxy contract
- This means that 1 Proxy address that has the same address forever, will point and route people to the correct implementation contract that has the logic
- When an upgrade is needed, the new implementation contract is deployed, and the proxy will then point towards that new implemented contract
- The proxy contract would have an admin only function to update the pointer to the latest/newest implemented contract
  - Eg.
  ```
  function upgrade(address newImplementation) external {
    if (msg.sender != admin) fallback();
    implementation = newImplementation;
  }
  ```
  #### Proxy Terminology
  1. The implementation Contract
     - Which has all the code of the protocol
     - When upgrading, a brand new implementation contract is launched
  2. The proxy contract
     - Points to which implementation is the 'correct' one, and routes everyone's function calls to that contract
  3. The user
      - They make calls to the proxy
  4. The admin
      - The user (or group of users/voters) who upgrade to new implementation contracts.

#### Gotchas of Proxies
- Storage clashes
  - Functions only points to storage spots in solidity, not to value names
- Function Selector Clashes
  - A 4 bytes hash of a function (name + function sig)
  - It is possible that a function in the implementation contract has the same function selector with an admin function in the proxy contract

### Proxy Implementations Patterns
1. Transparent Proxy Pattern
   - Admins are only allowed to call admin functions
   - Admin functions are located in the proxy contract
   - Admin functions are functions that govern the upgrades
   - Users can only call functions in the implementation contract
   - Prevents function selector clashing
2. Universal Upgradeable Proxies (UUPS)
   - Put all the logic of upgrading in the implementation contract
   - AdminOnly upgrade functions are in the implementation contracts instead of the proxy
   - Saves Gas, no need to check in the proxy contract if someone is an admin or not
   - Proxy contracts will be smaller
   - However, if deploying an implementation contract without any upgradeable functionality, then there is nothing you can do.
3. Diamond Pattern
   - Allows for multiple implementation contract
   - If a contract is too big to be implemented in a single contract, and requires multiple implementation, this pattern will be able to read multiple contracts
   - Allows for more granular upgrades (smaller upgrades)
     - Upgrade a singular contract out of all the multiple implemented contracts


## EIP-1967 (Standard Proxy Storage Slots)
- To have certain storage slots specifically used for proxies 

## Reference
* [Cyfrin Updraft Foundry UUPS Upgradeable Contracts](https://github.com/Cyfrin/foundry-upgrades-cu)*