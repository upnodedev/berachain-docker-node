#!/bin/bash

bootnodes_url="https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/el-bootnodes.txt";
bootnodes=$(curl -s "$bootnodes_url" | grep '^enode://' | tr '\n' ',' | sed 's/,$//');

exec ./reth node --authrpc.jwtsecret=./build/bin/config/beacond/jwt.hex \
--chain=./build/bin/config/reth/eth-genesis.json \
--datadir=./build/bin/config/reth \
--port=30303 \
--http \
--http.addr=0.0.0.0 \
--http.api="eth,net,web3,txpool,debug" \
--http.port=8545 \
--http.corsdomain="*" \
--bootnodes="$bootnodes" \
--trusted-peers="$bootnodes" \
--ws \
--ws.addr=0.0.0.0 \
--ws.port=8546 \
--ws.origins="*" \
--authrpc.addr=0.0.0.0 \
--authrpc.port=8551 \
--log.file.directory=./build/bin/config/reth/logs \
--metrics=0.0.0.0:6060
