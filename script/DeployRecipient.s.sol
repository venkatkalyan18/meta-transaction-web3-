// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import {Script} from "forge-std/Script.sol";
import {Recipient} from "../src/contracts/Recipient.sol";

contract DeployRecipient is Script {
    function deployRecipientt(
        address forwarderAddress
    ) external returns (Recipient) {
        Recipient recipient;
        vm.startBroadcast();
        recipient = new Recipient(forwarderAddress);
        vm.stopBroadcast();
        return recipient;
    }
}
