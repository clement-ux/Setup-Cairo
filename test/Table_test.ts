import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { starknet } from "hardhat";
import { Account, StarknetContract } from "hardhat/types";

describe("My Test", function () {
    this.timeout(30_000);

    let contract: StarknetContract;
    let deck: StarknetContract;


    let account0: Account;
    let account1: Account;
    let account2: Account;

    before(async function () {
        this.timeout(30000000)
        // Accounts
        account0 = await starknet.deployAccount("OpenZeppelin");
        account1 = await starknet.deployAccount("OpenZeppelin");
        account2 = await starknet.deployAccount("OpenZeppelin");

        // Contracts
        let contractFactory = await starknet.getContractFactory("table");
        contract = await contractFactory.deploy();
        
        console.log("Contract deployed at address: ",contract.address)

        await account1.invoke(contract, "init_deck")
    })

    /*
    it("Should draw a card", async function () {
        const res = await account0.call(deck, "draw", {id : 20})
        console.log(res.card.color.toString())
    })*/
    
    it("Should do nothing", async function () {
        const amount = BigInt(10);
        const caller = await account1.call(contract,"sender")

        await account1.invoke(contract, "caving", {amount})
        const is_player = await account1.call(contract,"get_is_player", {address :account1.address})
        const balance_player_after = await account1.call(contract,"get_balance_player", {address :account1.address})

        console.log(caller)
        console.log(balance_player_after)
        console.log(is_player)
    })

    it("User should draw", async function () {
        const res = await account1.invoke(contract, "draw_hand", {id : 20})
        //console.log(res)
        const card = await account1.call(contract, "get_deck", {id:20})
        console.log(card)
        const hand = await account1.call(contract, "get_hand_player", {address : account1.address})
        console.log(hand)
    })

    /*
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
    */
})