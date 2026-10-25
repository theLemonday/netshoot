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
    kubectl \
    util-linux \
    fd \
    bat \
    jq \
    navi

RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
ADD https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

WORKDIR /root

COPY motd motd
COPY zshrc .zshrc
COPY bashrc .bashrc
COPY config/ /root/.config

ADD https://github.com/theLemonday/cheats.git /root/.local/share/navi/cheats/

CMD ["/bin/zsh"]
