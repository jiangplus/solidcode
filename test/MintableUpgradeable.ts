import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";

import { expect } from "chai";
import { ethers } from "hardhat";

import keccak256 from "keccak256";
import { MerkleTree } from "merkletreejs";

describe("Mintable", function () {
  async function deployFixture() {
    const [owner, otherAccount] = await ethers.getSigners();
    // console.log('account', owner.address, otherAccount.address)

    const Mintable = await ethers.getContractFactory("MintableUpgradeable");
    const mintable = await upgrades.deployProxy(Mintable, ["SuperToken", "SuperToken", "http://google.com/"],
    {
      kind: 'uups',
    });
    // const mintable = await Mintable.attach("");
    console.log('mintable address:', mintable.address)

    const Mintable2 = await ethers.getContractFactory("MintableUpgradeableV2");
    const mintable2 = await upgrades.upgradeProxy(mintable.address, Mintable2);
    console.log("mintable upgraded");

    console.log(mintable2)

    return { mintable: mintable2, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should be mintable", async function () {
      const { mintable, owner, otherAccount } = await deployFixture();

      await mintable.connect(owner).mint(owner.address);
      await mintable.connect(owner).mint(otherAccount.address);
      console.log("exists(1)", await mintable.exists(1));
      console.log("ownerOf(1)", await mintable.ownerOf(1));
      console.log("tokenURI(1)", await mintable.tokenURI(1));
      await mintable.setTokenURI("http://google.com/nft/");
      console.log("tokenURI(1)", await mintable.tokenURI(1));
    });

  });
});
