FROM archlinux:latest

# Metadata labels for container registry
LABEL org.opencontainers.image.title="nealcontainer"
LABEL org.opencontainers.image.description="Arch Linux development container with zsh, starship, neovim, and development tools configured for VS Code devcontainers"
LABEL org.opencontainers.image.source="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.url="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.documentation="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.vendor="Nvveen"
LABEL org.opencontainers.image.licenses="MIT"

# Install sudo
RUN pacman -Syu --noconfirm sudo zsh starship git curl neovim otf-droid-nerd stow \
    openssh

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
RUN mkdir -p /home/vscode/.ssh/

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
