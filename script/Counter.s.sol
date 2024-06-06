// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "src/Counter.sol";

contract CounterScript is Script {
    Counter counter;
    uint256 constant EXPECTED_NONCE = 0; // TODO Edit this with the nonce of the deployer address
    // The list of networks to deploy to.
    string[] public networks = ["mainnet", "optimism", "sepolia"];
    string[] public networkRpcUrls =
        ["https://eth.llamarpc.com", "https://optimism.llamarpc.com", "https://ethereum-sepolia-rpc.publicnode.com"];
    mapping(string => address) public counterAddresses;

    function run() public {
        address expectedContractAddress = vm.computeCreateAddress(msg.sender, EXPECTED_NONCE);
        console.log("Expected contract address: %s", expectedContractAddress);

        for (uint256 i; i < networkRpcUrls.length; i++) {
            vm.createSelectFork((networkRpcUrls[i]));
            bool isDeployed = address(expectedContractAddress).code.length > 0;

            if (isDeployed) {
                console.log("Skipping '%s': contract already deployed at %s", networks[i], expectedContractAddress);
                revert("Contract already deployed");
            }

            uint256 nonce = vm.getNonce(msg.sender);
            if (nonce != EXPECTED_NONCE) {
                console.log("%s: current nonce %d != expected nonce %d", networks[i], nonce, EXPECTED_NONCE);
                revert("Nonce Mismatch");
            }

            // Deploy the contract
            vm.broadcast();
            counter = new Counter();
            counterAddresses[networks[i]] = address(counter);
        }

        for (uint256 i; i < networks.length; i++) {
            console.log("Deployed contract to '%s' at %s", networks[i], counterAddresses[networks[i]]);
        }
    }
}
