// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.01 ether; // This is the amount that will be funded when calling 'fund'

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); // Here the 'fund' function is called in the most recently deployed address of the 'FundMe' contract
        vm.stopBroadcast();

        console.log("You funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        // Here will be the main code
        // Important: we want to fund the most recent deployed contract

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); // This is how I get the most recently deployed contract address
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed); // Here the 'fundFundMe' function is called
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw(); // Here the 'withdraw' function is called in the most recently deployed address of the 'FundMe' contract
        vm.stopBroadcast();
    }

    function run() external {
        // Here will be the main code
        // Important: we want to fund the most recent deployed contract

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); // This is how I get the most recently deployed contract address
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed); // Here the 'fundFundMe' function is called
        vm.stopBroadcast();
    }
}
