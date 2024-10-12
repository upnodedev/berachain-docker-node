# berachain-docker-node ⛵️✨⚡

Easily run the bArtio RPC node in a single command via docker.

Make sure you have [docker](https://docs.docker.com/)!

```bash
./run
```

Sync time ~Xh.

> [!NOTE]  
> This repository is under active development. Things may change. Closer to the Berachain mainnet there will be more customizations and support for different ELs.

## Logs

```bash
docker compose logs -f --tail 100
```

## Auto snapshots

You can use [bera-snap](https://github.com/upnodedev/snapshotify) for automatic snapshots, either local only or with upload to [GCS](https://cloud.google.com/storage). See README.md for details.
