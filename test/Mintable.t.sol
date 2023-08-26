// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Mintable} from "../contracts/Mintable.sol";

contract MintableTest is Test {
    Mintable public mintable;

    function setUp() public {
        mintable = new Mintable("SuperToken", "SuperToken", "http://google.com/");
    }

    function test_Increment() public {
        mintable.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }
}
