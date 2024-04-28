---
layout: post
title:  "Cryptothingies workshop"
date:	2024-04-28 20:06:41 +0200
author: foo
categories: workshop smart-contracts
ref: cryptothingies-workshop
---

A year or two ago I created a small workshop to introduce my work colleagues to the basics of Smart Contracts security.

Besides the presentation, which I include right after this section, I created a small lab with a couple of Virtual Machines to play around my own local testnet.

What follows are my raw notes.
Keep in mind, I haven't curated them in any way, so they might be confusing.
I'm simply releasing them because I had them laying around and it's already written, so it takes no effort for me to publish them.

If you're interested on the technical aspects of the attacks, I created a [companion post](/post/workshop/smart-contracts/2024/04/28/cryptothingies-workshop-solutions.html) with all the (again, raw) details.

Table of Contents:
* Table of Contents
{:toc}


{% include embed_pdf.html
	path="/assets/posts/2024-04-28-cryptothingies-workshop/Cryptothingies.pdf"
%}


----

<br/>
<br/>
<br/>

# Intro

The Ethereum (ETH) stack looks like this (from top to bottom):

  5. **Distributed apps (dapps)** -> End-user applications. Can be a regular mobile app, without noticing that the whole blockchain is below it. For example, a block explorer is a dapp.

  4. **Client APIs** -> Not really a necessary part of the stack, but provide abstraction to access the blockchain (create transactions, get information from existing ones, ...).

  3. **ETH Node** -> Part of the blockchain, which verifies the transactions and stores the status of the chain. The nodes are just computers that run an Ethereum client

  2. **Smart Contract** -> Programs that compile to EVM (ETH VM) Bytecode, along with their data (state). Can be written in a multitude of languages (Solidity, Vyper, Yul, ...) Provide a set of functions that anyone can call from their dapps.
		A smart contract is an ETH account, but not controlled vy a user, sondern by their programming. The functions can be called by issuing a transaction.

  1. **ETH VM** -> Like any VM, translates the opcodes of the Smart Contract to the (native) instructions that the node will run

<br/>
<br/>
<br/>

# Requirements

There are several solutions to create private networks and develop smart contracts.
Most of them are written in Typescript (notable exeption being [Brownie](https://github.com/eth-brownie/brownie), which uses Python).

For this project, I need:

  - **A private network** (*testnet*). There are public [test networks](https://ethereum.org/en/developers/docs/networks/#testnets), but some of them rarely have anyone mining (so, I have to run a node), and I prefer to have everything locally so I can easier look at my transactions and no one disturbs me.
	[Hardhat](https://hardhat.org/) has tools to compile, deploy and test smart contracts, and has a built-in local network. Its strength is the incorporated debugging, so I can more easily trace a contract to understand an exploit.
	[Ganache](https://github.com/trufflesuite/ganache), part of the Truffle suite, might be also another option. However, Truffle's documentation seems to be a little bit outdated (or maybe the Eth ecosystem changes too fast, idk)

  - **A block explorer**. This is not really a _must_, but a _nice-to-have_. I could just use the node's API and create a silly explorer myself (or even just use hardhat/truffle existing functions), but I'd rather use an existing one with a nice UI.
	It looks like [scaffold-eth](https://github.com/scaffold-eth/scaffold-eth) integrates hardhat with a UI to develop Smart Contracts and review the transactions, but it consumes a ton of memory (I can't even make it start on my VM).
	[Ganache-UI](https://github.com/trufflesuite/ganache-ui) is the equivalent for Truffle (it incorporates both the network and the UI).

	[Blockscout](https://github.com/blockscout/blockscout) is a web frontend which can connect to any node's RPC to explore transactions et al.

There are also IDEs like [Remix](https://remix-project.org/), which provide an easy interface for Smart Contract development.
I won't do any development, though, just copy+pasting from the CTF challenges.


In the end, I decided to use Hardhat+Blockscout because of the debugging capabilities.

<br/>
<br/>
<br/>

# Set up on Arch Linux

First, NodeJS and npm: `pacman -Su npm` (this automatically installs NodeJS as a dependency)

Then, set hardhat up (assuming no errors occur on any command):
```sh
$ mkdir hardhat-testnet && cd hardhat-testnet
$ npm init
[Follow the prompts...]
$ npm install --save-dev hardhat
$ npx hardhat
[Follow the prompts on "create a sample project". Neither hardhat-waffle nor hardhat-ethers are required, since we won't write any test cases...]
```

We can also compile the defaul test contract (Greeter.sol) and deploy it to the testnet:
```sh
$ npx hardhat compile
Downloading compiler 0.8.4
Compiled 2 Solidity files successfully
$ npx hardhat run scripts/sample-script.js
Deploying a Greeter with greeting: Hello, Hardhat!
Greeter deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
$ npx hardhat node --hostname 0.0.0.0
Started HTTP and WebSocket JSON-RPC server at http://0.0.0.0:8545/

Accounts
========

WARNING: These accounts, and their private keys, are publicly known.
Any funds sent to them on Mainnet or any other live network WILL BE LOST.

Account #0: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 (10000 ETH)
[...]
```

Then, on another terminal session, we can run Blockscout to explore the testnet:
```sh
$ pacman -Su postgresql elixir autoconf make automake && rustup install stable && rustup default stable
$ su - postgres -c "initdb --locale en_GB.ISO-8859-1 -D '/var/lib/postgres/data'"
[...]
Success. You can now start the database server using:

    pg_ctl -D /var/lib/postgres/data -l logfile start
$ systemctl start postgresql.service
$ su - postgres -c 'createuser --interactive'
Enter name of role to add: blockscout
Shall the new role be a superuser? (y/n) n
Shall the new role be allowed to create databases? (y/n) n
Shall the new role be allowed to create more new roles? (y/n) n
$ su - postgres -c 'createdb -O blockscout -U postgres blockscout_data' # MAKE SURE THE DB DOESN'T CONTAIN A HYPHEN: https://github.com/blockscout/blockscout/issues/5234
$ # Now, PostgreSQL is configured
$ mkdir block-explorer && cd block-explorer
$ curl -sLO 'https://github.com/blockscout/blockscout/archive/refs/heads/master.zip'
$ unzip master.zip
$ cd blockscout-master/
$ export DATABASE_URL=postgresql://blockscout:@localhost:5432/blockscout_data
$ export ETHEREUM_JSONRPC_HTTP_URL=http://localhost:8545
$ mix do deps.get, local.rebar --force, deps.compile
[...]
Generated block_scout_web app
$ export SECRET_KEY_BASE="$(mix phx.gen.secret)"
$ mix compile
$ mix do ecto.create, ecto.migrate
[...]
[...] [info]  == Migrated 20220306091504 in 0.0s
$ cd apps/block_scout_web/assets ; npm install --legacy-peer-deps && node_modules/webpack/bin/webpack.js --mode production ; cd -
$ cd apps/explorer && npm install && mix phx.digest; cd -
$ cd apps/block_scout_web; mix phx.gen.cert blockscout blockscout.local; cd -
* creating priv/cert/selfsigned_key.pem
* creating priv/cert/selfsigned.pem
[...]
$ mix phx.server
[...]
[...] application=phoenix [info] Running BlockScoutWeb.Endpoint with cowboy 2.9.0 at 0.0.0.0:4000 (http)
[...] application=phoenix [info] Running BlockScoutWeb.Endpoint with cowboy 2.9.0 at 0.0.0.0:4001 (https)
[...]
```

Contracts can be verified (or, at least, when they have no constructor args) using the standard JSON ([https://docs.blockscout.com/for-users/verifying-a-smart-contract#via-standard-json-input](https://docs.blockscout.com/for-users/verifying-a-smart-contract#via-standard-json-input):
  -  Go to the contract address
  - Click on the "code" tab > "verify & publish" > "Via standard input JSON"
  - Fill in he contract name (for example: `contracts/01-Fallback.sol:Fallback`), the compiler version, and upload the input json
	- The JSON can be obtained with `jq ".input" artifacts/build-info/<the deployed contract one>.json`
	- The ABI-encoded arguments can (in theory) be found using [https://abi.hashex.org/](https://abi.hashex.org/) + `jq '.output.contracts."contracts/<whatever>.sol".<contract name>.abi' artifacts/build-info/<the deployed contract one>.json -c`


Finally, the test contract can be compiled, deployed and tested:
```sh
$ npx hardhat compile
$ npx hardhat run scripts/sample-script.js  --network localhost
Greeter deployed to: 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
$ npx hardhat test --network localhost

  Greeter
    ✔ Should return the new greeting once it's changed (849ms)


  1 passing (854ms)
```

<br/>
<br/>
<br/>

# Playing the CTF

To compile and deploy one of the CTF's contracts, we need an older version of the openzeppelin/contracts library, which uses Solidity 0.6.0:
```sh
$ cd hardhat-testnet && npm i @openzeppelin/contracts@3.4.1
```

After that, we can just paste the contracts' source code (can also be found here: [https://github.com/OpenZeppelin/ethernaut](https://github.com/OpenZeppelin/ethernaut)):
```sh
$ cd hardhat-testnet && npx hardhat compile
Compiled 1 Solidity file successfully
$  npx hardhat run scripts/deploy-ctf.js --network localhost
contracts/01-Fallback.sol:Fallback deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
contracts/00-Hello Ethernaut.sol:Instance deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
(...)
```

This is my custom script to deploy and verify contracts using just `npx hardhat run scripts/deploy-ctf.js`:
```js
const hre = require("hardhat");
const http = require ("http"); /* Change to require("https") if the URL below should use TLS */
const querystring = require ("querystring")

const BLOCKSCOUT_HOST = "127.0.0.1";
const BLOCKSCOUT_PORT = 4000;


/**
 * Verifies the contract's source code on the just deployed address
 */
async function blockscout_verify (contract_name, address, args = null) {

  const artifact =  await artifacts.readArtifact (contract_name);
  /* I'm assuming it exists, because I don't care enough to do proper error handling */
  const abi = artifact ["abi"];


  const debug_info = await artifacts.getBuildInfo(contract_name);
  /* Again, assuming they exist */
  const standard_input = debug_info ["input"];
  const compiler = debug_info ["solcLongVersion"];

  let post_data = {
        "module":"contract",
          "action": "verifysourcecode",
        "codeformat": "solidity-standard-json-input",
        "contractaddress": address,
        "contractname": contract_name,
        "compilerversion": "v" + compiler, /* Blockscout dies without further info if the compiler doesn't have the "v" */
        "sourceCode": JSON.stringify (standard_input)
  };


  if (args) {

    const iface = new hre.ethers.utils.Interface (abi);
    const encoded_args = iface.encodeDeploy (args);
    /* Yup, the typo is there in the API */
    post_data ["constructorArguements"] = encoded_args.replace (/^0x/, ""); /* The resulting string has a leading "0x", but Blockscout doesn't like that */
  }

  const data = querystring.stringify (post_data);

  const req = http.request (
    {
      "hostname": BLOCKSCOUT_HOST,
      "port": BLOCKSCOUT_PORT,
      "path": "/api",
      "method": "POST",
      "headers": {
        "Content-Type": "application/x-www-form-urlencoded",
        "Content-Length": Buffer.byteLength (data)
      }
    },
    res => {
      res.on ("data", d => {

        const response = JSON.parse (d);

        if (response ["status"] == "1" ) {
          /* The verification takes some time, so it makes no sense to keep polling for it */
          console.log ("Issued verification for " + contract_name);
        } else {
          console.log ("Verification of " + contract_name + " result: ", response ["result"]);
        }
      });
    }
  );

  req.on ("error", error => {
    console.error ("Error while verifying " + contract_name + " deployed at " + address + ":");
    console.error (error.message);
  });

  req.write (data);
  req.end ();
}



/**
 * Deploys the selected contract and starts the verification process, if the parameter "verify" is "true"
 * Since the contract's constructor may take one or more arguments, it's up to the caller to specify the
 * correct deployment function, which will get called after getContractFactory() is finished and returns
 * a contract. For example: `(contract, args) => { retur contract.deploy (args [0], args [1]) }`
 *
 * The constructor function can access the args through the "args" array, which is also passed to deploy()
 * and MUST return the result of contract.deploy()
 */
async function deploy (contract_name, verify = false, constructor, args) {

  const contract = await hre.ethers.getContractFactory (contract_name);
  const deployed = await constructor (contract, args);

  console.log (contract_name + " deployed to:", deployed.address);

  if (verify) {
    const timer = ms => new Promise( res => setTimeout(res, ms));
    console.log ("Waiting 60 seconds to allow transactions to be mined and Blockscout to ingest the new data");

    timer(60000).then(_=> blockscout_verify (contract_name, deployed.address, args));
  }
}





function main() {

  /* Dictionary of contracts and arguments
     Each element should contain the following information:
      - name: str -> full path to the contract (e.g.: "contracts/01-Fallback.sol:Fallback")
      - constructor: function -> Contract's constructor, to deploy it
      - args: array|null -> Arguments to pass to the constructor
      - verify: boolean -> "true" if the contract should be verified in Blockscout
  */
  const contracts = [
    {
      "name": "contracts/01-Fallback.sol:Fallback",
      "constructor": (contract, args) => { return contract.deploy (); },
      "args": null,
      "verify": true
    },
    {
      "name": "contracts/00-Hello Ethernaut.sol:Instance",
      "constructor": (contract, args) => { return contract.deploy (args [0]); },
      "args": [ "SuperSecurePassword!" ],
      "verify": true
    }
  ]

  const req = http.request (
    {
      "hostname": BLOCKSCOUT_HOST,
      "port": BLOCKSCOUT_PORT,
      "path": "/api",
      "method": "GET"
    },
    res => {
      /* If there's any reply at all, I assume that the server is running (instead of waiting for the data) */
      contracts.forEach (
        c => {
          deploy (c ["name"], c ["verify"], c ["constructor"], c ["args"]);
        }
      );
    }
  );

  req.on ("error", error => {
    console.log ("Error contacting blockscout: " + error.message);

    /* Just deploy the contracts, without verification */
    contracts.forEach (
      c => {
        deploy (c ["name"], false, c ["constructor"], c ["args"]);
      }
    );
  });

  req.end ();
}

main()
/*  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
})*/
```

To call a contract and interact with it, this template can be used:
```html
<html>
<head>
	<script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js"></script>
</head>
<body>
<script>
	const web3 = new Web3("http://192.168.0.22:8545");
	const attackerAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

	//  jq '.output.contracts."contracts/Greeter.sol".Greeter.abi' artifacts/build-info/f6d72e584f9c6e176d0b340e8f9097a9.json  -c
	const GREETER_ABI = [{"inputs":[{"internalType":"string","name":"_greeting","type":"string"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"greet","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"_greeting","type":"string"}],"name":"setGreeting","outputs":[],"stateMutability":"nonpayable","type":"function"}]
	const GREETER_ADDR = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"

	const greeter_contract = new web3.eth.Contract (GREETER_ABI, GREETER_ADDR)

	greeter_contract.methods.setGreeting ("qwer").send (
		{"from": attackerAddress},
		function (err, res) {
			if (err) {
				console.log("An error occured", err);
				return;
			}
			console.log("Registered transaction: ", res)
		}
	);
</script>
</body>
</html>
```

Then, `greeter_contract` can be used to interact with the contract.
The methods defined by the contract are available under `greeter_contract.methods.<method_name>`, and can be either `call`ed (for requests which don't change the contract's status and, therefore, don't create a transaction on the chain) or `send`ed to (which change the contract's status and require a payment, since the transaction will be registered in the chain).
More info on `call` vs `send()` here: [https://bitsofco.de/calling-smart-contract-functions-using-web3-js-call-vs-send/](https://bitsofco.de/calling-smart-contract-functions-using-web3-js-call-vs-send/)

<br/>
<br/>
<br/>

# Solutions

## Hello Ethernaut

We're told to get the contract's information by `call`ing `contract.info()`:
```js
>> ctf00_contract.methods.info ().call ( (err, res) => console.log (res));
You will find what you need in info1().
```

As instructed, we can keep following the trail:
```js
>> ctf00_contract.methods.info1 ().call ( (err, res) => console.log (res));
Try info2(), but with "hello" as a parameter.
>> ctf00_contract.methods.info2 ("hello").call ( (err, res) => console.log (res));
The property infoNum holds the number of the next info method to call.
>> ctf00_contract.methods.infoNum ().call ( (err, res) => console.log (res));
42
>> ctf00_contract.methods.info42 ().call ( (err, res) => console.log (res) );
theMethodName is the name of the next method.
>> ctf00_contract.methods.theMethodName ().call ( (err, res) => console.log (res) );
The method name is method7123949.
>> ctf00_contract.methods.method7123949 ().call ( (err, res) => console.log (res) );
If you know the password, submit it to authenticate().
```

Note that, to get the value of the `infoNum` property, we can just `call` it like with any other contract.
Since the final method requests a password, we can also peek at the `password` property and `send` it to `authenticate()` (since we're changing the contract's status):
```js
>> ctf00_contract.methods.password ().call ( (err, res) => console.log (res) );
SuperSecurePassword!
>> ctf00_contract.methods.authenticate ("SuperSecurePassword!").call ( (err, res) => console.log (res) );
Object {  }
>> ctf00_contract.methods.getCleared ().call ( (err, res) => console.log (res) );
false
```

Huh?
Why is it not cleared?
Oh, true, because `call` doesn't change the contract status.

Let's try again, but this time let's send a transaction:
```js
>> ctf00_contract.methods.authenticate ("asdf").send ({ "from": attackerAddress }, (err, res) => console.log (res) );
0x46da940b7eed9fb741015e5cf0d87d33d112bd2795f26fe9aea6e6458d6d5c0e
>> ctf00_contract.methods.getCleared ().call ( (err, res) => console.log (res) );
false
>> ctf00_contract.methods.authenticate ("SuperSecurePassword!").send ({ "from": attackerAddress }, (err, res) => console.log (res) );
0xb598659853e78ffaa0a4cf72b8f06733d07ce2ef2af9019dbbc486dd37e3f302
>> ctf00_contract.methods.getCleared ().call ( (err, res) => console.log (res) );
true
```

As shown above, creating a transaction with a wrong password doesn't clear the level, but using the correct password does work.

## Fallback

According to the description of this challenge: You will beat this level if
  - you claim ownership of the contract
  - you reduce its balance to 0


----

# Extra references

[https://ethereum.org/en/developers/local-environment/](https://ethereum.org/en/developers/local-environment/) -> Official ETH documentation with info to some tools that can be used for development

[https://ethereum.org/en/developers/docs/ethereum-stack/](https://ethereum.org/en/developers/docs/ethereum-stack/) -> Explanation of the whole ETH stack

[https://ethereum.org/en/developers/docs/smart-contracts/languages/](https://ethereum.org/en/developers/docs/smart-contracts/languages/) -> List of languages that can be used to develop Smart Contracts

[https://blog.soliditylang.org/2022/02/07/solidity-developer-survey-2021-results/](https://blog.soliditylang.org/2022/02/07/solidity-developer-survey-2021-results/) -> Solidity developer survey, including the share of the different developent tools ( [https://blog.soliditylang.org/img/2022/02/eth_ide.png](https://blog.soliditylang.org/img/2022/02/eth_ide.png) )

[https://swcregistry.io/](https://swcregistry.io/) => Smart Contract Weakness Classification (SWE) list. SWEs are like CWE, but for SmartContracts

----


