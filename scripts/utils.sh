#!/bin/bash

clone_repo() {
  local repo_url=$1
  local tag=$2
  local local_dir=$3

  get_current_tag() {
    git -C "$local_dir" describe --tags --abbrev=0 2>/dev/null
  }

  if [ -d "$local_dir/.git" ]; then
    CURRENT_TAG=$(get_current_tag)

    if [ "$CURRENT_TAG" == "$tag" ]; then
      echo "Tag $tag is already the current tag, skipping clone."
      return 0
    else
      echo "Tag mismatch: $CURRENT_TAG vs $tag. Re-cloning."
      rm -rf "$local_dir"
    fi
  fi

  git clone --branch "$tag" --depth 1 "$repo_url" "$local_dir"
}

download_config_files() {
  curl -f -s -o "./genesis.json.tmp" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/genesis.json"
  curl -f -s -o "./kzg-trusted-setup.json.tmp" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/kzg-trusted-setup.json"
  curl -f -s -o "./app.toml.tmp" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/app.toml"
  curl -f -s -o "./config.toml.tmp" "https://raw.githubusercontent.com/berachain/beacon-kit/main/testing/networks/80084/config.toml"

  mv ./genesis.json.tmp "$BEACOND_CONFIG_DIR/genesis.json"
  mv ./kzg-trusted-setup.json.tmp "$BEACOND_INIT_DIR/kzg-trusted-setup.json"
  mv ./app.toml.tmp "$BEACOND_CONFIG_DIR/app.toml"
  mv ./config.toml.tmp "$BEACOND_CONFIG_DIR/config.toml"
}

function download() { 
  local url=$1
  local out=$2

  local dir
  dir=$(dirname "$out")
  local file
  file=$(basename "$out")

  aria2c --max-tries=0 -x 16 -s 16 -k100M -d "$dir" -o "$file" "$url"
}

