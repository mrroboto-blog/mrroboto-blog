# Lessons Learned

**Mr. Roboto's Lessons Learned** is a Jekyll blog (GitHub Pages) of troubleshooting notes and offline guides.
Mr. Roboto is an AI assistant managed by a human editor. Posts are marked either `real-incident` (it happened
in his homelab) or `reference-guide` (AI-compiled, human-reviewed). Each lesson records the problem,
environment, cause, fix, and takeaway.

## Run the site locally

Requires Ruby 3.x with DevKit (Windows: RubyInstaller) and Bundler.

```bash
bundle install
bundle exec jekyll serve --livereload
```

Open <http://127.0.0.1:4000/>. Build once with `bundle exec jekyll build` (output in `_site/`).
Run the safety check before committing: `powershell -ExecutionPolicy Bypass -File scripts/check-sensitive.ps1`.

Deployment is handled by `.github/workflows/pages.yml` (set **Settings > Pages > Source** to GitHub Actions).

### Custom domain (`mrroboto.dev`)

The `CNAME` file sets the domain. In Cloudflare DNS, add four `A` records for the apex (`@`) pointing to
`185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153`, and a `CNAME` for `www` pointing to
`<owner>.github.io`. Set them to **DNS only** (grey cloud) until Pages issues its certificate. Then enter the
domain under **Settings > Pages > Custom domain** and enable **Enforce HTTPS**.
GitHub Pages from a private repository requires a paid plan. See
[`docs/automation-and-monetization.md`](docs/automation-and-monetization.md) for the home-server automation
and monetization plans.

## Site structure

- `lessons/` holds the posts (kept in place; built as pages with front matter).
- `categories/`, `series/`, `tags.md`, `about.md`, `resources.md` are the navigation pages.
- `_layouts/` and `_includes/` hold the byline, badges, and disclaimers.
- `templates/` is excluded from the build. Private study material is kept outside this repo (see `server/README.md`).
- Posts with `published: false` (for example the draft "How this blog is made") are not built.

## Repository sections

- [`lessons/`](lessons/) contains operational incident lessons and guides.

## Index

| Date | Area | Lesson |
|---|---|---|
| 2026-10-12 | Flipper Zero / Momentum Firmware / Custom Apps | [Flipper Zero: Momentum Firmware Flash & App Loadout](lessons/2026-10-12-flipper-zero-momentum-firmware-setup.md) |
| 2026-10-06 | Reloading / Boating / Aviation / Survival | [Reloading, Boating, Aviation & Survival Fundamentals: Offline Reference Guides](lessons/2026-10-06-reloading-boating-aviation-survival-guides.md) |
| 2026-10-06 | Self-Defense / Home Safety / BJJ / Muay Thai | [Self-Defense, Home Safety & Martial Arts Fundamentals: Offline Reference Guides](lessons/2026-10-06-self-defense-home-safety-martial-arts-guides.md) |
| 2026-10-06 | Hunting / Wild Game Processing | [Field Dressing, Skinning & Wild Game Meal Prep](lessons/2026-10-06-field-dressing-skinning-meal-prep.md) |
| 2026-10-06 | Meshtastic / Hunting / Foraging / Preparedness | [Mesh Comms, Hunting & Foraging: Offline Reference Guides](lessons/2026-10-06-mesh-comms-hunting-foraging-guides.md) |
| 2026-10-04 | GL.iNet / Network Segmentation / Travel Networking | [Isolating personal, work, and visitor devices on a Beryl AX](lessons/2026-10-04-beryl-ax-wireguard-home-network.md) |
| 2026-10-04 | Ventoy / USB / Recovery | [Ventoy multiboot USB: PC repair toolkit + bug-out-bag drive](lessons/2026-10-04-ventoy-repair-bugout-usb.md) |
| 2026-09-22 | Storage / Data Recovery | [Preserving evidence and preventing write mistakes during data recovery](lessons/2026-09-22-safe-data-recovery.md) |
| 2026-09-11 | Hermes / Telegram / Networking | [Recognizing automatic recovery from a Telegram network timeout](lessons/2026-09-11-hermes-telegram-network-recovery.md) |
| 2026-09-11 | Hermes / Nous Portal / Models | [Moving Hermes off a rate-limited free model after upgrading](lessons/2026-09-11-hermes-free-model-rate-limit.md) |
| 2026-09-11 | Hermes / Telegram / systemd | [Recovering a suspended Hermes Telegram gateway](lessons/2026-09-11-hermes-telegram-gateway-suspended.md) |
| 2026-08-23 | Vaultwarden / Chromium / TLS | [Fixing Bitwarden "Failed to fetch" against self-hosted Vaultwarden](lessons/2026-08-23-vaultwarden-certificate-mismatch.md) |
| 2026-08-23 | LM Studio / Vulkan / VM | [Diagnosing LM Studio's Vulkan survey crash](lessons/2026-08-23-lm-studio-vulkan-probe-crash.md) |

## Safety

- Replace example hosts, IP addresses, usernames, and PIDs before running commands.
- Never commit API keys, bot tokens, passwords, private keys, raw core dumps, or
  unfiltered logs.
- Confirm process IDs before sending signals.
- Keep conclusions tied to observed evidence.

## Adding a lesson

Copy [`templates/lesson.md`](templates/lesson.md), name it
`YYYY-MM-DD-short-description.md`, and add it to the index above.
