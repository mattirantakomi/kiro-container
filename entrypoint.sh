#!/bin/bash
set -e

# Clean all previous sessions/auth data on every start
rm -rf /home/kiro/.mozilla
rm -rf /home/kiro/.config/Kiro
rm -rf /home/kiro/.config/chromium
rm -rf /home/kiro/.config/tigervnc/*.log
rm -rf /tmp/firefox-kiro

# Ensure TigerVNC config directory exists
mkdir -p /home/kiro/.config/tigervnc

# Set display resolution (default 1920x1080)
RESOLUTION=${VNC_RESOLUTION:-1920x1080}

# Start VNC server without password (SecurityTypes=None)
vncserver :1 -geometry "$RESOLUTION" -depth 24 -localhost no -SecurityTypes None --I-KNOW-THIS-IS-INSECURE -xstartup /home/kiro/.vnc/xstartup

# Start noVNC (web-based VNC client) for browser access
websockify --web=/usr/share/novnc/ --heartbeat=30 0.0.0.0:6080 localhost:5901 &

echo "============================================"
echo " Kiro IDE Docker Container Running"
echo "============================================"
echo " Browser:    http://localhost:6080"
echo " VNC client: localhost:5901 (no password)"
echo " Resolution: $RESOLUTION"
echo "============================================"

# Keep container running
sleep 2
tail -f /home/kiro/.vnc/*.log /home/kiro/.config/tigervnc/*.log 2>/dev/null || sleep infinity
