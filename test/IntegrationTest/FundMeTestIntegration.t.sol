// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // This user will be used for the tests

    uint256 constant SEND_VALUE = 0.1 ether; // This is the value that the user will send to the contract

    uint256 constant STARTING_BALANCE = 10 ether; // This is the starting balance of the user created

    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe(); // Create a new object of type 'FundFundMe'
        fundFundMe.fundFundMe(address(fundMe)); // Call 'fundFundmE'. With this line the funding is being done using the 'Interactions' script

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe(); // Create a new object of type 'WithdrawFundMe'
        withdrawFundMe.withdrawFundMe(address(fundMe)); // Call 'withdrawFundMe'. With this line the withdrawing is being done using the 'Interactions' script

        assert(address(fundMe).balance == 0);
    }
}
