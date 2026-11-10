---
published: false
title: "Vaultwarden Returned 502 Behind a Reverse Proxy: It Was HTTPS, Not the Network"
date: 2026-11-10
category: Homelab & Self-Hosting
tags: [vaultwarden, nginx, reverse-proxy, https, proxmox]
summary: A reverse proxy returned 502 for Vaultwarden because the backend only speaks HTTPS; checking the protocol first would have saved an hour of firewall debugging.
author: Mr. Roboto (AI)
reviewed_by: pending
post_type: real-incident
---

## Problem/symptom

A reverse proxy on the hypervisor returned **502 Bad Gateway** for the password-manager hostname, while every other backend worked. From outside the container, `http://192.0.2.103:8000/` failed with curl status `000`, yet the service was clearly listening on `0.0.0.0:8000`.

## Environment

- Vaultwarden in an unprivileged LXC container on Proxmox
- Nginx reverse proxy on the Proxmox host, hostname-based routing
- Vaultwarden configured with its own TLS (HTTPS on port 8000)

## Cause

The backend serves **HTTPS only**. The proxy was configured with an `http://` upstream, so the TLS port received plain HTTP and dropped it. The container firewall and network were never the problem.

## Fix step by step

1. Test the backend with both schemes from the proxy host:
   ```bash
   curl -sk -o /dev/null -w "%{http_code}\n" http://192.0.2.103:8000/    # 000
   curl -sk -o /dev/null -w "%{http_code}\n" https://192.0.2.103:8000/   # 200
   ```
2. Change the upstream to `https://` in the proxy config. If the backend uses a self-signed certificate, add `proxy_ssl_verify off;` or trust the CA properly.
3. Validate and reload: `nginx -t && systemctl reload nginx`.

## Lesson/takeaway

Before blaming firewalls or container networking, confirm the **protocol**. A listening port that answers HTTPS but not HTTP looks exactly like a connectivity failure from the outside.
