#!/bin/bash

if [ -e "$RETH_READY_FLAG" ]; then
  echo "Reth is ready."
  exit 0
fi

curl -L "https://github.com/paradigmxyz/reth/releases/download/$RETH_VERSION/reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz" > "reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz"
tar -xzvf "reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz" -C "$BIN_DIR"

"$BIN_DIR"/reth --version

curl -o "$RETH_INIT_DIR/eth-genesis.json" "$ETH_GENESIS_URL"
touch "$RETH_READY_FLAG"

exec "$@"
