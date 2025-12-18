// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UUPSUpgradeable} from "@openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

/**
 * @title An upgradeable smart contract
 * @author Ronald Koh
 * @notice UUPSUpgradeable is an abstract class. This means that the undundefined functions in UUPSUpgradeable.sol has to be defined here in the inherited contract.
 * @dev Implementation contract can never have a constructor, all initializing of storage variable can only be done in the proxy contract as storage is stored in the proxy, not the implementation
 * @dev Deploy implementation, call initializer function from openzepplin Initializable.sol, which will be called from the proxy contract
 */
contract BoxV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 internal number;

    /// @custom:oz-upgrades-unsafe-allow constructor
    // The comment above is so that the linter won't warn us that a constructor is not allowed in a UUPSUpgradeable contract
    // The _disableInitializers() is telling the contract explicitly to not do any sort of initializing
    // This is the same as totally not having a constructor function, but this way is more verbose
    constructor() {
        _disableInitializers();
    }

    // Acts as the constructor for the implementation contract
    // Proxy contract will immediatly call this initalize(), which in a way acts as a constructor
    // Able to set storage values here etc.
    function initalize() public initializer {
        //Uses OwnableUpgradeable.sol's __Ownable_init() to set deployer of contract as owner
        __Ownable_init(msg.sender); // function is prepended with __ which defines it as an initalizer function
    }

    function getNumber() external view returns (uint256) {
        return number;
    }

    function version() external pure returns (uint256) {
        return 1;
    }

    //This function is taken from UUPSUpgradeable.sol, the function that is to be defined here.
    //We change virtual to override, we do not set anything in the function as we do not want any authorisation
    function _authorizeUpgrade(address newImplementation) internal override {}
}
