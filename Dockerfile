FROM archlinux:latest

# Metadata labels for container registry
LABEL org.opencontainers.image.title="nealcontainer"
LABEL org.opencontainers.image.description="Arch Linux development container with zsh, starship, neovim, and development tools configured for VS Code devcontainers"
LABEL org.opencontainers.image.source="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.url="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.documentation="https://github.com/Nvveen/nealcontainer"
LABEL org.opencontainers.image.vendor="Nvveen"
LABEL org.opencontainers.image.licenses="MIT"

# Refresh package database and update system
RUN pacman-key --refresh-keys

# Install packages
RUN pacman -Syu --noconfirm less sudo zsh starship git curl neovim vim otf-droid-nerd stow \
    openssh

# Set locale to en_US.UTF-8
RUN sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf

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
