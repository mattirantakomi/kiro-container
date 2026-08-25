FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for Kiro IDE, VNC, and a lightweight desktop
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    gnupg \
    # VNC server and lightweight desktop
    tigervnc-standalone-server \
    tigervnc-common \
    dbus-x11 \
    xfce4 \
    xfce4-terminal \
    # Kiro/Electron dependencies
    libasound2t64 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    libxshmfence1 \
    libsecret-1-0 \
    libxss1 \
    xdg-utils \
    # Useful dev tools
    git \
    sudo \
    # noVNC for browser-based access (optional)
    novnc \
    websockify \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install Kiro IDE
ARG KIRO_VERSION=1.0.337
RUN wget -q "https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/${KIRO_VERSION}/deb/kiro-ide-${KIRO_VERSION}-stable-linux-x64.deb" \
    -O /tmp/kiro-ide.deb \
    && dpkg -i /tmp/kiro-ide.deb || apt-get install -f -y \
    && rm /tmp/kiro-ide.deb

# Create non-root user
RUN useradd -m -s /bin/bash -G sudo kiro \
    && echo "kiro ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER kiro
WORKDIR /home/kiro

# Set up VNC password (default: "kiro123", change via VNC_PASSWORD env var)
RUN mkdir -p /home/kiro/.vnc \
    && echo "kiro123" | vncpasswd -f > /home/kiro/.vnc/passwd \
    && chmod 600 /home/kiro/.vnc/passwd

# VNC startup config
COPY --chown=kiro:kiro xstartup /home/kiro/.vnc/xstartup
RUN chmod +x /home/kiro/.vnc/xstartup

# Workspace directory for projects
RUN mkdir -p /home/kiro/workspace

# Expose VNC port and noVNC port
EXPOSE 5901 6080

# Entrypoint script
COPY --chown=kiro:kiro entrypoint.sh /home/kiro/entrypoint.sh
RUN chmod +x /home/kiro/entrypoint.sh

ENTRYPOINT ["/home/kiro/entrypoint.sh"]
