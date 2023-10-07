// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {SolaProfile} from "../contracts/SolaProfile.sol";
// import {MintableUpgradeable} from "../contracts/MintableUpgradeable.sol";
// import {Mintable} from "../contracts/Mintable.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UUPSProxy is ERC1967Proxy {
  constructor(
    address _implementation,
    bytes memory _data
  ) ERC1967Proxy(_implementation, _data) {}
}

contract MintableUpgradeableTest is Test {
    SolaProfile public mintable;
    SolaProfile implementationV1;
    SolaProfile wrappedProxyV1;
    SolaProfile profile;
    UUPSProxy proxy;

    uint256 onePrivateKey =
      0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    address oneAddr =
      0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    uint256 twoPrivateKey =
      0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

    address twoAddr =
      0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function setUp() public {
      implementationV1 = new SolaProfile();

      proxy = new UUPSProxy(address(implementationV1), "");

      vm.prank(oneAddr);
      profile = SolaProfile(address(proxy));
      profile.initialize("Profile", "Profile", "http://example.com", 37);
    }

    function test_ProfileAdmin() public {
      assertEq(profile.owner(), oneAddr);
      vm.prank(oneAddr);
      profile.setProfileCreator(oneAddr, true);
      vm.prank(oneAddr);
      uint256 tokenId =  profile.createProfile(oneAddr, "");

      console2.log(tokenId);

      assertEq(profile.ownerOf(38), oneAddr);
    }
}
