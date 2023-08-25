# The version of debian used here should not exceed the version of debian used to build distroless images
# This is to ensure that the glibc versions of distroless are >= of rust
FROM rust:bullseye AS builder

ARG PACKAGE
ARG CARGO_ARGS
ARG RUSTFLAGS

COPY . /code
WORKDIR /code

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/code/target \
    --mount=type=cache,uid=1500,target=/usr/local/cargo/git \
    RUSTFLAGS="${RUSTFLAGS}" cargo build --release --package ${PACKAGE} --target x86_64-unknown-linux-gnu ${CARGO_ARGS} && \
    mv /code/target/x86_64-unknown-linux-gnu/release/${PACKAGE} /app

# -----------------------------------------------------------------

FROM gcr.io/distroless/cc
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
