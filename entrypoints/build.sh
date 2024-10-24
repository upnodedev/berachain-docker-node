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

get_latest_snapshot() {
  local snapshot_type=$1
  local metadata
  metadata=$(curl -s "$SNAPSHOT_METADATA_URL")
  echo "$metadata" | jq -r --arg type "$snapshot_type" '.snapshots | sort_by(.uploadTime) | reverse | map(select(.fileName | contains($type))) | .[0].fileName'
}

handle_snapshot() {
  local snapshot_type=$1
  local snapshot_datadir=$2
  local snapshot_temp_dir=$3
  local snapshot_datadir_name=$4
  local snapshot_full_path
  local snapshot_file
  local snapshot_url

  snapshot_full_path=$(get_latest_snapshot "$snapshot_type")
  snapshot_file=$(basename "$snapshot_full_path")

  if [ "$SNAPSHOT_SOURCE" = "gcs" ]; then
    snapshot_url="https://storage.googleapis.com/$snapshot_full_path"
  else
    snapshot_url="$SNAPSHOT_METADATA_URL/$snapshot_file"
  fi

  if [ ! -f "$SNAPSHOTS_DIR/$snapshot_file" ] || [ -f "$SNAPSHOTS_DIR/$snapshot_file.aria2" ]; then
    download "$snapshot_url" "$SNAPSHOTS_DIR/$snapshot_file"
  fi

  mkdir -p "$snapshot_temp_dir"
  lz4 -dc < "$SNAPSHOTS_DIR/$snapshot_file" | tar xvf - -C "$snapshot_temp_dir"
  mv "$snapshot_temp_dir/$snapshot_datadir_name"/* "$snapshot_datadir"
  rm -rf "$snapshot_temp_dir"
  rm -f "$SNAPSHOTS_DIR/$snapshot_file"
}

prepare_reth() {
  curl -L "https://github.com/paradigmxyz/reth/releases/download/$RETH_VERSION/reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz" > "reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz"
  tar -xzvf "reth-$RETH_VERSION-x86_64-unknown-linux-gnu.tar.gz" -C "$BIN_DIR"
  "$BIN_DIR/reth" --version

  curl -o "$RETH_INIT_DIR/eth-genesis.json" "$ETH_GENESIS_URL"
}

main() {
  if [ ! -e "$BEACOND_READY_FLAG" ]; then
    prepare_beacond
    configure_beacond
    if [ "$BEACOND_SNAPSHOT_ENABLED" = true ]; then
      handle_snapshot "pruned_snapshot" "$BEACOND_DATA_DIR" "$BEACOND_SNAPSHOT_TEMP" "$BEACOND_SNAPSHOT_DATADIR_NAME"
    fi
    touch "$BEACOND_READY_FLAG"
  fi

  if [ ! -e "$RETH_READY_FLAG" ]; then
    prepare_reth
    if [ "$RETH_SNAPSHOT_ENABLED" = true ]; then
      handle_snapshot "reth_snapshot" "$RETH_INIT_DIR" "$RETH_SNAPSHOT_TEMP" "$RETH_SNAPSHOT_DATADIR_NAME"
    fi
    touch "$RETH_READY_FLAG"
  fi

  exec "$@"
}

main "$@"
