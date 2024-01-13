// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {TestConfig as test} from "./TestConfig.s.sol";

/**
 * @title HelperConfig
 * @author ashuk1109
 *
 * The values here are strictly for carrying out testing purposes in a swift manner
 * and may not necessarily replicate the values which we may find for tokens in the actual market
 */
contract HelperConfig is Script {
    function getConstructorConfig() internal view returns (test.Config memory) {
        uint256 _tokenPrice = 100;

        uint256 _presaleCap = 3000 ether;
        uint256 _presaleMinContribution = 1 ether;
        uint256 _presaleMaxContribution = 50 ether;
        uint256 _presaleStartTime = block.timestamp;
        uint256 _presaleEndTime = block.timestamp + 2 minutes;

        uint256 _publicSaleCap = 5000 ether;
        uint256 _publicSaleMinContribution = 1 ether;
        uint256 _publicSaleMaxContribution = 50 ether;
        uint256 _publicSaleStartTime = _presaleEndTime + 1 minutes;
        uint256 _publicSaleEndTime = _publicSaleStartTime + 5 minutes;

        uint256 _minCap = 2000 ether;
        address _distributionAddress = address(this);

        uint256 _totalSupply = 1e6 ether;

        test.Config memory config = test.Config(
            _tokenPrice,
            _presaleCap,
            _presaleMinContribution,
            _presaleMaxContribution,
            _presaleStartTime,
            _presaleEndTime,
            _publicSaleCap,
            _publicSaleMinContribution,
            _publicSaleMaxContribution,
            _publicSaleStartTime,
            _publicSaleEndTime,
            _minCap,
            _distributionAddress,
            _totalSupply
        );

        return config;
    }
}
