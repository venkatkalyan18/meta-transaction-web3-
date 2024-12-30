// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Test, console} from "forge-std/Test.sol";
import {Forwarder} from "../src/contracts/Forwarder.sol";
import {DeployForwader} from "../script/DeployForwader.s.sol";
import {DeployRecipient} from "../script/DeployRecipient.s.sol";
import {Recipient} from "../src/contracts/Recipient.sol";

contract ForwaderTest is Test {
    Forwarder public forwarder;
    Recipient public recipient;
    DeployForwader deployForwader;
    DeployRecipient deployRecipient;
    address user = makeAddr("USER");

    function setUp() external {
        deployForwader = new DeployForwader();
        forwarder = deployForwader.deployContract();

        deployRecipient = new DeployRecipient();
        recipient = deployRecipient.deployRecipientt(address(forwarder));
    }

    function testCheckIfRelayerAddressIsCorrect() view external {
        address relayerAddress = forwarder.getRelayerAddress();
        assertTrue(deployForwader.relayer() == relayerAddress);
    }

    function testIsVerifyWorking() external {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        Forwarder.ForwardRequest memory forwardRequest = Forwarder.ForwardRequest({
            to: address(recipient),
            from: alice,
            value: 0,
            nonce: 0,
            data: abi.encodeWithSignature("mint(uint256)", 10)
        });

        bytes32 hashedMessage = keccak256(
            abi.encodePacked(forwardRequest.to, forwardRequest.from, forwardRequest.value, forwardRequest.nonce, forwardRequest.data)
        );
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, hashedMessage);
        bytes memory sig = abi.encodePacked(r, s, v);

        (bool isVerified) = forwarder.verify(forwardRequest, sig);
        
        assertTrue(isVerified);
    }

    function testExecuteFunction() external {
        (address alice, uint256 alicePk) = makeAddrAndKey("alice");

        Forwarder.ForwardRequest memory forwardRequest = Forwarder.ForwardRequest({
            to: address(recipient),
            from: alice,
            value: 0,
            nonce: 0,
            data: abi.encodeWithSignature("mint(uint256)", 10)
        });

        bytes32 hashedMessage = keccak256(
            abi.encodePacked(forwardRequest.to, forwardRequest.from, forwardRequest.value, forwardRequest.nonce, forwardRequest.data)
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, hashedMessage);
        bytes memory sig = abi.encodePacked(r, s, v);

        vm.prank(deployForwader.relayer());
        forwarder.execute(forwardRequest,sig);

        assert(recipient.balanceOf(alice) == 10);
    }
}
