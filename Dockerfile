FROM ubuntu:latest

ARG RUST_VERSION=stable
ARG SOLANA_VERSION=stable
ARG ANCHOR_VERSION=v0.27.0

# helper scripts
COPY github-entrypoint.sh /github-entrypoint.sh
RUN chmod 777 /github-entrypoint.sh

# core dependencies
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y vim git curl pkg-config build-essential libudev-dev openssl libssl-dev
RUN curl -O http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb
RUN dpkg -i libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb && rm -f libssl1.1_1.1.1f-1ubuntu2.19_amd64.deb

# Cypress dependencies
RUN apt-get install -y libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

# node
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN corepack enable

# cleanup system
RUN apt-get clean

# user environment for tools that are required to be user-scoped
RUN useradd -m tools
USER tools

# rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="$PATH:/home/tools/.cargo/bin"
RUN rustup default $RUST_VERSION
RUN rustup target add wasm32-unknown-unknown

# solana
RUN sh -c "$(curl -sSfL https://release.solana.com/$SOLANA_VERSION/install)"
ENV PATH="$PATH:/home/tools/.local/share/solana/install/active_release/bin"
RUN solana-keygen new --no-bip39-passphrase

# anchor
RUN [ $ANCHOR_VERSION = latest ] \
    && cargo install --git https://github.com/coral-xyz/anchor anchor-cli --locked --force \
    || cargo install --git https://github.com/coral-xyz/anchor anchor-cli --locked --force --tag $ANCHOR_VERSION
RUN cd /home/tools && anchor init x && cd x && cargo update -p solana-program --precise 1.14.26 && anchor build && cd .. && rm -rf x

# test utils
RUN cargo install cargo-llvm-cov cargo-nextest wasm-pack
RUN rustup component add llvm-tools-preview --toolchain stable-x86_64-unknown-linux-gnu

SHELL ["/bin/bash", "-c"]

# give owner's permissions to all users for tools
# this is needed so the container can run with an arbitrary UID
# why python? chmod -R 777 breaks things, and doing this logic with bash is extremely slow
RUN python3 -c $'import os, stat \n\
for grp in os.walk("/home/tools"): \n\
    for name in grp[1] + grp[2]: \n\
        path = os.path.join(grp[0], name) \n\
        os.chmod(path, int(oct(os.stat(path)[stat.ST_MODE])[-3:-2]) * 73)'

# ----------

FROM scratch
COPY --from=0 / /
ENV PATH="$PATH:/home/tools/.cargo/bin:/home/tools/.local/share/solana/install/active_release/bin"
ENV HOME="/home/tools"
