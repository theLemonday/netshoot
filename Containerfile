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
RUN set -ex \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache \
    bash \
    bind-tools \
    ethtool \
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
    iptables \
    nftables \
    zsh \
    oh-my-zsh \
    starship \
    openssh \
    neovim \
    git \
    jq

RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
COPY motd motd
COPY zshrc .zshrc
COPY bashrc .bashrc
COPY starship.toml /root/.config/starship.toml

# Copy the compiled binary from the builder stage
COPY --from=navi-builder /usr/local/cargo/bin/navi /usr/local/bin/navi

# Set navi discovery paths
ENV NAVI_PATH=/root/.local/share/navi/cheats

# Inject the custom Vim-motion cheatsheet
COPY cheats/ "${NAVI_PATH}/custom/"

WORKDIR /root
CMD ["/bin/zsh"]
