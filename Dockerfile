ARG USER=root

FROM ubuntu:latest

ARG USER
ARG SOLANA_VERSION=v1.10.35

# core dependencies
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y git curl pkg-config build-essential libudev-dev openssl libssl-dev
RUN curl -O http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1-1ubuntu2.1~18.04.20_amd64.deb
RUN dpkg -i libssl1.1_1.1.1-1ubuntu2.1~18.04.20_amd64.deb && rm libssl1.1_1.1.1-1ubuntu2.1~18.04.20_amd64.deb

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

# solana
RUN sh -c "$(curl -sSfL https://release.solana.com/$SOLANA_VERSION/install)"
ENV PATH="$PATH:/$USER/.local/share/solana/install/active_release/bin"
RUN solana-keygen new --no-bip39-passphrase

# anchor
RUN cargo install --git https://github.com/jet-lab/anchor anchor-cli --locked --force
RUN cd /$USER && anchor init x && cd x && anchor build && cd .. && rm -rf x

# test utils
RUN cargo install cargo-llvm-cov
RUN rustup component add llvm-tools-preview --toolchain stable-x86_64-unknown-linux-gnu

# ----------

FROM scratch
COPY --from=0 / /
ARG USER
ENV PATH="$PATH:/$USER/.cargo/bin:/$USER/.local/share/solana/install/active_release/bin"
