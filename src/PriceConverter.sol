// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //This function will return the current price of ETH in terms of USD
        //Address ETH/USD: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); Line commented out, as it was hard-coded
        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 _ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        //This function will convert the ETH amount into it's USD value
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (_ethAmount * ethPrice) / 1e18;
        return ethAmountInUsd;
    }

    // function getVersion() public view returns (uint256) {
    //     return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    // }

    // function getDecimals() public view returns(uint8){
    //     uint8 priceFeed = AggregatorV3Interface.decimals();
    // }
}
