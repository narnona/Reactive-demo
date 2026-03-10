// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AbstractCallback} from "@reactive/contracts/abstract-base/AbstractCallback.sol";

contract MsgNode is AbstractCallback {
    event SendMessage(
        address indexed sender, 
        address indexed receiver,
        uint256 indexed destinationChainid, 
        string message
    );

    event ReceivedMessage(
        address indexed sender,
        address indexed receiver,
        uint256 indexed sourceChainid,
        string message
    );

    constructor(address _callback_sender) AbstractCallback(_callback_sender) payable {}


    function sendMessage(address receiver, uint256 destinationChainid, string calldata message) external {
        emit SendMessage(
            msg.sender, 
            receiver, 
            destinationChainid, 
            message
        );
    }

    function receiveMessage(
        address rvm_id_ptr, // 这里的参数会被 Reactive 填充为 RVM ID
        address sender, 
        address receiver, 
        uint256 sourceChainid, 
        string memory message
    ) external authorizedSenderOnly rvmIdOnly(rvm_id_ptr) {
        emit ReceivedMessage(
            sender,
            receiver,
            sourceChainid,
            message
        );
    }
}