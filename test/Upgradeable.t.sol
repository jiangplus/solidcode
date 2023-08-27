// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {MintableUpgradeable} from "../contracts/MintableUpgradeable.sol";
import {Mintable} from "../contracts/Mintable.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UUPSProxy is ERC1967Proxy {
  constructor(
    address _implementation,
    bytes memory _data
  ) ERC1967Proxy(_implementation, _data) {}
}

contract MintableUpgradeableTest is Test {
    MintableUpgradeable public mintable;
    MintableUpgradeable implementationV1;
    MintableUpgradeable wrappedProxyV1;
    UUPSProxy proxy;

    function setUp() public {
        implementationV1 = new MintableUpgradeable();

        // deploy proxy contract and point it to implementation
        proxy = new UUPSProxy(address(implementationV1), "");

        wrappedProxyV1 = MintableUpgradeable(address(proxy));
        wrappedProxyV1.initialize("SuperToken", "SuperToken", "http://google.com/");

    }

    function test_Increment() public {
        wrappedProxyV1.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    }
}
