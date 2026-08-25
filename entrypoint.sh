#!/bin/bash
set -e

# Update VNC password if VNC_PASSWORD env var is set
if [ -n "$VNC_PASSWORD" ]; then
    echo "$VNC_PASSWORD" | vncpasswd -f > /home/kiro/.vnc/passwd
    chmod 600 /home/kiro/.vnc/passwd
fi

# Set display resolution (default 1920x1080)
RESOLUTION=${VNC_RESOLUTION:-1920x1080}

# Start VNC server
vncserver :1 -geometry "$RESOLUTION" -depth 24 -localhost no

# Start noVNC (web-based VNC client) for browser access
# --heartbeat keeps the connection alive
websockify --web=/usr/share/novnc/ --heartbeat=30 6080 localhost:5901 &

echo "============================================"
echo " Kiro IDE Docker Container Running"
echo "============================================"
echo " Selaimella: http://localhost:6080/vnc.html?autoconnect=true&resize=remote&password=kiro123"
echo " VNC client: localhost:5901 (salasana: kiro123)"
echo " Resoluutio: $RESOLUTION"
echo "============================================"

# Keep container running
tail -f /home/kiro/.vnc/*:1.log
