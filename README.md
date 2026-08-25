# Kiro IDE Docker Container

A Docker container running Kiro IDE with a VNC server. This allows you to use the IDE safely without risking your host machine's configuration.

## Features

- Based on Ubuntu 26.04 LTS (Resolute Raccoon)
- Kiro IDE pre-installed
- TigerVNC server (port 5901)
- noVNC web client (port 6080) — accessible via browser
- XFCE4 desktop environment (lightweight)
- Project files mounted from `./workspace`

## Getting Started

```bash
docker compose up --build
```

## Connecting

### Via Browser (noVNC)

Open: http://localhost:6080

### Via VNC Client

Connect to: `localhost:5901` (no password)

## Kiro IDE

Kiro IDE launches automatically when the container starts. If you need to restart it manually, open a terminal in the desktop and run:

```bash
kiro --no-sandbox
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_RESOLUTION` | `1920x1080` | Desktop resolution |

## Workspace

The `./workspace` folder is mounted into the container at `/home/kiro/workspace`. Save your projects there so they persist across container restarts.

## Notes

- `shm_size: 2gb` is important for Chromium/Electron-based apps (prevents crashes)
- `seccomp=unconfined` is needed for Electron sandbox to work inside the container
- `--no-sandbox` flag is required to run Kiro IDE inside Docker
- Kiro requires an AWS account for sign-in (browser-based OAuth)
