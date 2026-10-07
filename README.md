# ada-remote

Connects a Linux machine (a VPS, a cloud GPU, a server under your desk) to an
Ada desktop.

## Connect a machine

On your desktop, open **Files → Machines → Connect a machine** and copy the
line it shows. Run it on the machine, or paste it into your provider's
startup script:

```sh
curl -fsSL https://github.com/Ifesol-backup/ada-remote/releases/latest/download/install.sh | sh -s -- <invite>
```

The machine prints three words. Approve it on your desktop when the card there
shows the same three words. An invite works once, for an hour.

## What you get

- The machine shows up in Files with live GPU, CPU, memory and disk, its web
  apps (Jupyter, ComfyUI, Gradio, Ollama and others, found on their own) and
  its terminals.
- Its files as a folder on your desktop: Files and any app open, edit and
  save them directly. A file reaches the machine whole when it's closed.
- Project folders kept in step both ways. A file changed on both sides is
  never overwritten: you pick which to keep, or keep both. What sync
  replaces or deletes is kept for a week.
- Web apps open in your desktop's browser with no port forwarding.
- Terminals keep running on the machine when your desktop sleeps or the
  connection drops, and pick up exactly where they were.
- It updates itself when your desktop asks (and waits for you while
  terminals are running, since an update restarts them).

## How it connects

- An encrypted QUIC connection ([iroh](https://iroh.computer)) between your
  desktop's key and the machine's. The machine accepts only the desktop it was
  approved by.
- Nothing listens on a public port, and no root is needed, so it works inside
  containers (RunPod, Vast.ai) as well as on VMs.
- It runs as a systemd service where there is one, and keeps itself running
  in containers. Running the install line again (for example from a startup
  script) is safe.

## On the machine

```sh
ada-remote status   # which desktop it belongs to
ada-remote leave    # forget the desktop and stop
```

Its files live in `~/.local/share/ada-remote`, or `/workspace/.ada-remote` in
containers that have a persistent `/workspace`.

## Releases

Static binaries for x86_64 and aarch64 Linux, each with a SHA-256 checksum
that `install.sh` checks before running anything.
