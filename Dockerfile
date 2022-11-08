ARG USER=root

FROM ubuntu:latest

ARG USER
ARG RUST_VERSION=stable
ARG SOLANA_VERSION=stable
ARG ANCHOR_VERSION=latest

# core dependencies
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y git curl pkg-config build-essential libudev-dev openssl libssl-dev
RUN curl -O http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1-1ubuntu2.1~18.04.20_amd64.deb
RUN dpkg -i libssl1.1_1.1.1-1ubuntu2.1~18.04.20_amd64.deb && rm libssl1.1_1.1.1-1ubuntu2.1~18.04.20_amd64.deb

# Cypress dependencies
RUN apt-get install -y libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# user environment
RUN [ $USER = root ] || useradd -md /$USER $USER
ENV PATH="$PATH:/$USER/.cargo/bin:/$USER/.local/share/solana/install/active_release/bin"

# node
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN corepack enable

USER $USER

# rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="$PATH:/$USER/.cargo/bin"
RUN rustup default $RUST_VERSION

# solana
RUN sh -c "$(curl -sSfL https://release.solana.com/$SOLANA_VERSION/install)"
ENV PATH="$PATH:/$USER/.local/share/solana/install/active_release/bin"
RUN solana-keygen new --no-bip39-passphrase

# anchor
RUN [ $ANCHOR_VERSION = latest ] \
    && cargo install --git https://github.com/jet-lab/anchor anchor-cli --locked --force \
    || cargo install --git https://github.com/jet-lab/anchor anchor-cli --locked --force --tag $ANCHOR_VERSION
RUN cd /$USER && anchor init x && cd x && anchor build && cd .. && rm -rf x

# test utils
RUN cargo install cargo-llvm-cov
RUN rustup component add llvm-tools-preview --toolchain stable-x86_64-unknown-linux-gnu
RUN cargo install cargo-nextest

# ----------

FROM scratch
COPY --from=0 / /
ARG USER
ENV PATH="$PATH:/$USER/.cargo/bin:/$USER/.local/share/solana/install/active_release/bin"
