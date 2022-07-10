
# Poker Stark

A prototype for a 100% on-chain poker game, build for Matchbox hackhaton. 


## Comment

The objective here was to create a 100% on-chain poker, based on StarkNet. 

However, due to the lack of knowledge of the Cairo language, we could not achieve 
all that was desired by far.

What has been done:
- User can come and sit at the table if there is enough open seat), and have a balance.
- User of the table can confirm they are ready to play.
- When all user seated users are ready to play, they can start the a round.
- When a round is started :
    - First the deck is initialized.
    - Then the distribution of two cards per player start.
    - After that the users can start to bet, using the inside game balance.
    - After this point, the game logic has no been setup, so all next function 
        can happend at the same time.
    - The distribution of the flop, turn river.
    - Choosen the winning hand has not been done.
    - Update the balance of the winner after the calculation of the winner.

- About the encryption of the card, this part has not been done, but could be planned. 
    At the moment, only the get_caller_address() can access to hand using a view, but we 
    know that this is not good way to do it. 

- There are a lot of mistake and no-sens in the smart contract, since we are learning cairo 
    for a really short time. But at least thanks to this hackhaton we learn a huge amount of 
    things for this language, which is really new for us. 

- This contract has not been deployed to the tesnet for some obvious reasons. 
    So it is not linked to the front-end at the moment. 
## Link for front-end

[Front-end Poker Stark](https://github.com/clement-ux/Poker-Stark)


## Roadmap

- Comming ...


## Installation

Install packages, run Devnet for testing (open docker), start testing

```bash
  npm install
  starknet-devnet &
  npx hardhat test
```
    