FROM rust:1-slim-bookworm AS builder

WORKDIR /usr/src/huaguruncho_rust
COPY . .

RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY --from=builder /usr/src/huaguruncho_rust/target/release/huaguruncho_server /app/huaguruncho_server
COPY --from=builder /usr/src/huaguruncho_rust/target/release/libhuaguruncho_core.so /app/libhuaguruncho_core.so

ENV RUST_ENGINE_PORT=8081
EXPOSE 8081

CMD ["/app/huaguruncho_server"]
