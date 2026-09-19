# Kiro IDE Docker Container

A Docker container running Kiro IDE with a VNC server and xpra support. This allows you to use the IDE safely without risking your host machine's configuration.

## Features

- Based on Ubuntu 26.04 LTS (Resolute Raccoon)
- Kiro IDE pre-installed and launches automatically
- Google Chrome for OAuth login (opens inside the container)
- TigerVNC server (port 5901, no password)
- noVNC web client (port 6080) — accessible via browser, auto-connects
- **Xpra** (port 14500) — forwards just the Kiro window into your host desktop natively
- XFCE4 desktop with taskbar and desktop shortcuts
- Project files mounted from `./workspace`

## What is Kiro?

Kiro is an agentic IDE developed by AWS, built on top of VS Code. It goes beyond a typical AI copilot: instead of just completing code, it plans, implements, and verifies work autonomously.

### Key features

**Autopilot mode**
Kiro works independently on large tasks without step-by-step guidance. It can read the codebase, make changes across multiple files, run terminal commands, and fix errors iteratively — all while you watch the changes and can revert or interrupt at any time. The alternative is **Supervised mode**, where Kiro asks for approval before each change, presenting diffs as individual hunks you can accept or reject.

**Spec-driven development**
In spec sessions, Kiro turns a free-form description into requirements, then an architecture design, then a sequenced task list — which it implements autonomously. This approach produces more maintainable code and works especially well for complex features.

**Agents and hooks**
Kiro supports custom agents (`.kiro/agents/`) that can be triggered automatically by events — file save, session start, task completion, and more. This enables things like automatic linting or test runs without any manual trigger.

**Steering files**
Project-specific instructions, coding standards, and context can be written to `.kiro/steering/*.md` files, which Kiro reads automatically in every session.

**MCP support**
Model Context Protocol servers can be attached to Kiro, giving the agent access to external tools and data sources (databases, APIs, documentation, etc.).

**Other highlights**
- Attach images and documents to chat (e.g. UI mockup → implementation)
- Real-time code change diffs as the agent works
- One-click commit message generation from the source control panel
- Intelligent error diagnostics for syntax, type, and semantic errors
- Per-prompt credit usage shown in real time

### Supported language models

Kiro provides access to frontier and open-weight models from Anthropic, OpenAI, and other providers. The model can be changed per session:

| Model | Description |
|-------|-------------|
| **Auto** | Default — routes automatically to frontier models (Sonnet + specialized models) to balance quality, latency, and cost |
| **Claude Opus 4.8** | Reliable top-tier model for demanding coding and reasoning tasks |
| **Claude Sonnet 5** | Fast and balanced, approaches Opus-level quality with better token efficiency |
| **Claude Sonnet 4.5** | Available on the free tier |
| **GPT-5.6 Sol** | OpenAI's flagship model — top benchmark results for long multi-step tasks (272K context) |
| **GPT-5.6 Terra** | Balanced alternative to Sol at a lower cost |
| **GPT-5.6 Luna** | Most cost-efficient OpenAI option, still outperforms Opus 4.8 on coding benchmarks |
| **Qwen3 Coder Next** | Open-weight model, available on all plans |
| **DeepSeek 3.2** | Open-weight model, available on all plans |
| **MiniMax M2.1** | Open-weight model with multilingual support, available on all plans |

> Model availability varies by subscription tier and region. The free tier includes Claude Sonnet 4.5 and the open-weight models.

## Getting Started

```bash
docker compose up --build
```

## Connecting

### Xpra — native window forwarding (recommended)

Xpra forwards the Kiro IDE window directly into your Ubuntu desktop. The window behaves like any local app: it gets its own taskbar entry, you can resize it, alt-tab to it, etc.

**Install xpra on your Ubuntu host** (once):

> **Important:** Use the official xpra.org repository, not the Ubuntu package. Ubuntu 22.04's
> default package is version 3.x, but the container runs version 6.x — the version mismatch
> causes a `disconnect invalid compression: zlib is not available` error on connect.

```bash
# Find your Ubuntu codename:
# jammy = 22.04, noble = 24.04, oracular = 24.10, resolute = 26.04
DISTRO="jammy"   # <-- change this to match your Ubuntu version

# Remove the old Ubuntu package if installed
sudo apt remove -y xpra 2>/dev/null || true

# Add the official xpra.org repository
sudo apt install -y ca-certificates wget
sudo wget -O /usr/share/keyrings/xpra.asc https://xpra.org/xpra.asc
sudo wget -O /etc/apt/sources.list.d/xpra.sources \
    "https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/${DISTRO}/xpra.sources"
sudo apt update && sudo apt install -y xpra
```

**Connect:**

```bash
xpra attach tcp://localhost:14500
```

The Kiro IDE window appears on your desktop. Close the xpra client to disconnect (the container keeps running).

### noVNC — browser access

```
http://localhost:6080
```

Auto-connects and scales to your browser window. No password needed.

### VNC client

```
localhost:5901  (no password)
```

## Signing In

When Kiro prompts for sign-in, click the link inside the Kiro window. Google Chrome will open inside the container and handle the OAuth flow. Complete the AWS Builder ID login there.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VNC_RESOLUTION` | `1920x1080` | Desktop resolution (VNC/noVNC) |
| `XPRA_PORT` | `14500` | TCP port for the xpra server |

## Workspace

The `./workspace` folder is mounted into the container at `/home/kiro/workspace`. Save your projects there so they persist across container restarts.

## Notes

- All session data (Kiro config, browser profile) is cleaned on every container start for a fresh login
- `shm_size: 2gb` is required for Chromium/Electron apps (prevents crashes)
- `SYS_ADMIN` capability is needed for XFCE's icon rendering (glycin/bubblewrap sandbox)
- Desktop shortcuts for Kiro IDE and Chrome are on the desktop
- Taskbar at the top shows running windows (click to restore minimized apps)
- Xpra runs on display `:2` separately from VNC (`:1`), so both can be used simultaneously
