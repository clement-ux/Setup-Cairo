import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { starknet } from "hardhat";
import { Account, StarknetContract } from "hardhat/types";

describe("My Test", function () {
    this.timeout(30_000);

    let contract: StarknetContract;


    let account0: Account;
    let account1: Account;
    let account2: Account;

    before(async function () {
        // Accounts
        account0 = await starknet.deployAccount("OpenZeppelin");
        account1 = await starknet.deployAccount("OpenZeppelin");
        account2 = await starknet.deployAccount("OpenZeppelin");

        // Contracts
        const contractFactory = await starknet.getContractFactory("contract");
        contract = await contractFactory.deploy();

        console.log("Contract deployed at address: ",contract.address)
    })

    it("Should test", async function () {
        const amount = BigInt(10);
        const { res: currBalance } = await account0.call(contract, "get_balance");
        await account0.invoke(contract, "increase_balance", { amount });
        const { res: newBalance } = await account0.call(contract, "get_balance");
        //console.log(currBalance, newBalance)
        expect(newBalance).to.deep.equal(currBalance + amount);
    })
    it("should estimate fee", async function () {
        const fee = await contract.estimateFee("increase_balance", { amount: BigInt(10) });
        //console.log("Estimated fee:", fee.amount, fee.unit);
    });
    it("should return transaction data and transaction receipt", async function () {
        console.log("Deployment transaction hash:", contract.deployTxHash);
    
        const transaction = await starknet.getTransaction(contract.deployTxHash);
        console.log(transaction);
    
        const txHash = await contract.invoke("increase_balance", { amount: 10 });
    
        const receipt = await starknet.getTransactionReceipt(txHash);
        console.log(receipt.events);
    });
})
0.000259500_000000000