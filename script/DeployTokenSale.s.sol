// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {TestConfig as test} from "./TestConfig.s.sol";

contract DeployTokenSale is Script, HelperConfig {
    function run() external returns (TokenSale) {
        test.Config memory config = getConstructorConfig();

        vm.startBroadcast();
        TokenSale sale = new TokenSale(
            config._tokenPrice,
            config._presaleCap,
            config._presaleMinContribution,
            config._presaleMaxContribution,
            config._presaleStartTime,
            config._presaleEndTime,
            config._publicSaleCap,
            config._publicSaleMinContribution,
            config._publicSaleMaxContribution,
            config._publicSaleStartTime,
            config._publicSaleEndTime,
            config._minCap,
            config._distributionAddress,
            config._totalSupply
        );
        vm.stopBroadcast();
        return sale;
    }
}
