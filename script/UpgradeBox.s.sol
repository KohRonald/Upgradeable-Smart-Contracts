// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {BoxV1} from "src/BoxV1.sol";
import {BoxV2} from "src/BoxV2.sol";

contract UpgradeBox is Script {
    function run() external returns (address) {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);

        vm.startBroadcast();
        BoxV2 newBox = new BoxV2(); //Deploys BoxV2 implementation
        vm.stopBroadcast();

        address proxy = upgradeBox(mostRecentlyDeployed, address(newBox)); //Upgrading our proxy to point towards the new implementation
        return proxy;
    }

    /**
     * @param proxyAddress Takes the proxy address that takes reference from implementation contracts
     * @param newBoxImplementation Takes the new deployed box contract address
     * @return address Returns the address of the proxy
     */
    function upgradeBox(address proxyAddress, address newBoxImplementation) public returns (address) {
        vm.startBroadcast();
        BoxV1 proxy = BoxV1(proxyAddress); //We cast proxy address with BoxV1 abi, as the proxy itself does not have any functions
        proxy.upgradeToAndCall(address(newBoxImplementation), ""); //Here upgrades the proxy to point to the new implementation, this is possible because the BoxV1 contract has the UUPSUpgradeable import
        vm.stopBroadcast();
        return address(proxy);
    }
}
