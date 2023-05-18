FROM rust:latest AS builder

ARG PACKAGE
ARG CARGO_ARGS

COPY . /code
WORKDIR /code

RUN --mount=type=cache,target=/usr/local/cargo/registry \
	--mount=type=cache,target=/code/target \
    --mount=type=cache,uid=1500,target=/usr/local/cargo/git \
    cargo build --release --package ${PACKAGE} ${CARGO_ARGS} && \
    mv /code/target/release/${PACKAGE} /app

# -----------------------------------------------------------------

FROM gcr.io/distroless/cc
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
