//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        // Mock
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // Deploy a 'FundMe' contract using the Sepolia ETH/USD price feed
        vm.stopBroadcast();
        return fundMe;
    }
}
