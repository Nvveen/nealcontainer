FROM archlinux:latest

# Metadata labels for container registry
LABEL org.opencontainers.image.title="nealcontainer"
LABEL org.opencontainers.image.description="Arch Linux development container with zsh, starship, neovim, and development tools configured for VS Code devcontainers"
LABEL org.opencontainers.image.source="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.url="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.documentation="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.vendor="Nvveen"
LABEL org.opencontainers.image.licenses="MIT"

# Fix keyring issues and update system
RUN pacman -Sy --noconfirm --disable-download-timeout archlinux-keyring && \
    rm -rf /etc/pacman.d/gnupg && \
    pacman-key --init && \
    pacman-key --populate archlinux

# Install packages
RUN pacman -Syu --noconfirm less sudo zsh starship git curl neovim vim otf-droid-nerd stow \
    openssh jq \
    ripgrep fd bat eza bottom git-delta zoxide fzf

# Set locale to en_US.UTF-8 and enable en_US/nl_NL variants
RUN sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
  sed -i 's/^#nl_NL.UTF-8/nl_NL.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Set LANG environment variable for the container
ENV LANG=en_US.UTF-8

# Set NEALARCH to identify this as a nealcontainer environment
ENV NEALARCH=1

# Create vscode user with sudo privileges
RUN useradd -m -s /bin/bash vscode && \
    usermod -aG wheel vscode && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    chsh -s /usr/bin/zsh vscode

# Fix machine-id for systemd
RUN touch /etc/machine-id

# Switch to vscode user
USER vscode

RUN touch /home/vscode/.zshrc
RUN mkdir -p /home/vscode/.ssh/ /home/vscode/.local/custom && \
    chown -R vscode:vscode /home/vscode/.ssh/ /home/vscode/.local/custom

VOLUME /home/vscode/.local/custom

LABEL devcontainer.metadata='{ \
  "remoteUser": "vscode", \
  "customizations": { \
    "vscode": { \
      "extensions": [ \
        "foxundermoon.shell-format" \
      ], \
      "settings": { \
        "terminal.integrated.defaultProfile.linux": "zsh" \
      } \
    } \
  } \
}'
