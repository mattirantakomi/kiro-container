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
    # SVG/icon rendering (needed for XFCE panel)
    librsvg2-common \
    glib-networking \
    # Useful dev tools
    git \
    sudo \
    # Clipboard support for noVNC copy-paste
    xclip \
    xsel \
    # Browser for OAuth login
    # (chromium-browser is snap stub on Ubuntu 26.04, installed separately below)
    fonts-liberation \
    # noVNC for browser-based access (optional)
    novnc \
    websockify \
    # Xpra dependencies (xpra itself installed from official repo below)
    apt-transport-https \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Update icon/pixbuf caches (prevents crashes in XFCE panel)
# Remove glycin-loaders which uses bwrap sandbox (crashes in Docker), reinstall XFCE deps
RUN apt-get update && \
    apt-get remove -y glycin-loaders glycin-thumbnailers libglycin-2-0 && \
    apt-get install -y --fix-broken xfce4 xfce4-terminal librsvg2-2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
RUN gdk-pixbuf-query-loaders > /usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache 2>/dev/null || true
RUN gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true

# Install Xpra from official repo (Ubuntu 26.04 = "resolute")
RUN apt-get update && apt-get install -y ca-certificates wget && \
    wget -O /usr/share/keyrings/xpra.asc https://xpra.org/xpra.asc && \
    DISTRO="resolute" && \
    wget -O /etc/apt/sources.list.d/xpra.sources \
        "https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/${DISTRO}/xpra.sources" && \
    apt-get update && apt-get install -y xpra && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Google Chrome (real browser, not snap stub)
RUN wget -q -O /tmp/chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && \
    apt-get update && apt-get install -y /tmp/chrome.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && rm /tmp/chrome.deb

# Set noVNC defaults: autoconnect, remote resize, fullscreen-like viewport
RUN sed -i "s/UI.initSetting('autoconnect', false)/UI.initSetting('autoconnect', true)/" /usr/share/novnc/app/ui.js && \
    sed -i "s/UI.initSetting('resize', 'off')/UI.initSetting('resize', 'remote')/" /usr/share/novnc/app/ui.js && \
    sed -i "s/UI.initSetting('reconnect', false)/UI.initSetting('reconnect', true)/" /usr/share/novnc/app/ui.js && \
    sed -i "s/UI.initSetting('reconnect_delay', 5000)/UI.initSetting('reconnect_delay', 1000)/" /usr/share/novnc/app/ui.js
COPY novnc-index.html /usr/share/novnc/index.html

# Download and install Kiro IDE
ARG KIRO_VERSION=1.0.337
RUN wget -q "https://prod.download.desktop.kiro.dev/releases/stable/linux-x64/signed/${KIRO_VERSION}/deb/kiro-ide-${KIRO_VERSION}-stable-linux-x64.deb" \
    -O /tmp/kiro-ide.deb \
    && dpkg -i /tmp/kiro-ide.deb || apt-get install -f -y \
    && rm /tmp/kiro-ide.deb

# Create non-root user
RUN useradd -m -s /bin/bash -G sudo kiro \
    && echo "kiro ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Kiro CLI (for device code login flow)
RUN apt-get update && apt-get install -y unzip && apt-get clean && rm -rf /var/lib/apt/lists/*
USER kiro
RUN curl -fsSL https://cli.kiro.dev/install | bash || true
USER root
RUN if [ -f /home/kiro/.local/bin/kiro-cli ]; then ln -sf /home/kiro/.local/bin/kiro-cli /usr/local/bin/kiro-cli; fi

USER kiro
WORKDIR /home/kiro

# Set up VNC and xpra directories
RUN mkdir -p /home/kiro/.vnc /home/kiro/.config/tigervnc /home/kiro/Desktop \
    /home/kiro/.config/xfce4/xfconf/xfce-perchannel-xml \
    /home/kiro/.xpra

# VNC startup config
COPY --chown=kiro:kiro xstartup /home/kiro/.vnc/xstartup
RUN chmod +x /home/kiro/.vnc/xstartup

# Set Firefox as default browser so Kiro login links open correctly
ENV BROWSER="google-chrome --no-sandbox"
COPY --chown=kiro:kiro google-chrome.desktop /home/kiro/.local/share/applications/google-chrome.desktop
COPY --chown=kiro:kiro helpers.rc /home/kiro/.config/xfce4/helpers.rc
RUN xdg-mime default google-chrome.desktop x-scheme-handler/http && \
    xdg-mime default google-chrome.desktop x-scheme-handler/https

# Workspace directory for projects
RUN mkdir -p /home/kiro/workspace

# Desktop shortcuts
COPY --chown=kiro:kiro desktop-icons/Kiro.desktop /home/kiro/Desktop/Kiro.desktop
COPY --chown=kiro:kiro desktop-icons/Chrome.desktop /home/kiro/Desktop/Chrome.desktop
RUN chmod +x /home/kiro/Desktop/*.desktop

# Panel config (taskbar with window list)
COPY --chown=kiro:kiro panel-config/xfce4-panel.xml /home/kiro/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
COPY --chown=kiro:kiro panel-config/xfce4-desktop.xml /home/kiro/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

# Expose VNC port, noVNC port, and xpra port
EXPOSE 5901 6080 14500

# Entrypoint script
COPY --chown=kiro:kiro entrypoint.sh /home/kiro/entrypoint.sh
RUN chmod +x /home/kiro/entrypoint.sh

ENTRYPOINT ["/home/kiro/entrypoint.sh"]
