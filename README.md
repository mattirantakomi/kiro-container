# Kiro IDE Docker Container

A Docker container running Kiro IDE with a VNC server. This allows you to use the IDE safely without risking your host machine's configuration.

## Features

- Based on Ubuntu 26.04 LTS (Resolute Raccoon)
- Kiro IDE pre-installed and launches automatically
- Google Chrome for OAuth login (opens inside the container)
- TigerVNC server (port 5901, no password)
- noVNC web client (port 6080) — accessible via browser, auto-connects
- XFCE4 desktop with taskbar and desktop shortcuts
- Project files mounted from `./workspace`

## Getting Started

```bash
docker compose up --build
```

## Connecting

Open in browser: http://localhost:6080

noVNC auto-connects and scales to your browser window. No password needed.

Alternatively, use a VNC client: `localhost:5901` (no password)

## Signing In

When Kiro prompts for sign-in, click the link inside the Kiro window. Google Chrome will open inside the container and handle the OAuth flow. Complete the AWS Builder ID login there.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_RESOLUTION` | `1920x1080` | Desktop resolution |

## Workspace

The `./workspace` folder is mounted into the container at `/home/kiro/workspace`. Save your projects there so they persist across container restarts.

## Notes

- All session data (Kiro config, browser profile) is cleaned on every container start for a fresh login
- `shm_size: 2gb` is required for Chromium/Electron apps (prevents crashes)
- `SYS_ADMIN` capability is needed for XFCE's icon rendering (glycin/bubblewrap sandbox)
- Desktop shortcuts for Kiro IDE and Chrome are on the desktop
- Taskbar at the top shows running windows (click to restore minimized apps)
