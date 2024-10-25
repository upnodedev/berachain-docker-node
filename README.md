# berachain-docker-node ⛵️✨⚡

Easily run the bArtio RPC node in a single command via docker.

Make sure you have [docker](https://docs.docker.com/)!

```bash
./run
```

Sync time ~Xh.

> [!NOTE]  
> This repository is under active development. Things may change. Closer to the Berachain mainnet there will be more customizations and support for different ELs.

## Using Snapshots

To avoid waiting for the long sync time, we can use `beacond` & reth `snapshots`. The easiest way is to use Upnode snapshots provided with [bera-snap](https://github.com/upnodedev/bera-snap) tool.

Just set `true` for `BEACOND_SNAPSHOT_ENABLED` and `RETH_SNAPSHOT_ENABLED` in the `.env` file. In this case, snapshots will be downloaded and decompressed automatically.

```bash
#########################################################################
#                          ↓ SNAPSHOTS ↓                                #
#########################################################################

# Snapshot source configuration (bera-snap)
SNAPSHOT_SOURCE="api" # Possible values: "gcs" or "api"
# SNAPSHOT_METADATA_URL="https://storage.googleapis.com/yourbucket/berachain/snapshots/metadata.json" # EXAMPLE GCS URL!
SNAPSHOT_METADATA_URL="http://bera-api.upnode.org/snapshots"

# Beacond
BEACOND_SNAPSHOT_ENABLED=true # <-- HERE
BEACOND_SNAPSHOT_DATADIR_NAME="data/beacond/data"

# Reth
RETH_SNAPSHOT_ENABLED=true # <-- HERE
RETH_SNAPSHOT_DATADIR_NAME="data/reth"
# ...
```

## Logs

```bash
docker compose logs -f --tail 100
```

## Auto Snapshots For Your Node

You can use [bera-snap](https://github.com/upnodedev/bera-snap) for automatic node snapshots with configurable scheduling. Supports API access and optional [GCS](https://cloud.google.com/storage) upload. See [docs](https://github.com/upnodedev/bera-snap/blob/main/README.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
