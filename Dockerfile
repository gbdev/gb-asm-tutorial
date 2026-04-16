# Get simple debian image
FROM debian:latest
LABEL org.opencontainers.image.source=https://github.com/gbdev/gb-asm-tutorial
SHELL ["bash", "-lc"]
RUN apt update
RUN apt install curl -y

# Install rust and mdbook
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN apt install gcc -y
RUN source "$HOME/.cargo/env"
RUN cargo install mdbook@0.4.52

COPY . /code
WORKDIR /code

# Serve gb-asm-tutorial
# See https://github.com/rust-lang/mdBook/issues/2226
RUN mdbook build
CMD mdbook serve --hostname 0.0.0.0 & mdbook watch