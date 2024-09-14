#!/bin/bash

set -e

# shellcheck disable=SC1091
source ./scripts/utils.sh

prepare_beacond() {
  clone_repo "$BEACON_REPO_URL" "$BEACON_TAG" "$BEACOND_REPO_DIR"
  cd "$BEACOND_REPO_DIR"

  if [ ! -f "$BIN_DIR/beacond" ]; then
    make build
    cp -f "$BEACOND_REPO_DIR/build/bin/beacond" "$BIN_DIR/"
  fi

  "$BIN_DIR/beacond" version
}

configure_beacond() {
  if [ -z "$(ls -A "$BEACOND_CONFIG_DIR")" ]; then
    "$BIN_DIR/beacond" init "$MONIKER_NAME" --chain-id "$CHAIN_ID" --consensus-key-algo bls12_381 --home "$BEACOND_INIT_DIR"
    rm -f "$BEACOND_CONFIG_DIR/genesis.json" "$BEACOND_CONFIG_DIR/app.toml" "$BEACOND_CONFIG_DIR/config.toml"
  fi

  if [ ! -f "$BEACOND_CONFIG_DIR/genesis.json" ] || [ ! -f "$BEACOND_INIT_DIR/kzg-trusted-setup.json" ] || [ ! -f "$BEACOND_CONFIG_DIR/app.toml" ] || [ ! -f "$BEACOND_CONFIG_DIR/config.toml" ]; then
    download_config_files
  fi

  sed -i "s/^moniker = \".*\"/moniker = \"$MONIKER_NAME\"/" "$BEACOND_CONFIG_DIR/config.toml"
  sed -i "s|^jwt-secret-path = \".*\"|jwt-secret-path = \"$JWT_PATH\"|" "$BEACOND_CONFIG_DIR/app.toml"

  seeds=$(curl -s "$SEEDS_URL" | tail -n +2 | tr '\n' ',' | sed 's/,$//')
  peers=$(curl -s "$PEERS_URL")

  sed -i "s/^seeds = \".*\"/seeds = \"$seeds\"/" "$BEACOND_CONFIG_DIR/config.toml"
  sed -i "s/^persistent_peers = \".*\"/persistent_peers = \"$peers\"/" "$BEACOND_CONFIG_DIR/config.toml"

  if [ ! -f "$JWT_PATH" ]; then
    ./build/bin/beacond jwt generate -o "$JWT_PATH"
  fi
}

handle_beacond_snapshot() {
  if [ ! -f "$SNAPSHOTS_DIR/$BEACOND_SNAPSHOT" ] || [ -f "$SNAPSHOTS_DIR/$BEACOND_SNAPSHOT.aria2" ]; then
    download "$BEACOND_SNAPSHOT_URL" "$SNAPSHOTS_DIR/$BEACOND_SNAPSHOT"
  fi

  mkdir -p "$BEACOND_SNAPSHOT_TEMP"
  lz4 -dc < "$SNAPSHOTS_DIR/$BEACOND_SNAPSHOT" | tar xvf - -C "$BEACOND_SNAPSHOT_TEMP"
  mv "$BEACOND_SNAPSHOT_TEMP"/"$BEACOND_SNAPSHOT_DATADIR_NAME"/* "$BEACOND_DATA_DIR"
}

prepare_reth() {
  curl -L "https://github.com/paradigmxyz/reth/releases/download/$RETH_VERSION/reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz" > "reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz"
  tar -xzvf "reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz" -C "$BIN_DIR"
  "$BIN_DIR/reth" --version

  curl -o "$RETH_INIT_DIR/eth-genesis.json" "$ETH_GENESIS_URL"
}

handle_reth_snapshot() {
  if [ ! -f "$SNAPSHOTS_DIR/$RETH_SNAPSHOT" ] || [ -f "$SNAPSHOTS_DIR/$RETH_SNAPSHOT.aria2" ]; then
    download "$RETH_SNAPSHOT_URL" "$SNAPSHOTS_DIR/$RETH_SNAPSHOT"
  fi

  mkdir -p "$RETH_SNAPSHOT_TEMP"
  tar -xzvf "$SNAPSHOTS_DIR/$RETH_SNAPSHOT" -C "$RETH_SNAPSHOT_TEMP"
  mv "$RETH_SNAPSHOT_TEMP"/"$RETH_SNAPSHOT_DATADIR_NAME"/* "$RETH_INIT_DIR"
}

main() {
  if [ ! -e "$BEACOND_READY_FLAG" ]; then
    prepare_beacond
    configure_beacond
    [ "$BEACOND_SNAPSHOT_ENABLED" = true ] && handle_beacond_snapshot
    touch "$BEACOND_READY_FLAG"
  fi

  if [ ! -e "$RETH_READY_FLAG" ]; then
    prepare_reth
    [ "$RETH_SNAPSHOT_ENABLED" = true ] && handle_reth_snapshot
    touch "$RETH_READY_FLAG"
  fi

  exec "$@"
}

main "$@"
