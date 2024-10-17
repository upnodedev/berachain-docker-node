FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ENV GO_VERSION=1.23.1
ENV FOUNDRY_VERSION=nightly-d663f38be3114ccb94f08fe3b8ea26e27e2043c1

RUN apt-get update && \
    apt-get install -y git make jq curl wget build-essential pkg-config libssl-dev openssl ca-certificates unzip gnupg aria2 net-tools lz4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ARCH=$(dpkg --print-architecture) && echo "Architecture: ${ARCH}" && \
    wget https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/root/.foundry/bin:${PATH}"
RUN foundryup -v ${FOUNDRY_VERSION}

WORKDIR /app

COPY entrypoints/build.sh /app/build.sh
COPY scripts/utils.sh /app/scripts/utils.sh
RUN chmod +x /app/build.sh

ENTRYPOINT ["/app/build.sh"]
