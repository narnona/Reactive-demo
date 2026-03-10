// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IReactive } from "@reactive/contracts/interfaces/IReactive.sol";
import { AbstractReactive } from "@reactive/contracts/abstract-base/AbstractReactive.sol";
import { ISystemContract } from "@reactive/contracts/interfaces/ISystemContract.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract ReactiveContract is IReactive, AbstractReactive, Ownable {
    error AlreadySet();
    error NeverSet();
    error NodeNotExist();

    event SetMsgNode(uint256 indexed chainId, address msgNode);
    event DisableMsgNode(uint256 indexed chainId);

    // keccak256("SendMessage(address,address,uint256,string)")
    uint256 constant TOPIC_0 = uint256(0x20cf7a31d7cd62c38d409eea8194ebbc741d82d1631d66f4dd7b0bac9c3d5e20);

    mapping(uint256 chainId => address) msgNode;
    uint64 private constant GAS_LIMIT = 1000000;

    constructor(address _service, address _owner) Ownable(_owner) {
        service = ISystemContract(payable(_service));
    }

    // 订阅
    function setMsgNode(uint256 _chainId, address _msgNode) external onlyOwner {
        if(msgNode[_chainId] == _msgNode) revert AlreadySet();
        msgNode[_chainId] = _msgNode;

        if (!vm) {
            service.subscribe(
                _chainId,
                _msgNode,
                TOPIC_0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
        emit SetMsgNode(_chainId, _msgNode);
    }

    // 取消订阅
    function disableMsgNode(uint256 _chainId) external onlyOwner {
        if(msgNode[_chainId] == address(0)) revert NeverSet();
        delete msgNode[_chainId];

        if(!vm) {
            service.unsubscribe(
                _chainId,
                msgNode[_chainId],
                TOPIC_0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
        emit DisableMsgNode(_chainId);
    }

    function react(LogRecord calldata log) external vmOnly {
        uint256 destinationChainid = log.topic_3;
        if(msgNode[destinationChainid] == address(0)) revert NodeNotExist();

        address sender = address(uint160(log.topic_1));
        address receiver = address(uint160(log.topic_2));
        string memory message = abi.decode(log.data, (string));

        bytes memory payload = abi.encodeWithSignature(
            "receiveMessage(address,address,address,uint256,string)", 
            address(0),
            sender,
            receiver,
            log.chain_id,
            message
        );
        emit Callback(destinationChainid, msgNode[destinationChainid], GAS_LIMIT, payload);
    }
}