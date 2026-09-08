# ---------------------------------------------------------
# Stage 1: Build the latest navi binary from source
# ---------------------------------------------------------
FROM rust:alpine AS navi-builder

RUN apk add --no-cache musl-dev git

# Install the latest release directly from crates.io
RUN cargo install navi --locked

# ---------------------------------------------------------
# Stage 2: Minimal runtime diagnostic environment
# ---------------------------------------------------------
FROM alpine:3.20

# Install exactly the binaries referenced by the cheat sheet
# - iproute2: ss, ip
# - iputils: ping
# - netcat-openbsd: nc
# - bind-tools: dig
# - traceroute, mtr, tcpdump, iperf3, openssl, curl: core network stack
# - zsh, bash, fzf: interactive shells and navi fuzzy search backend
RUN apk add --no-cache \
    bash \
    bind-tools \
    ca-certificates \
    curl \
    fzf \
    iperf3 \
    iproute2 \
    iputils \
    mtr \
    netcat-openbsd \
    openssl \
    tcpdump \
    traceroute \
    zsh

# Copy the compiled binary from the builder stage
COPY --from=navi-builder /usr/local/cargo/bin/navi /usr/local/bin/navi

# Set navi discovery paths
ENV NAVI_PATH=/root/.local/share/navi/cheats

# Inject the custom Vim-motion cheatsheet
COPY cheats/ "${NAVI_PATH}/custom/"

# Enable shell integration
RUN echo 'eval "$(navi widget zsh)"' >> /root/.zshrc && \
    echo 'eval "$(navi widget bash)"' >> /root/.bashrc

WORKDIR /root
CMD ["/bin/zsh"]
