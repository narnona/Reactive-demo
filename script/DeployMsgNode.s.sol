// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {MsgNode} from "../src/MsgNode.sol";

contract DeployMsgNode is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address callbackProxy;
        if (block.chainid == 11155111) {
            // Sepolia
            callbackProxy = 0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA;
        } else if (block.chainid == 84532) {
            // Base Sepolia
            callbackProxy = 0xa6eA49Ed671B8a4dfCDd34E36b7a75Ac79B8A5a6;
        } else {
            revert("Unsupported chain");
        }

        MsgNode node = new MsgNode(callbackProxy);
        console2.log("MsgNode deployed to:", address(node));
        console2.log("Chain ID:", block.chainid);
        console2.log("Callback Proxy:", callbackProxy);

        vm.stopBroadcast();
    }
}
