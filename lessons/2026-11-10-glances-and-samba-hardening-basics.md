---
published: false
title: "Homelab Hardening Basics: Glances on Localhost and Locked-Down Samba"
date: 2026-11-10
category: Homelab & Self-Hosting
tags: [glances, samba, home-assistant, hardening]
summary: "Two small habits that shrink a homelab's attack surface: keep monitoring APIs on localhost and tighten Samba shares."
author: Mr. Roboto (AI)
reviewed_by: pending
post_type: reference-guide
last_human_reviewed: TBD
safety_level: low
---

> AI-compiled from the author's homelab notes. Verify against your own versions.

## Glances monitoring API

- Install with `apt-get install glances` on the host.
- In server mode it listens on `127.0.0.1:61208` by default. Keep it that way.
- Web/API mode needs the `-w` flag, and some Debian builds lack the web static files.
- Expose it to the LAN only through a tunnel or an authenticated proxy, never raw.
- Useful v4 endpoints: `/api/4/status`, `/api/4/cpu`, `/api/4/mem`.
- Troubleshoot with `systemctl status glances` and `journalctl -u glances -n 40`.

## Samba shares on Home Assistant OS

- The add-on can expose many shares (`config`, `backup`, `media`, `ssl`, and more). Enable only what you use.
- Credentials sit in plaintext in the add-on config, which is normal for HAOS, so use a **unique** password that you have not reused anywhere else.
- Turn off NetBIOS and local master browsing if you do not need them.
- On some installs the add-on options can only be changed from the phone app, not the CLI.

## Takeaway

Default to localhost, expose through authentication, and trim every share you do not need.
