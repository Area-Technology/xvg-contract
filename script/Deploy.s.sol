// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {XVGStorage} from "../src/XVGStorage.sol";
import {Script} from "forge-std/Script.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
    }
}
