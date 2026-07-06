# Claude Science in Docker

A Dockerfile for running [Claude Science](https://claude.com/product/claude-science)
in a container, for anyone whose host OS ships an old `bubblewrap` (Claude
Science's sandbox needs ≥0.8.0, but Ubuntu 22.04 and similar only have 0.6.1).

**This repo does not contain or distribute the Claude Science binary.**
Building the image downloads it fresh, directly from Anthropic's servers,
under your own account — this repo is just the recipe.

## Requirements

- Docker (Docker Desktop or the Docker Engine CLI)
- A **Claude Pro, Max, Team, or Enterprise** subscription. Claude Science
  does not work on the free plan — the container will build and run fine,
  but sign-in will fail without a qualifying plan.

## Build

```bash
git clone https://github.com/srssina/claude-science-docker
cd claude-science-docker
docker build -t claude-science .
```

## Run

```bash
docker run -d \
  --name claude-science \
  -p 8765:8765 \
  --cap-add=SYS_ADMIN \
  --security-opt apparmor=unconfined \
  --security-opt seccomp=unconfined \
  --security-opt systempaths=unconfined \
  -v ~/claude-science-data:/root/.claude-science \
  claude-science
```

The volume mount keeps your projects and settings persistent across
container restarts.

## Sign in

Get a one-time login link (expires in 3 minutes, so open it right away):

```bash
docker exec -it claude-science claude-science url
```

Open the printed URL in your browser and sign in with your claude.ai account.

## Why the container needs those extra flags

Claude Science sandboxes its own tool execution using `bwrap` (bubblewrap),
which itself needs to create a nested Linux sandbox *inside* the Docker
container. Docker's default hardening blocks several things bwrap needs:

| Flag | Why it's needed |
|---|---|
| `--cap-add=SYS_ADMIN` | bwrap needs this capability to create namespaces |
| `--security-opt apparmor=unconfined` | Docker's default AppArmor profile blocks bwrap's `pivot_root` |
| `--security-opt seccomp=unconfined` | Docker's default seccomp profile blocks syscalls bwrap needs |
| `--security-opt systempaths=unconfined` | Docker masks `/proc/sys/user/max_user_namespaces` read-only by default; bwrap needs to read it |

This is real relaxation of the container's own isolation — reasonable for a
personal/local setup, but worth knowing if you're running this on a shared
or untrusted host.
