#!/bin/bash

bootnodes=$(curl -s "$BOOTNODES_URL" | grep '^enode://' | tr '\n' ',' | sed 's/,$//');

exec "$BIN_DIR"/reth node \
  --authrpc.jwtsecret="$JWT_PATH" \
  --chain="$RETH_INIT_DIR/eth-genesis.json" \
  --datadir="$RETH_INIT_DIR" \
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
  --log.file.directory=."$RETH_INIT_DIR/logs" \
  --metrics=0.0.0.0:6060
