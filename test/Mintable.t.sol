// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Mintable} from "../contracts/Mintable.sol";

contract MintableTest is Test {
    Mintable public mintable;

    uint256 onePrivateKey =
      0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    address oneAddr =
      0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    uint256 twoPrivateKey =
      0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

    address twoAddr =
      0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function setUp() public {
        vm.prank(oneAddr);
        mintable = new Mintable("SuperToken", "SuperToken", "http://google.com/");
    }

    function test_Increment() public {
        vm.prank(oneAddr);
        mintable.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }
}
