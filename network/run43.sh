#!/bin/bash

geth --datadir ~/.ethereum/net42 --networkid 42 --rpc --rpcport 8545 --rpcaddr 0.0.0.0 --rpccorsdomain "*" --rpcapi "admin,db,debug,eth,miner,net,personal,shh,txpool,web3" console
