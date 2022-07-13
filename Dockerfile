FROM ubuntu:latest

ARG SOLANA_VERSION=stable
ARG ANCHOR_VERSION=latest

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y git curl pkg-config build-essential libudev-dev openssl libssl-dev
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN curl -O http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1l-1ubuntu1.6_amd64.deb
RUN dpkg -i libssl1.1_1.1.1l-1ubuntu1.6_amd64.deb
RUN corepack enable
RUN useradd -m jet

USER jet

RUN	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

ENV PATH="$PATH:/home/jet/.cargo/bin"

RUN	sh -c "$(curl -sSfL https://release.solana.com/$SOLANA_VERSION/install)"
RUN cargo install --git https://github.com/project-serum/anchor avm --locked --force
RUN avm install $ANCHOR_VERSION
RUN avm use $ANCHOR_VERSION
RUN cargo install cargo-llvm-cov

ENV PATH="$PATH:/home/jet/.cargo/bin:/home/jet/.local/share/solana/install/active_release/bin"

RUN solana-keygen new --no-bip39-passphrase

# ----------

FROM scratch
COPY --from=0 / /
USER jet
ENV PATH="$PATH:/home/jet/.cargo/bin:/home/jet/.local/share/solana/install/active_release/bin"
