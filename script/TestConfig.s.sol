// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface TestConfig {
    struct Config {
        uint256 _tokenPrice;
        uint256 _presaleCap;
        uint256 _presaleMinContribution;
        uint256 _presaleMaxContribution;
        uint256 _presaleStartTime;
        uint256 _presaleEndTime;
        uint256 _publicSaleCap;
        uint256 _publicSaleMinContribution;
        uint256 _publicSaleMaxContribution;
        uint256 _publicSaleStartTime;
        uint256 _publicSaleEndTime;
        uint256 _minCap;
        address _distributionAddress;
        uint256 _totalSupply;
    }
}
