import { expect } from "chai";
import { starknet } from "hardhat";

describe("My Test", function () {
    this.timeout(30_000);

    it("Should test", async function () {
        const contractFactory = await starknet.getContractFactory("contract");
        const contract = await contractFactory.deploy();
        console.log("Contract deployed at address: ",contract.address)
    })
})