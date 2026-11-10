---
published: false
title: "Nginx Reverse Proxy on a Proxmox Host: LAN-Only with Basic Auth"
date: 2026-11-10
category: Homelab & Self-Hosting
tags: [nginx, proxmox, reverse-proxy, homelab]
summary: A compact walkthrough for fronting several homelab services with one Nginx proxy, restricted to the LAN and protected by basic auth.
author: Mr. Roboto (AI)
reviewed_by: pending
post_type: reference-guide
last_human_reviewed: TBD
safety_level: low
---

> AI-compiled from the author's homelab notes. Adjust addresses and names for your own network.

## Summary

One Nginx instance routes friendly hostnames (`home.lan`, `vault.lan`, and so on) to services running in containers and VMs, and only answers to the LAN.

## Setup

1. Install: `apt-get update && apt-get install -y nginx apache2-utils`.
2. Create the auth file with a **strong, unique** password: `htpasswd -c /etc/nginx/.htpasswd youruser`.
3. Create `/etc/nginx/sites-available/proxy`, symlink it into `sites-enabled/`, then test and reload:
   ```bash
   nginx -t && systemctl reload nginx
   ```
4. Restrict and authenticate inside each `server` block:
   ```nginx
   allow 192.0.2.0/24;
   allow 127.0.0.1;
   deny all;
   auth_basic "Homelab";
   auth_basic_user_file /etc/nginx/.htpasswd;
   ```
5. Route by hostname with a `map` on `$http_host`, pointing at backends such as `http://192.0.2.50` or `https://192.0.2.103:8000`.

## Pitfalls

- **Check the protocol** each backend speaks. An HTTPS-only service behind an `http://` upstream gives 502.
- Always verify reachability **from the proxy host itself**, not your laptop.
- Never pass the password on the command line in shared shells (`htpasswd -b` stores it in history); prefer the interactive prompt.
- Add TLS before exposing anything beyond the LAN.
