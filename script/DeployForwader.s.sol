// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import {Script} from "forge-std/Script.sol";
import {Forwarder} from "../src/contracts/Forwarder.sol";
import "../src/contracts/Recipient.sol";

contract DeployForwader is Script {
    address public relayer = makeAddr("RELAYER");

    function deployContract() external returns (Forwarder contractAddress) {
        vm.startBroadcast();
        contractAddress = new Forwarder(relayer);
        vm.stopBroadcast();
    }
}
