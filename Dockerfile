FROM ubuntu:latest

ARG USER=jet
ARG SOLANA_VERSION=stable
ARG ANCHOR_VERSION=latest

# core dependencies
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y git curl pkg-config build-essential libudev-dev openssl libssl-dev

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
RUN cargo install --git https://github.com/project-serum/anchor avm --locked --force
RUN avm install $ANCHOR_VERSION && avm use $ANCHOR_VERSION
RUN cd /$USER && anchor init x && cd x && anchor build && cd .. && rm -rf x

# test utils
RUN cargo install cargo-llvm-cov

# ----------

FROM scratch
COPY --from=0 / /
USER $USER
WORKDIR /$USER
ENV PATH="$PATH:/$USER/.cargo/bin:/$USER/.local/share/solana/install/active_release/bin"
