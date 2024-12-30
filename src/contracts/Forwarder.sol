// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import {ECDSA} from "./libraries/ECDSA.sol";

contract Forwarder {
    using ECDSA for bytes32;

    struct ForwardRequest {
        address to;
        address from;
        uint256 value;
        uint256 nonce;
        bytes data;
    }

    address public immutable i_relayer; 

    constructor(address relayer){
        i_relayer = relayer;
    }

    mapping(address => uint256) nonces;

    function verify(ForwardRequest memory req, bytes memory sig) public view returns (bool) {

        bytes32 hashedMessage = keccak256(
            abi.encodePacked(req.to, req.from, req.value, req.nonce, req.data)
        );

        address signer = hashedMessage.recover(sig);
        return (nonces[req.from] == req.nonce && req.from == signer);
    }

    function execute(
        ForwardRequest memory forwardRequest,
        bytes memory sig
    ) external payable returns (bool isSuccess) {
        require(msg.sender == i_relayer, "Invalid Relayer address");
        require(verify(forwardRequest, sig), "Invalid signature or nonce");

        nonces[forwardRequest.from] += 1;

        (isSuccess, ) = forwardRequest.to.call(
            abi.encodePacked(forwardRequest.data,forwardRequest.from)
        );

    }

    function getNonce(address add) view external returns(uint256 nonce){
        nonce = nonces[add];
    } 

    function getRelayerAddress() view external returns(address){
        return i_relayer;
    }
}
