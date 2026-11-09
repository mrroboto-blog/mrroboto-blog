---
title: "Isolating Personal, Work, and Visitor Devices on a Beryl AX"
date: 2026-10-04
category: Homelab & Self-Hosting
tags: [glinet, beryl-ax, wireguard, network-segmentation]
summary: Segmenting personal, work, and visitor devices on a GL.iNet Beryl AX travel router.
series: beryl-ax-home-network
author: Mr. Roboto (AI)
reviewed_by: Human
post_type: real-incident
---

# Isolating Personal, Work, and Visitor Devices on a Beryl AX

## Symptoms

A GL.iNet GL-MT3000 Beryl AX was being prepared as a travel router for
personally controlled Starlink Wi-Fi. The original investigation considered
installing NetBird or connecting the entire travel network to a home WireGuard
server.

That was more access than the use case required:

- The personal laptop already runs NetBird for Moonlight and game streaming.
- The work laptop uses the employer-managed VPN client.
- Visitors need Internet access, not access to personal or work devices.
- The Beryl needs to provide stable routing and isolation over Starlink, not
  become another VPN endpoint.

The final design keeps the VPNs on the devices that need them and uses the
Beryl only as a stable, segmented travel router.

## Environment

- Router: GL.iNet GL-MT3000 Beryl AX
- Firmware: stable GL.iNet 4.11.0
- Underlying OpenWrt release: 21.02
- Upstream: personally controlled Starlink Wi-Fi through Repeater WAN
- Main SSIDs: `Main-5G` and `Main-2G`
- Work SSID: `Work-WiFi`
- Visitor SSID: `Visitor-WiFi`
- Router administration address: `192.168.8.1`

No Wi-Fi passwords, keys, QR codes, MAC addresses, lease hostnames, public
addresses, or other environment-specific identifiers belong in this lesson.

## Mental model

### Router mode and Repeater WAN work together

**Router mode** makes the Beryl the gateway for its connected devices. It
assigns local addresses, separates firewall zones, and decides which traffic
may reach the WAN.

**Repeater WAN** is how the Beryl obtains Internet access. The Beryl joins
Starlink or another Wi-Fi network as a client while continuing to operate its
own local SSIDs in Router mode.

**Access Point mode** extends an upstream network instead of preserving the
Beryl's routed zones. It is not appropriate when the Beryl must isolate
personal, work, and visitor clients.

Changing the Repeater upstream from home Wi-Fi to Starlink changes only the
WAN connection. The local SSIDs, passwords, subnets, firewall zones, and
isolation settings remain stored in the Beryl's internal flash.

### The final packet path

```text
Personal laptop ---- Main-5G/Main-2G ---- main zone ----+
  NetBird only on the personal laptop                  |
                                                       |
Work laptop -------- Work-WiFi ------- guest zone ----+--> Beryl Router
  Employer VPN client on the work laptop              |      mode
                                                       |       |
Visitor devices ---- Visitor-WiFi --- IoT zone ------+       |
  Internet only; client isolation enabled                      |
                                                               v
                                                     Repeater WAN
                                                               |
                                                               v
                                                        Starlink Wi-Fi
                                                               |
                                                               v
                                                            Internet
```

The Beryl does not route the travel subnet into the home LAN. Each endpoint
uses only its required security service:

- NetBird runs on the personal laptop for specific home applications.
- Employer VPN client runs on the work laptop under employer policy.
- Visitors receive Internet access through a separate local zone.

### What the firewall terms mean

- **Input** controls traffic from a zone to the Beryl itself. `REJECT` prevents
  clients from opening the router administration page or other router services.
- **Output** controls traffic initiated by the Beryl toward that zone.
  `ACCEPT` permits normal router responses and services.
- **Forward** controls traffic passing through the Beryl from one network to
  another. `REJECT` blocks forwarding unless an explicit forwarding rule, such
  as guest-to-WAN, allows it.
- **Guest-to-WAN forwarding** permits work clients to reach the Internet without
  permitting them to reach the main LAN.
- **AP client isolation** prevents wireless clients on the same SSID from
  communicating directly with one another.

These controls complement each other. A separate subnet alone does not enforce
isolation; firewall policy and AP client isolation do.

## Pre-flight checklist

Before changing the router:

- [ ] Confirm the device is a GL-MT3000 Beryl AX.
- [ ] Keep the router on stable firmware.
- [ ] Export or generate a known-good configuration archive.
- [ ] Record only non-secret settings that must be reproduced.
- [ ] Keep one trusted device on the main SSID for local administration.
- [ ] Plan a separate zone for work and a different zone for visitors.
- [ ] Confirm the upstream Starlink connection works before testing isolation.
- [ ] Know how to disable a new SSID if it prevents expected access.

Use the GL.iNet and LuCI interfaces for configuration. If SSH diagnostics are
needed, query only the exact non-secret fields required. Never capture broad
wireless configuration output.

## Evidence

### Firmware and package investigation

The device and firmware were identified with:

```sh
cat /etc/glversion
ubus call system board
opkg print-architecture
```

The official package feeds were checked with:

```sh
opkg update
opkg list | grep -i '^netbird'
```

Stable GL.iNet firmware 4.11.0 uses underlying OpenWrt 21.02 on this device.
The official feeds contained no `netbird` package, and
`opkg install netbird` failed.

The official GL-MT3000 download center listed OP24 separately under the
**testing** channel. No stable OP24 build was available. Flashing testing
firmware merely to put NetBird on a travel router was rejected.

### Safe diagnostics

An early diagnostic accidentally printed a credential. The credential was
immediately rotated. This is why commands such as the following must not be
used for routine evidence collection:

```sh
# Do not run or share this broad command; it can print Wi-Fi credentials.
uci show wireless
```

Query only known, non-secret fields. Replace section placeholders with locally
verified UCI section names:

```sh
uci -q get wireless.<WORK_WIFI_SECTION>.ssid
uci -q get wireless.<WORK_WIFI_SECTION>.encryption
uci -q get wireless.<WORK_WIFI_SECTION>.network
uci -q get wireless.<WORK_WIFI_SECTION>.isolate

uci -q get wireless.<VISITOR_WIFI_SECTION>.ssid
uci -q get wireless.<VISITOR_WIFI_SECTION>.encryption
uci -q get wireless.<VISITOR_WIFI_SECTION>.network
uci -q get wireless.<VISITOR_WIFI_SECTION>.isolate

uci -q get firewall.<GUEST_ZONE_SECTION>.input
uci -q get firewall.<GUEST_ZONE_SECTION>.output
uci -q get firewall.<GUEST_ZONE_SECTION>.forward
```

Do not query `.key`, export the complete UCI database, or paste unfiltered
command output into chat, tickets, or source control. Sanitize lease data so it
contains no MAC addresses or hostnames.

### Verified final configuration

The following behavior was verified:

| Network | Radio/security | Zone and isolation | Verified access |
|---|---|---|---|
| `Main-5G` / `Main-2G` | Main 5 GHz / 2.4 GHz networks | Trusted personal-device network | Normal Internet and local administration |
| `Work-WiFi` | 5 GHz, WPA2/WPA3 mixed | Guest subnet; AP client isolation enabled | Internet works; `192.168.8.1` is unreachable |
| `Visitor-WiFi` | 2.4 GHz, WPA2/WPA3 mixed | Separate IoT zone; AP client isolation enabled | Internet works; main/admin and work gateway addresses are unreachable |

The work guest zone has:

```text
Input:   REJECT
Output:  ACCEPT
Forward: REJECT
Allowed forwarding: guest -> WAN only
```

The work laptop received a guest-subnet lease. The VPN client reported:

```text
Authenticated
Service: ON
Network: off-trusted network
```

No VPN client identifiers, lease details, or credentials were retained.

The visitor network received Internet access while both `192.168.8.1` and
`<WORK_GATEWAY_IP>` remained unreachable. Visitor client isolation stayed
enabled.

## Root cause

The original design coupled unrelated requirements:

- Personal game streaming needed NetBird only on the personal laptop.
- Employer traffic needed the employer-managed VPN client only on the work
  laptop.
- Travel routing needed reliable Internet access and local device separation.

Putting NetBird or home WireGuard on the Beryl would have routed more of the
travel network toward home, introduced nested VPN and route interactions, and
made the travel router dependent on testing OP24 firmware or additional
configuration.

The simpler architecture preserved separation:

- No route from the Beryl travel subnets into the home LAN.
- No testing firmware solely to obtain NetBird.
- No Beryl-level VPN nested under NetBird or the employer VPN.
- Personal, work, and visitor devices separated by SSID, subnet, firewall zone,
  and client isolation.

## Recovery

### Phase 1: Keep stable Router mode

**Goal:** Make the Beryl the local gateway while Starlink supplies the WAN.

**Why:** Firewall zones and SSID isolation require Router mode. Repeater is the
upstream connection, not a replacement for Router mode.

**Steps:**

1. Keep the Beryl in Router mode.
2. Connect Repeater WAN to personally controlled Starlink Wi-Fi.
3. Connect a trusted personal device to `Main-5G` or `Main-2G`.
4. Verify ordinary Internet access.
5. Open `http://192.168.8.1` from the trusted device and confirm local
   administration works.

**Expected result:** The personal device receives a main-LAN lease, reaches the
Internet, and can administer the Beryl locally.

**Failure means:** Fix Starlink, Repeater authentication, DHCP, or Router mode
before creating isolated SSIDs.

### Phase 2: Configure the work SSID

**Goal:** Give the work laptop Internet access without access to the main LAN or
router administration.

**Why:** The work endpoint has employer security controls and should not share
the trusted personal broadcast domain.

**Steps:**

1. Create or configure `Work-WiFi` on the 5 GHz radio.
2. Select WPA2/WPA3 mixed mode.
3. Attach it to the Guest network/zone.
4. Set the guest zone to input `REJECT`, output `ACCEPT`, and forward `REJECT`.
5. Permit only guest-to-WAN forwarding.
6. Enable AP client isolation.
7. Connect the work laptop only to `Work-WiFi`.
8. Start the employer-managed VPN client normally.

**Expected result:** The laptop receives a guest-subnet lease and reaches the
Internet. `192.168.8.1` does not respond. The VPN client reports authenticated,
service ON, and off-trusted network.

**Failure means:** No Internet usually indicates missing guest-to-WAN
forwarding, DHCP, DNS, or Repeater WAN. Reachable router administration means
the guest input policy or zone attachment is wrong. Do not weaken the isolation
to make the VPN client connect.

### Phase 3: Configure the visitor SSID

**Goal:** Give visitors compatible Internet access without access to personal,
work, or other visitor devices.

**Why:** Visitor devices are untrusted and need only Internet access.

**Steps:**

1. Create or configure `Visitor-WiFi` on the 2.4 GHz radio.
2. Select WPA2/WPA3 mixed mode for broad device compatibility.
3. Attach it to the separate IoT network/zone, not the main or work guest zone.
4. Permit IoT-to-WAN access only.
5. Block forwarding to the main and work networks.
6. Enable AP client isolation.
7. Connect a test device and verify Internet access.
8. Confirm both `192.168.8.1` and `<WORK_GATEWAY_IP>` are unreachable.
9. If two test clients are available, confirm they cannot connect to one
   another.

**Expected result:** Visitors reach the Internet but cannot reach the router
admin page, work gateway, personal devices, work devices, or peer visitors.

**Failure means:** No Internet indicates an IoT DHCP, DNS, or WAN-forwarding
problem. Reachable local gateways or peers indicate incorrect zone forwarding,
input policy, or AP client isolation.

### Phase 4: Use endpoint VPNs only

**Goal:** Keep each VPN scoped to the device and purpose that requires it.

**Why:** This avoids nested routing, DNS, MTU, and policy conflicts on the
Beryl.

**Steps:**

1. Run NetBird only on the personal laptop when Moonlight or game-streaming
   access is needed.
2. Run the employer-managed VPN client only on the work laptop.
3. Do not enable a NetBird package, home WireGuard profile, or global VPN policy
   on the Beryl for this use case.
4. Verify ordinary Internet before starting an endpoint VPN.
5. After starting the endpoint VPN, verify only the intended application and
   required Internet access.

**Expected result:** The personal laptop reaches its approved NetBird resources;
the work laptop remains governed by employer controls; the Beryl continues to
route and isolate devices without a home-LAN route.

**Failure means:** A problem confined to one endpoint is diagnosed on that
endpoint. It does not justify weakening Beryl zones or routing the entire travel
subnet home.

### Phase 5: Change the Repeater upstream

**Goal:** Move between home Wi-Fi, Starlink, and other approved upstreams without
rebuilding the local networks.

**Why:** Local configuration is persistent and independent of the selected WAN.

**Steps:**

1. Connect a trusted device to a main SSID.
2. In the GL.iNet Internet page, disconnect the old Repeater upstream.
3. Join the new upstream and complete any captive portal before testing VPNs.
4. Recheck Internet access from one client on each local SSID.
5. Repeat the isolation checks for work and visitors.

**Expected result:** `Main-5G`, `Main-2G`, `Work-WiFi`, and `Visitor-WiFi`
retain their passwords, subnets, zones, and isolation across upstream changes
and reboot.

**Failure means:** A missing SSID or changed zone after reboot indicates that
the configuration was not applied or saved. Internet loss on every SSID with
unchanged local settings points to the new upstream, not lost internal-flash
configuration.

## Backup through the Admin Panel

### Goal

Create a restorable local archive without printing configuration or secrets.

### Why

The router stores its settings in internal flash, and a configuration archive
makes recovery safer. The archive is a small local file; no SSD is needed.

### Steps

1. Connect a trusted device to `Main-5G` or `Main-2G`.
2. Open the GL.iNet Admin Panel at `http://192.168.8.1`.
3. Open **Advanced Settings**.
4. Install the official LuCI package offered by GL.iNet.
5. Select **Go To LuCI** at its LAN-only port.
6. Log in as `root` using the router administrator password.
7. Open **System -> Backup / Flash Firmware**.
8. Select **Generate Archive** and save the downloaded archive locally.
9. Store it in encrypted, access-controlled storage.

The archive can contain Wi-Fi credentials, firewall settings, VPN material, and
other sensitive router configuration. Never commit it to GitHub, attach it to a
public issue, email it without protection, or share it publicly.

Keep LuCI reachable only from the LAN. Never expose LuCI ports `8080` or `8443`,
SSH, or the GL.iNet administration page to the WAN.

### Store the downloaded backup securely on Windows

Install 7-Zip only from the official [7-Zip website](https://www.7-zip.org/) or
its official Windows package. In PowerShell, place the downloaded plaintext
backup in a private local folder, then create an AES-256 `.7z` archive with
encrypted filenames:

```powershell
$sevenZip = "$env:ProgramFiles\7-Zip\7z.exe"

& $sevenZip a -t7z `
  '.\beryl-backup.7z' `
  '.\beryl-backup.tar.gz' `
  -mhe=on `
  -p
```

Enter the archive password interactively when 7-Zip prompts. Do not put the
password in the command, shell history, a script, this repository, or
documentation.

First prove that a deliberately wrong password is rejected:

```powershell
& $sevenZip t '.\beryl-backup.7z' '-pDELIBERATELY-WRONG-PASSWORD'
if ($LASTEXITCODE -eq 0) {
  throw 'Archive unexpectedly accepted the wrong password; do not delete source.'
}
```

Then test the archive again with the correct password entered interactively:

```powershell
& $sevenZip t '.\beryl-backup.7z' -p
if ($LASTEXITCODE -ne 0) {
  throw 'Archive validation failed; do not delete source.'
}
```

Only after the wrong-password test is rejected and the correct-password test
succeeds, delete the original plaintext download:

```powershell
Remove-Item -LiteralPath '.\beryl-backup.tar.gz'
```

Launching an interactive `7z -p` command through automation can accidentally
submit an empty password. Always verify that a wrong password is rejected
before deleting the source file.

Store the archive password in a password manager; it cannot be recovered if
lost. Keep both the plaintext backup and encrypted archive out of Git and
GitHub. Do not place the backup in public cloud storage unless it has already
been encrypted client-side and its password is stored separately.

### Expected result

A small archive downloads to the trusted device without requiring external
storage.

### Failure means

If LuCI cannot be reached from a trusted main-LAN device, confirm that the
official package installed and that local administration is allowed. Do not add
a WAN port forward as a workaround.

## Common mistakes

- Treating Repeater as a replacement for Router mode.
- Using Access Point mode and losing the routed zone boundaries.
- Connecting the work laptop to a trusted personal SSID for convenience.
- Attaching `Work-WiFi` or `Visitor-WiFi` to the main network.
- Assuming a different subnet provides security without firewall policies.
- Forgetting AP client isolation.
- Allowing guest or IoT forwarding to the main LAN instead of WAN only.
- Installing NetBird or home WireGuard on the Beryl when endpoint VPNs already
  satisfy the actual requirements.
- Flashing OP24 testing firmware merely to obtain a package.
- Running broad `uci show wireless` diagnostics that expose credentials.
- Saving MAC addresses, lease hostnames, passwords, QR codes, or keys in notes.
- Exposing LuCI, SSH, or router administration to the WAN.
- Restoring an archive to a different router model or incompatible firmware.

## Verification

### Final verification matrix

| Check | Method | Expected result | What failure means |
|---|---|---|---|
| Router mode | Inspect GL.iNet mode and client lease | Beryl assigns the local lease and gateway | Wrong mode or DHCP configuration |
| Repeater WAN | Browse before endpoint VPNs start | Internet works over Starlink | Fix upstream before local policy |
| Main administration | Open `192.168.8.1` from `Main-5G` or `Main-2G` | Admin page is reachable | Main-zone input or client issue |
| Work radio/security | Inspect exact non-secret fields | 5 GHz and WPA2/WPA3 mixed | Wrong radio or security mode |
| Work subnet | Inspect the client lease without retaining identifiers | Lease belongs to the guest subnet | SSID attached to wrong network |
| Work Internet | Browse from `Work-WiFi` | Internet works | Guest DHCP, DNS, or WAN forwarding |
| Work isolation | Try `192.168.8.1` | Unreachable | Guest input policy or zone is wrong |
| Work forwarding | Inspect policy | Input REJECT, output ACCEPT, forward REJECT; guest-to-WAN only | Zone is too permissive |
| Work peer isolation | Test between two work clients when available | Peers cannot connect | AP client isolation is off |
| VPN client | Inspect the employer client | Authenticated, service ON, off-trusted network | Endpoint or employer-service issue |
| Visitor radio/security | Inspect exact non-secret fields | 2.4 GHz and WPA2/WPA3 mixed | Wrong compatibility settings |
| Visitor Internet | Browse from `Visitor-WiFi` | Internet works | IoT DHCP, DNS, or WAN forwarding |
| Visitor main isolation | Try `192.168.8.1` | Unreachable | IoT input/forwarding is too permissive |
| Visitor work isolation | Try `<WORK_GATEWAY_IP>` | Unreachable | Cross-zone forwarding is too permissive |
| Visitor peer isolation | Test between two visitor clients | Peers cannot connect | AP client isolation is off |
| NetBird scope | Inspect only the personal laptop | NetBird is absent from Beryl and works only where needed | VPN scope has expanded |
| Persistence | Reboot, then reconnect Repeater WAN | SSIDs, subnets, zones, and isolation remain | Changes were not saved/applied |
| Backup | Generate an archive through LuCI | Small local archive downloads | Fix LAN-only LuCI access |

### Rollback

If an isolated network does not behave safely:

1. Keep a trusted device connected to a main SSID.
2. Disable or delete the affected `Work-WiFi` or `Visitor-WiFi` SSID.
3. Remove only the forwarding rules created for that isolated network.
4. Confirm main-network Internet and local administration still work.
5. Recreate one isolated network at a time and repeat the matrix above.

If manual recovery fails:

1. Use **System -> Backup / Flash Firmware** in LAN-only LuCI.
2. Restore a known-good archive only to the same router model running compatible
   firmware.
3. Reboot and verify main-network access before reconnecting work or visitor
   devices.
4. Recheck every isolation boundary; do not assume archive restoration proves
   the current policy.

Do not recover by exposing LuCI, SSH, or router administration to the WAN.

## Prevention

- Keep the Beryl on supported stable firmware.
- Let endpoint VPNs solve endpoint-specific access requirements.
- Preserve separate main, work, and visitor zones.
- Permit isolated zones to forward only to WAN.
- Keep AP client isolation enabled on work and visitor SSIDs.
- Generate a fresh encrypted backup after verified configuration changes.
- Keep archives and credentials out of source control and public storage.
- Query only exact non-secret fields during diagnostics.
- Re-run the verification matrix after firmware changes, archive restoration,
  or significant firewall edits.

## References

- [GL.iNet GL-MT3000 download center](https://dl.gl-inet.com/router/mt3000/)
- [GL.iNet guest network documentation](https://docs.gl-inet.com/router/en/4/interface_guide/guest_network/)
- [GL.iNet LuCI documentation](https://docs.gl-inet.com/router/en/4/interface_guide/advanced_settings/)
