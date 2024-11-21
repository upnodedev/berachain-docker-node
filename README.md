# berachain-docker-node ⛵️✨⚡

Easily run the bArtio RPC node in a single command via docker.

Make sure you have [docker](https://docs.docker.com/)!

```bash
./run
```

Sync time with snapshots is a few hours.

> [!NOTE]  
> This repository is under active development. Things may change. Closer to the Berachain mainnet there will be more customizations and support for different ELs.

## Using Snapshots

To avoid waiting for the long sync time, we can use `beacond` & `reth` snapshots in one of these two ways.

### Auto Snapshots

The easiest way is to use Upnode snapshots provided with [bera-snap](https://github.com/upnodedev/bera-snap) tool.

Just set `true` for `BEACOND_SNAPSHOT_ENABLED` and `RETH_SNAPSHOT_ENABLED` in the `.env` file. In this case, snapshots will be downloaded and decompressed automatically.

```bash
# Beacond
BEACOND_SNAPSHOT_ENABLED=true
BEACOND_SNAPSHOT_DATADIR_NAME="data/beacond/data"

# Reth
RETH_SNAPSHOT_ENABLED=true
RETH_SNAPSHOT_DATADIR_NAME="data/reth"
```

### Manual Snapshots

Download and decompress the pruned beacond (pebbledb) and full reth snapshots as described in [Quickstart: Run A Node - Step 4 (Download Snapshot)](https://docs.berachain.com/nodes/quickstart#step-4-download-snapshot-recommended).

But move the files to the shared `data` directory.

```bash
# beacond
mv ./snapshots/tmp/beacond/data ./data/beacond/data;

# reth
mv ./snapshots/tmp/reth/blobstore ./data/reth;
mv ./snapshots/tmp/reth/db ./data/reth;
mv ./snapshots/tmp/reth/static_files ./data/reth;
```

## Logs

```bash
docker compose logs -f --tail 100
```

## Auto Snapshots For Your Node

You can use [bera-snap](https://github.com/upnodedev/bera-snap) for automatic node snapshots with configurable scheduling. Supports API access and optional [GCS](https://cloud.google.com/storage) upload. See [docs](https://github.com/upnodedev/bera-snap/blob/main/README.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
