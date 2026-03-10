// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {ReactiveContract} from "../src/ReactiveContract.sol";

contract DeployReactive is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);

        // System contract address for Reactive Lasna (and Mainnet)
        address service = 0x0000000000000000000000000000000000fffFfF;
        
        // Deploying ReactiveContract
        // Constructor: constructor(address _service, address _owner)
        ReactiveContract rc = new ReactiveContract(service, deployerAddress);

        console2.log("ReactiveContract deployed to:", address(rc));
        console2.log("System Service Address:", service);
        console2.log("Owner Address:", deployerAddress);

        vm.stopBroadcast();
    }
}
