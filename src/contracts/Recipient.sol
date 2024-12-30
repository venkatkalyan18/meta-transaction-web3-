// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Recipient is ERC20, ERC20Permit {
    address public immutable i_forwarder;

    constructor(address _forwarder) ERC20("Flair", "FLR") ERC20Permit("Flair") {
        i_forwarder = _forwarder;
    }

    function mint(uint256 amount) public {
        address sender = msgSender();
        _mint(sender, amount);
    }

    function msgSender() internal view returns (address) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return address(bytes20(msg.data[msg.data.length - 20:]));
        } else {
            revert("Invalid call");
        }
    }

    function isTrustedForwarder(
        address forwarder
    ) internal view returns (bool isTrusted) {
        isTrusted = (i_forwarder == forwarder);
    }

    function getRelayerAddress() internal view returns (address) {
        return i_forwarder;
    }
}
