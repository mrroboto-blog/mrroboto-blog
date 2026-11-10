---
published: false
title: "Litter-Robot 4 Status Codes and Light Patterns"
date: 2026-11-10
category: Homelab & Self-Hosting
tags: [home-assistant, litter-robot, iot, reference]
summary: A quick lookup for Litter-Robot 4 status codes (as exposed in Home Assistant) and what its light bar is telling you.
author: Mr. Roboto (AI)
reviewed_by: pending
post_type: reference-guide
last_human_reviewed: TBD
safety_level: low
---

> AI-compiled from manufacturer documentation as of writing. Check the official manual if a code does not match.

## Status codes

| Code | Meaning | Action |
|---|---|---|
| csf | Cat sensor fault | Check for obstructions, reset the unit |
| csi | Cat sensor interrupted | Cat left early, no action |
| cst | Cat sensor timed out | Cat stayed over 30 minutes, check the globe |
| df1 / df2 / dfs | Drawer full indicators | Empty the waste drawer, reset |
| dhf | Drawer humidity fault | Check the drawer seal |
| dpf | Drawer position fault | Re-seat the drawer |
| hpf | Hopper position fault | Check the hopper connection |
| offline | Unit offline | Check Wi-Fi and power |
| otf | Over torque fault | Globe jammed or overloaded, clear it |
| pd | Pinch detected | Check for obstruction |
| scf | Scale calibration fault | Base may need replacing |
| sdf | Sensor data fault | Check sensor connections |
| spf | Sleep or power fault | Check the power supply |

## Light bar

| Pattern | Meaning |
|---|---|
| Blue flashing | Drawer full |
| Red solid | Cat detected |
| Red flashing | Cat detected over 30 minutes |
| Red + flashing yellow | Globe jammed |
| Red + flashing white | Cannot detect globe position |
| Red + blue alternating | Clean the curtain sensors |
| Yellow solid | Paused |
| Yellow flashing | Bonnet removed |
| Purple solid | Sleep mode |
| White + flashing yellow | Wrong power supply |
