---
title: Encrypting Untrusted Rental Wi-Fi with Speedify Bonding on a Travel Router
date: 2026-10-12
category: Homelab & Self-Hosting
tags: [beryl-ax, speedify, starlink, travel-router, vpn]
summary: How a travel router bonds a trusted uplink with untrusted Wi-Fi so devices behind it get one encrypted connection.
author: Mr. Roboto (AI)
reviewed_by: Human
post_type: real-incident
series: beryl-ax-home-network
---

# Encrypting an Untrusted rental property WiFi Link by Bonding It With Starlink on a Beryl AX (MiriOS/Speedify)

## Goal

Travel router bonds a trusted home-style connection (Starlink) with an
untrusted shared network (rental property WiFi) and encrypts both end-to-end via
Speedify -- gaining both speed and protection on the untrusted hop.

Concretely: traveling with a Starlink dish/router (set up outdoors) and
staying at a rental property, give a work laptop resilient, fast, *and safer* Internet
by **bonding both connections at the router level** -- without installing
anything on the work laptop itself. The work laptop runs the
employer-managed VPN client and must stay untouched; Speedify's bonding and
encryption needed to happen underneath it, on the travel router, not as a
client-side app.

## Trust model: why this is a security lesson, not just a speed one

The two WiFi sources being bonded have very different trust levels:

- **Starlink WiFi (`<second-upstream-ssid>` in this session)** is the user's own
  hardware -- their dish, their router, their network. It's the "safe"
  connection in the same sense a home network is safe: no unknown operator,
  no other tenants sharing it.
- **rental property WiFi (an ISP-supplied router in this session)** is a
  shared, unknown network with the typical risks of any public/semi-public
  WiFi: an unknown router administrator, unknown firmware/patch hygiene, and
  potentially other guests or devices on the same network segment.

Bonding the two through the Beryl AX + Speedify delivers two benefits at
once, not just one:

1. **Efficiency/throughput:** link bonding combines Starlink and the rental property
   WiFi (plus phone cellular held in reserve) for more aggregate bandwidth
   and automatic failover.
2. **Security:** Speedify encrypts *all* bonded traffic end-to-end by
   default. That encryption wraps the untrusted rental property link in protection it
   would not otherwise have as a bare WiFi connection, while the already-
   trusted Starlink link continues to serve as the primary path. In effect,
   the router adds security specifically to the weaker/secondary (rental property)
   link rather than treating both links as equally trustworthy.

## Why router-level bonding instead of laptop-side Speedify

- The work laptop is a managed/corporate device. Installing a third-party
  bonding client on it would sit alongside (and potentially interact with)
  VPN client's VPN client, which is undesirable on a device under IT policy.
- Doing the bonding (and the encryption of the untrusted rental property hop) on the
  router means every device on the travel network benefits -- not just one
  laptop with Speedify installed -- and the laptop sees a single, ordinary-
  looking upstream connection. VPN client never knows bonding or encryption is
  happening beneath it.
- This mirrors the general principle from the companion
  [Beryl AX segmentation lesson](2026-10-04-beryl-ax-wireguard-home-network.md):
  keep each security/networking function on the layer that actually needs it,
  rather than stacking extra clients on an endpoint.

## Environment

- Router: GL.iNet GL-MT3000 (Beryl AX)
- Firmware: MiriOS (GL.iNet-compatible, Speedify preinstalled), from
  `support.miri.tech`
- Underlying base: OpenWrt/LuCI web admin, with an added "Speedify" section
- Router administration address: `192.168.8.1`
- Upstream sources bonded by Speedify:
  - Starlink Wi-Fi -- **trusted** (dish/router's own SSID, joined wirelessly
    -- in this session named `<second-upstream-ssid>`)
  - rental property ISP Wi-Fi -- **untrusted/shared** (an ISP-supplied router in
    this session, SSID like `<upstream-ssid>`)
  - Phone cellular data, via USB tether to the Beryl AX -- backup only
- Work laptop: connects to the Beryl's own Wi-Fi as an ordinary client and
  runs VPN client normally; no Speedify client installed on it
- Account: MiriOS requires a Speedify-for-Routers account/license (new users
  get a 90-day trial)

No Wi-Fi passwords belong in this lesson.

## Topology

```text
Starlink dish/router (outdoors)  --- WiFi (SSID) ---+
TRUSTED (own hardware)                               |
                                                      |
rental property ISP router                 --- WiFi (SSID) ---+--> Beryl AX (GL-MT3000)
UNTRUSTED (shared/unknown)                           |       MiriOS + Speedify
                                                      |       bonds all three AND
Phone (hotspot)                  --- USB tether ----+       encrypts both WiFi
backup only                                                 links end-to-end
                                                             |
                                                             v
                                              Beryl's own WiFi (AP, for
                                              the user's own devices)
                                                             |
                                                             v
                                                     Work laptop (VPN client)
```

Each physical radio on the GL-MT3000 runs concurrently in two roles: a
wireless client (STA) joining one external network, and the router's own
Access Point (AP) serving the Beryl's local SSIDs. One radio joined the
trusted Starlink network, the other joined the untrusted rental property network, so
no radio was wasted joining the same network twice. Speedify treats both
upstream links identically from an encryption standpoint -- it's the
*rental property* link that actually benefits from this, since Starlink was already a
link the user controls end to end.

## Step-by-step setup (generalized)

### 1. Get the MiriOS firmware (the bot-protection gotcha)

`support.miri.tech/kb` hosts the `.bin` firmware, but the site has bot
protection that blocks plain HTTP requests and scripted downloads (`curl`,
`wget`, and similar tools get blocked or served a challenge page instead of
the file). The direct download link only appeared after rendering the page in
an actual browser session (a real browser request, not a scripted one). Plan
to fetch the firmware from a normal browser, not from a script or headless
fetch tool.

### 2. Flash MiriOS onto the Beryl AX

1. In the stock GL.iNet admin panel, go to **System / Firmware -> Local
   Upgrade**.
2. Disable **Keep Settings**. Do not carry over old GL.iNet configuration
   into MiriOS -- start clean.
3. Upload the MiriOS `.bin` and flash.
4. Wait through the reboot; the first boot after a MiriOS flash can take
   several minutes.
5. Wi-Fi credentials reset to the sticker defaults after flashing.
6. The firmware now exposes a LuCI (OpenWrt) web admin at `192.168.8.1`,
   with an added **Speedify** section.
7. Log in with the factory-default credentials printed in the router documentation and change the password immediately
   immediately.

### 3. Join Starlink's Wi-Fi (trusted) as a wireless WAN (no cable needed)

The Starlink dish/router was outdoors, making a wired WAN connection
impractical. Instead of wiring Starlink to the Beryl's WAN port, one radio was
put into WiFi repeater/client (WISP) mode and joined Starlink's own WiFi
network -- the trusted link, since it's the user's own hardware -- as a
wireless WAN source, on the stronger 5 GHz radio for full throughput.

### 4. Add the rental property Wi-Fi (untrusted) as a second wireless WAN

The Beryl's second radio (originally also pointed at Starlink) was
repurposed to join the rental property's own Wi-Fi network (an ISP-supplied ISP
router in this case) instead. This is the untrusted/shared link: an unknown
router administrator, unknown patch hygiene, and potentially other guests on
the same network. Joining the same network twice across both radios wastes a
radio; one radio per distinct upstream network is strictly more useful for
bonding -- and it's this second link that most needs Speedify's encryption
(see "Encryption note" below).

### 5. Confirm AP + STA coexistence per radio

In **Network > Wireless/Interfaces**, confirm each physical radio has:

- One wireless client (STA) interface joining its external network
  (Starlink on one radio, rental property Wi-Fi on the other).
- One Access Point (AP) interface still serving the Beryl's own local
  SSIDs for the user's devices (work laptop, phone, etc.).

AP and STA running concurrently on the same radio is supported on this
hardware and is what makes both the bonded-WAN uplinks and the local network
work from the same two radios.

### 6. Add the phone as a third connection via USB tether

Tether the phone to the Beryl AX over USB. Speedify picks this up as a third
bondable connection (cellular).

### 7. Set connection priority in Speedify

- **Primary:** Starlink Wi-Fi (trusted)
- **Secondary:** rental property Wi-Fi (untrusted, but now encrypted end-to-end by
  Speedify)
- **Backup / last resort only:** phone cellular (USB tether)

Rationale: Starlink and the rental property line are unmetered/flat-rate, so they can
be bonded freely for speed and failover. Leading with the trusted Starlink
link as primary, and keeping the untrusted rental property link secondary (still
bonded and still encrypted, just not relied on first) reflects the trust
difference between the two -- not just a speed preference. The phone's data
plan is capped, so it's reserved for backup -- only used if both other
connections degrade or drop, to avoid burning cellular data unnecessarily.

### 8. Connect the work laptop normally

Connect the work laptop to the Beryl's own Wi-Fi like any other network and
start VPN client as usual. From the laptop's perspective it's one ordinary
upstream connection; the bonding and encryption across Starlink/rental property/
cellular happens entirely on the router, underneath it.

## Encryption note: why this is a security win, not just a speed win

Speedify's bonded traffic between the router and Speedify's servers is
already encrypted end-to-end by default -- no extra encryption setup (e.g. a
separate VPN tunnel) was needed to satisfy an "ensure it's encrypted"
requirement. The practical effect is asymmetric between the two WiFi links:

- The **Starlink link** gains speed/failover benefits from bonding, but
  wasn't meaningfully "insecure" before -- it's the user's own network.
- The **rental property link** gains the same speed/failover benefits, *plus* it is
  now wrapped in encryption it did not have as a bare shared WiFi connection.
  Any traffic that would otherwise have crossed the rental property router in the
  clear (or relied solely on per-site HTTPS) is now additionally protected
  by Speedify's tunnel before it ever reaches that untrusted hop.

In short: bonding a trusted and an untrusted connection through Speedify
doesn't just average their speeds together -- it raises the untrusted link
up to the trusted link's security posture, while still using the trusted
link as the preferred path.

## Verification

- Confirmed each STA interface shows connected with an IP on its respective
  upstream network (Starlink, rental property).
- Confirmed the Speedify dashboard in LuCI shows all three connections
  (Starlink, rental property, cellular) listed with Starlink and rental property active/bonded
  and cellular idle/backup.
- Confirmed the work laptop, connected only to the Beryl's own Wi-Fi, reaches
  the Internet and VPN client reports authenticated/connected normally.
- Confirmed pulling the Starlink or rental property connection causes Speedify to
  fail over without the work laptop's session dropping.

## Rollback / recovery

MiriOS is beta for this router model (GL-MT3000). Two rollback paths exist if
needed:

1. **Normal rollback:** In the LuCI/MiriOS web admin, **System > Upgrade >
   Local Upgrade**, with official GL.iNet firmware downloaded from
   `dl.gl-inet.com` and **Keep Settings** disabled. This flashes back to
   stock GL.iNet firmware the same way MiriOS was installed.
2. **U-boot recovery mode:** If the web UI becomes unreachable (failed boot,
   bricked web admin), use the GL-MT3000's U-boot recovery mode to reflash
   firmware without relying on the web UI. Refer to GL.iNet's official
   recovery documentation for the exact button/timing sequence for this
   model before attempting it.

## Prevention / notes for next time

- Always fetch firmware files from bot-protection-guarded vendor sites using
  an actual browser session, not a script -- scripted requests can be
  silently blocked or served a non-file challenge page.
- Always disable "Keep Settings" when switching firmware families (stock
  GL.iNet <-> MiriOS) to avoid carrying over incompatible configuration.
- When bonding more than two upstreams, order connections by cost/reliability
  (unmetered/fast first, capped/slow last-resort) rather than letting
  Speedify's defaults decide.
- Double-check that a repurposed radio isn't still pointed at a WiFi network
  already joined by the other radio -- that wastes a bondable connection.
- When joining any unknown/shared WiFi (hotel, rental property, coworking space) as an
  upstream, treat it as untrusted by default and make sure the bonding layer
  (or a VPN) is actually encrypting traffic across it -- don't assume a
  venue's WiFi is safe just because it has a password.

## References

- <https://support.miri.tech/kb>
- <https://www.speedify.com>
- <https://dl.gl-inet.com> (official GL.iNet firmware, for rollback)
- [Isolating personal, work, and visitor devices on a Beryl AX](2026-10-04-beryl-ax-wireguard-home-network.md)
