// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "script/DeployBox.s.sol";
import {UpgradeBox} from "script/UpgradeBox.s.sol";
import {BoxV1} from "src/BoxV1.sol";
import {BoxV2} from "src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public owner = makeAddr("owner");

    address public proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run(); //Proxy now points to BoxV1 as it deploys it on DeployBox contract
    }

    function testProxyStartsAtBoxV1() public {
        vm.expectRevert();

        //We wrap with BoxV2 abi as BoxV1 does not have the setNumber() function
        //If wrapping with BoxV1 abi, the code would not even compile
        //This would revert as before upgrade, BoxV1 does not have this function
        //The revert will be "unrecognized function selector"
        BoxV2(proxy).setNumber(11);
    }

    function testUpgrades() public {
        BoxV2 box2 = new BoxV2();
        upgrader.upgradeBox(proxy, address(box2));
        uint256 expectedValue = 2;

        //In the second parameter, we cast proxy address with BoxV2 abi, as the proxy itself does not have any functions
        assertEq(expectedValue, BoxV2(proxy).version());

        BoxV2(proxy).setNumber(11);
        assertEq(11, BoxV2(proxy).getNumber());
    }
}
