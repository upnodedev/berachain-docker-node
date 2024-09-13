#!/bin/bash

exec "$BIN_DIR"/beacond start \
    --home "$BEACOND_INIT_DIR" \
    --beacon-kit.engine.rpc-dial-url http://reth:8551 \
    --beacon-kit.kzg.trusted-setup-path "$BEACOND_INIT_DIR"/kzg-trusted-setup.json \
    --db_backend pebbledb
