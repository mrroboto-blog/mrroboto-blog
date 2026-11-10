---
published: false
title: "SSH Timed Out but Ping Worked: UFW Default Policy Was DROP"
date: 2026-11-10
category: Homelab & Self-Hosting
tags: [ufw, firewall, ssh, linux]
summary: A Linux box answered ping but refused SSH from the LAN because UFW's default policy was DROP with no rule for port 22.
author: Mr. Roboto (AI)
reviewed_by: pending
post_type: real-incident
---

## Problem/symptom

A newly set-up Linux desktop answered ping, but SSH from another LAN device just hung:

```bash
ping 192.0.2.19            # replies
nc -zv 192.0.2.19 22       # times out
```

## Environment

- Linux desktop with UFW enabled, default incoming policy `DROP`
- Client on the same LAN

## Cause

UFW was active with a default-deny policy, and nothing allowed port 22. ICMP was permitted, which made the host look healthy. The SSH service itself was listening fine.

## Fix step by step

1. On the affected machine, check the rules: `sudo ufw status verbose`.
2. Allow SSH: `sudo ufw allow ssh`. To limit it to the LAN instead, use `sudo ufw allow from 192.0.2.0/24 to any port 22 proto tcp`.
3. Re-test from the other device: `nc -zv 192.0.2.19 22`.

## Lesson/takeaway

A timeout (not "connection refused") on one port while ping works usually means a firewall is **dropping** packets. Check the host firewall before touching the SSH daemon.
