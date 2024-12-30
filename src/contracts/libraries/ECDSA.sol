// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

library ECDSA {

    function getSignerMessage(bytes32 hashedMessage) internal pure returns(bytes32 ethSignedMessage){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",hashedMessage));
    }

    function recover(bytes32 hashedMessage,bytes memory sig) internal pure returns(address){
        (uint8 v, bytes32 r,bytes32 s) = tryRecover(sig);
        return ecrecover(hashedMessage, v, r, s);
    }

    function tryRecover(bytes memory sig) internal pure returns (uint8 v, bytes32 r,bytes32 s){
        require(sig.length == 65,"Invalid signature");
        
            assembly {
                r := mload(add(sig, 32))
                s := mload(add(sig, 64))
                v := byte(0, mload(add(sig, 96)))
            }
    }   
}