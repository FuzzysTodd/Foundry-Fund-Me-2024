// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig; // This variable will be set up to the chain id that is being used

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // This is the initial price that we set for the mock price feed

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthUsdConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthUsdConfig();
        } else if (block.chainid == 42161) {
            activeNetworkConfig = getArbitrumMainnetEthUsdConfig();
        } else if (block.chainid == 421614) {
            activeNetworkConfig = getArbitrumSepoliaEthUsdConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthUsdConfig() public pure returns (NetworkConfig memory) {
        // This function will allow me to get the sepolia ETH/USD price feed
        // This function will retrun an object of type NetworkConfig
        // The NetworkConfig object is composed by a 'priceFeed' address
        NetworkConfig memory sepoliaEthUsdConfig =
            NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306}); // Included the price feed address for Sepolia ETH/USD
        return sepoliaEthUsdConfig;
    }

    function getMainnetEthUsdConfig() public pure returns (NetworkConfig memory) {
        // This function will allow me to get the mainnet ETH/USD price feed
        NetworkConfig memory mainnetEthUsdConfig =
            NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetEthUsdConfig;
    }

    function getArbitrumSepoliaEthUsdConfig() public pure returns (NetworkConfig memory) {
        // This function will allow me to get the mainnet ETH/USD price feed
        NetworkConfig memory arbitrumSepoliaEthUsdConfig =
            NetworkConfig({priceFeed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165});
        return arbitrumSepoliaEthUsdConfig;
    }

    function getArbitrumMainnetEthUsdConfig() public pure returns (NetworkConfig memory) {
        // This function will allow me to get the mainnet ETH/USD price feed

        NetworkConfig memory arbitrumMainnetEthUsdConfig =
            NetworkConfig({priceFeed: 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612});
        return arbitrumMainnetEthUsdConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // This function will allow me to get an Anvil ETH/USD price feed
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilEthUsdConfig = NetworkConfig({priceFeed: address(mockV3Aggregator)});
        return anvilEthUsdConfig;
    }
}
