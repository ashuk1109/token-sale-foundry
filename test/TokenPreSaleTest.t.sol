// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {TokenSale, TokenSaleEvents as events} from "../src/TokenSale.sol";
import {DeployTokenSale} from "../script/DeployTokenSale.s.sol";

contract TokenPreSaleTest is StdCheats, Test {
    DeployTokenSale public deployer;
    TokenSale public tokenSale;
    address public owner;
    address public tokenSaleAddress;
    address user1;
    address[] public users;

    function setUp() external {
        deployer = new DeployTokenSale();
        tokenSale = deployer.run();
        owner = tokenSale.owner();
        tokenSaleAddress = address(tokenSale);
        user1 = vm.addr(1);
        vm.deal(user1, 1000 ether);

        users = new address[](100);
        for (uint256 i = 0; i < users.length; i++) {
            users[i] = vm.addr(i + 4);
            vm.deal(users[i], 50 ether);
        }
    }

    function testOwner() public {
        assertEq(tokenSale.owner(), msg.sender);
    }

    function testPreSaleActive() public view {
        assert(tokenSale.isPresaleActive());
    }

    function testContributeRevertsWhenSaleNotStarted() public {
        (, , , , uint256 starTime, , ) = tokenSale.getPreSale();
        vm.warp(starTime - 1 seconds);
        vm.startPrank(user1);
        vm.expectRevert(TokenSale.TokenSale__SaleNotActive.selector);
        tokenSale.contribute{value: 1 ether}();
        vm.stopPrank();
    }

    function testPreSaleContributionRevert() public {
        vm.startPrank(user1);
        vm.expectRevert(TokenSale.TokenSale__ContributionOutOfRange.selector);
        tokenSale.contribute{value: 0.01 ether}();
        vm.expectRevert(TokenSale.TokenSale__ContributionOutOfRange.selector);
        tokenSale.contribute{value: 51 ether}();
        vm.stopPrank();
    }

    function testPreSaleContribution() public {
        uint256 amount = 2 ether;
        vm.startPrank(user1);
        vm.expectEmit(true, false, false, true);
        emit events.TokensPurchased(
            user1,
            amount,
            tokenSale.getTokenAmount(amount)
        );
        tokenSale.contribute{value: amount}();
        vm.stopPrank();

        // Test contribution recorded for user1
        assert(tokenSale.getPreSaleContributions(user1) == amount);

        // Test total contribution amount is updated
        (, , , , , , uint256 totalContributed) = tokenSale.getPreSale();
        assert(totalContributed == amount);

        // Test user1 gets the correct amount of tokens
        uint256 expectedTokens = tokenSale.getTokenAmount(amount);
        assert(tokenSale.balanceOf(user1) == expectedTokens);
    }

    function testRevertsWhenPreSaleCapReached() public {
        (, uint256 cap, , , , , ) = tokenSale.getPreSale();
        uint256 numOfUsers = cap / 50 ether;
        for (uint8 i = 0; i < numOfUsers; i++) {
            vm.startPrank(users[i]);
            tokenSale.contribute{value: 50 ether}();
            vm.stopPrank();
        }
        vm.startPrank(user1);
        vm.expectRevert(TokenSale.TokenSale__SaleCapExceeded.selector);
        tokenSale.contribute{value: 1 ether}();
        vm.stopPrank();
    }

    function testRevertsWhenUserCapReached() public {
        vm.startPrank(user1);
        (, , , uint256 maxContribution, , , ) = tokenSale.getPreSale();
        uint256 amount = maxContribution / 2;
        tokenSale.contribute{value: amount}();
        tokenSale.contribute{value: amount}();
        vm.expectRevert(
            TokenSale.TokenSale__MaxUserContributionCapReached.selector
        );
        tokenSale.contribute{value: 1 ether}();
        vm.stopPrank();
    }

    function testRevertsWhenEmergencyStopActive() public {
        vm.startPrank(owner);
        tokenSale.emergencyStopSale();
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert(TokenSale.TokenSale__EmergencyStopActive.selector);
        tokenSale.contribute{value: 1 ether}();
        vm.stopPrank();
    }

    function testRevertsRefundWhenPreSaleActive() public {
        vm.startPrank(user1);
        tokenSale.contribute{value: 10 ether}();
        vm.expectRevert(TokenSale.TokenSale__SaleStillActive.selector);
        tokenSale.claimRefund();
        vm.stopPrank();
    }

    function testRevertsRefundWhenPreMinCapReached() public {
        uint256 minCap = tokenSale.i_minCap();
        uint256 numOfUsers = minCap / 50 ether;
        for (uint8 i = 0; i < numOfUsers; i++) {
            vm.startPrank(users[i]);
            tokenSale.contribute{value: 50 ether}();
            vm.stopPrank();
        }

        (, , , , , uint256 endTime, ) = tokenSale.getPreSale();

        vm.startPrank(user1);
        tokenSale.contribute{value: 10 ether}();
        vm.warp(endTime + 1 seconds);
        vm.expectRevert(TokenSale.TokenSale__SaleMinCapReached.selector);
        tokenSale.claimRefund();
        vm.stopPrank();
    }

    function testClaimRefund() public {
        uint256 minCap = tokenSale.i_minCap();
        uint256 numOfUsers = minCap / 50 ether;
        for (uint8 i = 0; i < numOfUsers - 1; i++) {
            vm.startPrank(users[i]);
            tokenSale.contribute{value: 50 ether}();
            vm.stopPrank();
        }

        (, , , , , uint256 endTime, ) = tokenSale.getPreSale();

        vm.startPrank(user1);
        tokenSale.contribute{value: 10 ether}();
        vm.warp(endTime + 1 seconds);
        vm.expectEmit(true, false, false, true);
        emit events.TokensRefunded(user1, 10 ether);
        tokenSale.claimRefund();
        vm.stopPrank();
    }

    function testRevertsRefundWhenNoContribution() public {
        uint256 minCap = tokenSale.i_minCap();
        uint256 numOfUsers = minCap / 50 ether;
        for (uint8 i = 0; i < numOfUsers - 1; i++) {
            vm.startPrank(users[i]);
            tokenSale.contribute{value: 50 ether}();
            vm.stopPrank();
        }

        (, , , , , uint256 endTime, ) = tokenSale.getPreSale();
        vm.warp(endTime + 1 seconds);
        vm.startPrank(user1);
        vm.expectRevert(TokenSale.TokenSale__NoContributionToRefund.selector);
        tokenSale.claimRefund();
        vm.stopPrank();
    }
}
