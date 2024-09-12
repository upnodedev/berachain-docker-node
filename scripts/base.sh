#!/bin/bash

set -e

git clone https://github.com/berachain/beacon-kit
cd beacon-kit || exit
make build

./build/bin/beacond version

mkdir build/bin/config
mkdir build/bin/config/beacond
mkdir build/bin/config/reth

./build/bin/beacond init "$MONIKER_NAME" --chain-id bartio-beacon-80084 --consensus-key-algo bls12_381 --home ./build/bin/config/beacond

curl -o "./build/bin/config/beacond/config/genesis.json" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/genesis.json"

cat ./build/bin/config/beacond/config/genesis.json

curl -o "./build/bin/config/beacond/kzg-trusted-setup.json" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/kzg-trusted-setup.json"
curl -o "./build/bin/config/beacond/config/app.toml" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/app.toml"
curl -o "./build/bin/config/beacond/config/config.toml" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/config.toml"

sed -i "s/^moniker = \".*\"/moniker = \"$MONIKER_NAME\"/" "$PWD/build/bin/config/beacond/config/config.toml"
JWT_PATH=$PWD/build/bin/config/beacond/jwt.hex

sed -i "s|^jwt-secret-path = \".*\"|jwt-secret-path = \"$JWT_PATH\"|" "$PWD/build/bin/config/beacond/config/app.toml"

seeds_url="https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/cl-seeds.txt";
seeds=$(curl -s "$seeds_url" | tail -n +2 | tr '\n' ',' | sed 's/,$//')

sed -i "s/^seeds = \".*\"/seeds = \"$seeds\"/" "$PWD/build/bin/config/beacond/config/config.toml"
sed -i "s/^persistent_peers = \".*\"/persistent_peers = \"$seeds\"/" "$PWD/build/bin/config/beacond/config/config.toml"

./build/bin/beacond jwt generate -o ./build/bin/config/beacond/jwt.hex

mkdir snapshots
aria2c --max-tries=0 -x 16 -s 16 -k100M -o ./beacond-pruned-snapshot-202409101232.tar.lz4 https://storage.googleapis.com/bartio-snapshot-eu/beacon/pruned/beacond-pruned-snapshot-202409101232.tar.lz4

mkdir snapshots/tmp
mkdir snapshots/tmp/beacond

lz4 -dc <  ./beacond-pruned-snapshot-202409101232.tar.lz4 | tar xvfz - -C ./snapshots/tmp/beacond
mv ./snapshots/tmp/beacond/root/.beacond/data ./snapshots/tmp/beacond

curl -L https://github.com/paradigmxyz/reth/releases/download/v1.0.3/reth-v1.0.3-x86_64-unknown-linux-gnu.tar.gz > reth-v1.0.3-x86_64-unknown-linux-gnu.tar.gz

tar -xzvf reth-v1.0.3-x86_64-unknown-linux-gnu.tar.gz

./reth --version

curl -o "./build/bin/config/reth/eth-genesis.json" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/eth-genesis.json"

cat ./build/bin/config/reth/eth-genesis.json

exec "$@"
