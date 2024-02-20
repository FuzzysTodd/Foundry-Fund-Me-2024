// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; // The minimum value funders can fund is five USD worth of ETH

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    address private immutable i_ownerOfFundMeContract; // This variable stores the address of the deployer of the contract (the owner)

    AggregatorV3Interface private s_priceFeed; // This variable stores the price feed address

    constructor(address priceFeed) {
        i_ownerOfFundMeContract = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // When calling this function, users will be able to send funds to the 'FundMe' contract
        // For the transaction to go through, users that want to fund must send at least the equivalent of 5 USD worth of ETH
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "It is required to send at least 5 USD worth of ETH."
        );
        s_funders.push(msg.sender); // Updates the array that holds the funders with whomever call the 'fund' function
        s_addressToAmountFunded[msg.sender] += msg.value; // This is one way to say that 'something' is equal to 'something' plus 'another thing'
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwnerCanCallThisFunction {
        uint256 fundersLength = s_funders.length;

        for (uint256 fundersIndex = 0; fundersIndex < fundersLength; fundersIndex++) {
            address funder = s_funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed.");
    }

    function withdraw() public onlyOwnerCanCallThisFunction {
        for (uint256 fundersIndex = 0; fundersIndex < s_funders.length; fundersIndex++) {
            address funder = s_funders[fundersIndex]; // This is how we access to each address of the funder at each index of the array
            s_addressToAmountFunded[funder] = 0; // This is how we reset the 'addressToAmountFunded', by sticking the address that we got above into the mapping and reset the amount that they sent us to zero
        }
        s_funders = new address[](0); // The array is resetted after all it's elements were looped through

        // // Three ways of sending blockchain native tokens.
        // // transfer
        // payable(msg.sender).transfer(address(this).balance); // This is how we get the balance of our contract. The 'this' keyword refers to the whole contract. 'msg.sender' is of type address, while if we type cast 'payable(msg.sender)' is of type payable address. The person that calls this function gets transfered to his address the balance of the contract
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed.");
        // // call

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed.");
    }

    modifier onlyOwnerCanCallThisFunction() {
        // (msg.sender == i_ownerOfFundMeContract, "Only the owner of the contract can call this function.");
        if (msg.sender != i_ownerOfFundMeContract) {
            revert FundMe__NotOwner();
        }
        _;
    }

    // In case someone sends this contract ETH without calling 'fund':

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure functions (Getters)
     *
     */
    function getAddressToAmountFunded(address _fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[_fundingAddress];
    }

    function getFunder(uint256 _index) external view returns (address) {
        return s_funders[_index];
    }

    function getOwner() external view returns (address) {
        // This getter function is used in the 'testWithdrawWithASingleFunder' test
        return i_ownerOfFundMeContract;
    }
}
