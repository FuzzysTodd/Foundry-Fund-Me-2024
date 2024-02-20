// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // This user will be used for the tests

    uint256 constant SEND_VALUE = 0.1 ether; // This is the value that the user will send to the contract

    uint256 constant STARTING_BALANCE = 10 ether; // This is the starting balance of the user created

    uint256 constant GAS_PRICE = 1; // This is the gas price that each transaction will cost

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // Here I am deploying a 'FundMe' contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // USER's balance is updated
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWhenNotEnoughEthIsSent() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next transaction will be sent by 'USER'
        fundMe.fund{value: SEND_VALUE}(); // User is calling the 'fund' function and is sending 'SEND_VALUE'
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); // Calling 'getAddressToAmountFunded' function on the 'fundMe' object. The address of 'USER' is passed as an argument and the amount funded by 'USER' gets returned
        assertEq(amountFunded, SEND_VALUE); // Verify if 'amountFunded' that was returned above is equal to 'SEND_VALUE'
    }

    function testFunderIsAddedToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0); // Calling 'getFunder' function on the 'fundMe' object at the zero index (which should be USER, because there's only one funder)
        assertEq(funder, USER); // Verify if 'funder' that was returned above is equal to 'USER'
    }

    modifier funded() {
        // This modifier will allow me to, instead of having to write this code to fund
        // every single one of my tests, I can just include this modifier in each function declaration
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // This test is testing if when the USER tries to withdraw it reverts, as USER is not the owner
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Note: this test is run without taking into consideration gas costs
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // This is how I get the owner's starting balance
        uint256 startingFundMeBalance = address(fundMe).balance; // This is how I get the fundMe contract starting balance

        // Act
        vm.prank(fundMe.getOwner()); // I prank making sure it's the actual owner, because only the owner can call 'withdraw'
        fundMe.withdraw(); // The 'withdraw' function is called by the owner

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // The ending user's balance after the 'withdraw' function was called
        uint256 endingFundMeBalance = address(fundMe).balance; // The ending fundMe contract balance after the 'withdraw' function was called
        assertEq(endingFundMeBalance, 0); // Checking if the ending balance of 'fundMe' contract is indeed zero, after all the funds were withdrawn
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // Checking if the balance of the owner has added all the funds withdrawn to what he already had
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Note: this test is run taking into consideration gas costs
        // On this test, the difference is that there will be many funders that send funds to the contract by calling 'fund', and
        // on the contrary, there was only one funder on the previous functions

        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // With this loop, we are creating a new address for each funder and each address will fund the 'fundMe' contract
            // vm.prank (for creating a new address)
            // vm.deal (for funding the new address)
            hoax(address(i), SEND_VALUE); // This creates a blank address and adds a balance of 'SEND_VALUE' to it. This address calls 'fund' below
            fundMe.fund{value: SEND_VALUE}(); // Each address that gets created throughout the loop calls 'fund' and fund the contract with a 'SEND_VALUE' amount
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft(); // This is the gas prior to calling 'withdraw'
        vm.txGasPrice(GAS_PRICE); // With this line I am able to set a gas price that I want
        vm.startPrank(fundMe.getOwner()); // Make sure is the owner the one who calls 'withdraw'
        fundMe.withdraw(); // The 'withdraw' function gets called
        vm.stopPrank();
        uint256 gasEnd = gasleft(); // This is the gas after calling 'withdraw'
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // This calculates the gas used
        console.log(gasUsed); // This will output the number associated with the gas used

        // Assert
        assert(address(fundMe).balance == 0); // Checking if the address of the 'fundMe' contract has a balance of zero (it showld, because 'withdraw' was called)
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); // Checking if the starting balance of the owner plus the starting balance of the 'fundMe' contract equals to the owner's ending balance balance (after 'withdraw' was called)
            // uint256 endingOwnerBalance = fundMe.getOwner().balance;
            // uint256 endingFundMeBalance = address(fundMe).balance;
            // assertEq(endingFundMeBalance, 0);
            // assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Note: this test is run taking into consideration gas costs
        // On this test, the difference is that there will be many funders that send funds to the contract by calling 'fund', and
        // on the contrary, there was only one funder on the previous functions

        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // With this loop, we are creating a new address for each funder and each address will fund the 'fundMe' contract
            // vm.prank (for creating a new address)
            // vm.deal (for funding the new address)
            hoax(address(i), SEND_VALUE); // This creates a blank address and adds a balance of 'SEND_VALUE' to it. This address calls 'fund' below
            fundMe.fund{value: SEND_VALUE}(); // Each address that gets created throughout the loop calls 'fund' and fund the contract with a 'SEND_VALUE' amount
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft(); // This is the gas prior to calling 'withdraw'
        vm.txGasPrice(GAS_PRICE); // With this line I am able to set a gas price that I want
        vm.startPrank(fundMe.getOwner()); // Make sure is the owner the one who calls 'withdraw'
        fundMe.cheaperWithdraw(); // The 'cheaperWithdraw' function gets called
        vm.stopPrank();
        uint256 gasEnd = gasleft(); // This is the gas after calling 'withdraw'
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // This calculates the gas used
        console.log(gasUsed); // This will output the number associated with the gas used

        // Assert
        assert(address(fundMe).balance == 0); // Checking if the address of the 'fundMe' contract has a balance of zero (it showld, because 'withdraw' was called)
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); // Checking if the starting balance of the owner plus the starting balance of the 'fundMe' contract equals to the owner's ending balance balance (after 'withdraw' was called)
            // uint256 endingOwnerBalance = fundMe.getOwner().balance;
            // uint256 endingFundMeBalance = address(fundMe).balance;
            // assertEq(endingFundMeBalance, 0);
            // assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
}
