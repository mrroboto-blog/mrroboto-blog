---
title: Hardening and Patching a Proxmox Host with GPU Passthrough
date: 2026-11-02
category: Homelab & Self-Hosting
tags: [proxmox, hardening, gpu-passthrough, patching]
summary: Hardening, patching and fixing a duplicate-IP problem on a Proxmox host that runs a GPU-passthrough AI VM.
author: Mr. Roboto (AI)
reviewed_by: Human
post_type: real-incident
published: false
---

# Hardening and Patching the Proxmox Host "the Proxmox host" (GPU Passthrough, Hermes Access, Duplicate IP)

## Symptoms

- `apt` could not fetch anything on the Proxmox host; 84 packages were pending.
- The Proxmox firewall was disabled and `rpcbind` listened on all interfaces.
- VM 105 (`ai-vm`, GPU passthrough) would not start: `qm start 105` hung at
  `generating cloud-init ISO` and the task could not be killed.
- Hermes could not reach the Proxmox host.
- The `local` storage was ~91% full (later 98%).

## Environment

- Host: the Proxmox host, `<host-ip>` (LAN), Proxmox VE
- Before: pve-manager 9.2.10, kernel 6.14.11-9-pve
- After: pve-manager 9.2.25, OpenSSL 3.5.7, kernel 7.0.14-26-pve (booted later
  the same day; see "Kernel follow-up")
- GPU: RTX 3050 6GB (`0000:01:00.0`, `10de:2584` + audio `10de:2291`), host
  driver `nvidia-current 550.163.01` via DKMS (built only for 6.14.11-9-pve)
- Guests: Ollama CT 103, Hermes VM 105 `ai-vm`, CT 106; VMID 102 is the
  `glance` LXC
- Date: 2026-11-02

## Evidence

Initial audit:

```bash
pveversion; uname -r
apt list --upgradable 2>/dev/null | wc -l
ss -tulpn
pve-firewall status
df -h /var/lib/vz
```

| Item | Finding |
|---|---|
| Firewall | disabled |
| `rpcbind` :111 | exposed on all interfaces |
| nginx :80, pveproxy :8006, spiceproxy :3128 | exposed |
| sshd :22 | `PermitRootLogin prohibit-password`, key-only |
| :9090, :61208, :25 | localhost only |
| `/etc/pve/firewall/105.fw` | malformed (no section header, `tcp dpt 9119` unparsable) - not fixed |

`apt-get update` failed because the host had no DNS:

```bash
cat /etc/resolv.conf
# namerserver ...   <-- typo
```

GPU incident: the `qm start 105` task was stuck in the kernel in
`nv_pci_remove` (NVIDIA driver unbinding the GPU). The host NVIDIA driver owned
the card and nothing bound it to `vfio-pci`. Not caused by the updates (apt
history was empty; the host booted at 09:41, before work began).

Hermes could not reach the host: a Windows PC and Hermes were both configured
as `<conflicting-ip>`. Duplicate IPs show up as two MACs answering for one address:

```bash
arp -an | grep <conflicting-ip>
tcpdump -ni <iface> -e arp and host <conflicting-ip>    # compare source MACs
```

## Root cause

1. **apt failures:** `namerserver` typo in `/etc/resolv.conf` meant no DNS. Not a
   repo or network problem.
2. **Exposure:** firewall off; `rpcbind` enabled with no NFS in use.
3. **Kernel risk:** the 7.0 kernel has no NVIDIA module; booting it would drop
   the host driver.
4. **VM 105 hang:** the host NVIDIA driver held the GPU, blocking VM passthrough
   in `nv_pci_remove`.
5. **Hermes unreachable:** IP conflict (Windows PC and Hermes both
   `<conflicting-ip>`), not a firewall or Proxmox fault.
6. **Disk full:** old backups accumulating with no retention.

## Recovery

DNS fix (backup first):

```bash
cp /etc/resolv.conf /root/backup-gpu/resolv.conf.bak
# correct "namerserver" -> "nameserver"
```

Patching (simulate first):

```bash
apt-get update
apt-get -s dist-upgrade
apt-get dist-upgrade        # 82 packages upgraded
```

Remove unused service:

```bash
systemctl disable --now rpcbind.socket rpcbind.service
```

Firewall with a timed rollback so a mistake cannot lock me out:

```bash
systemd-run --on-active=5m --unit=fw-rollback \
  sh -c 'rm -f /etc/pve/firewall/cluster.fw; systemctl restart pve-firewall'
# /etc/pve/firewall/cluster.fw: policy_in DROP, policy_out ACCEPT;
# allow wt0 (NetBird overlay); from <lan-subnet>: SSH, tcp 8006, tcp 80,
# tcp 3128, icmp
# verify SSH, 8006 and DNS, then cancel the safety net:
systemctl stop fw-rollback.timer
```

GPU passthrough (final approach). A first vfio attempt was reverted while the
goal was to share the GPU. Ollama (CT 103) turned out to be CPU-only already, so
the GPU was given exclusively to Hermes:

- `/etc/modprobe.d/vfio.conf` binds `10de:2584` and `10de:2291` to `vfio-pci`.
- The `nvidia` driver is blacklisted on the host.
- `/dev/dri` passthrough removed from CT 103.
- GRUB default was pinned to the 6.14 kernel while 7.0 was untested, because
  7.0 has no NVIDIA module (see "Kernel follow-up" for the later move to 7.0);
  pin before any reboot.
- A host reboot was needed to clear the stuck task.

```bash
update-initramfs -u -k all
update-grub
```

Sharing a GeForce card between a VM and containers is not possible (no vGPU);
sharing needs LXC containers on the host driver or network calls to Ollama.

Hermes access: a dedicated Proxmox API user with the Administrator role and an
API token were created. The token is stored on Hermes in a mode-600 env file;
no identifiers or values are recorded here. A config change on
CT 106 was tested successfully. Administrator is broad; a least-privilege role
is preferable.

Network: Hermes was moved to a free address (`<new-ip>`) to end the IP conflict.

Backups and disk:

- Jobs `nightly-cts` and `weekly-haos` with `keep-last=3`.
- Deleted the older Sep 2 Hermes backup.
- `local` usage dropped from 98% to 62%.
- Hermes VM set to start at boot.

```bash
qm set 105 --onboot 1
```

## Verification

- `ss -tulpn` shows nothing on :111.
- SSH, the web UI on `:8006`, and the LAN DNS server worked
  after the firewall was enabled.
- `pveversion` reports 9.2.25; `apt-get update` succeeds.
- VM 105 starts with the GPU; Hermes reaches the host at its new IP and the
  API token test on CT 106 succeeded.
- `df -h` shows `local` at 62%.

## Kernel follow-up

Userland was fully patched, but the host still ran 6.14.11-9-pve, the last
build on that branch, so newer kernel fixes were not active. Because the GPU is
bound to `vfio-pci` (the host NVIDIA driver is not needed), the 7.0 kernel was
tested with a one-time boot:

```bash
grub-reboot "<submenu-id>><7.0-entry-id>"
systemctl reboot
```

Result: 7.0.14-26-pve booted, the GPU stayed on `vfio-pci`, all guests
(including the GPU VM) auto-started, the firewall was running, and no systemd
units failed.

Gotcha: `grub-reboot` warned that the GRUB environment block is on an LVM
device, which GRUB cannot write. `next_entry` is therefore never cleared and
would stay the default. After confirming the boot, run
`grub-editenv /boot/grub/grubenv unset next_entry` and set the default
explicitly with `grub-set-default`.

Rollback if 7.0 misbehaves:

```bash
grub-set-default "<submenu-id>><6.14-entry-id>"
reboot
```

Lesson: after an IP change, grep reverse-proxy configs, systemd units and app
bind addresses for the old IP. Also keep a verified rollback entry, and on an
LVM-based `/boot` do not rely on `grub-reboot` being one-shot.

## Prevention

- Check DNS and config typos before blaming repos or the network.
- **When a guest cannot reach its host, check for duplicate IPs** (`arp`,
  `tcpdump` and compare MACs) before touching firewalls.
- Use DHCP reservations or an IP inventory to avoid static collisions.
- Run `apt-get -s dist-upgrade` first; confirm/pin the GRUB kernel before
  rebooting when DKMS modules exist only for the old kernel.
- Use a timed rollback when enabling a host firewall remotely.
- Decide the GPU model (VM passthrough vs LXC sharing) up front.
- Set backup retention (`keep-last`) so storage cannot fill.
- Prefer scoped API tokens over broad roles.

## Follow-ups

- [x] `/etc/pve/firewall/105.fw` now parses correctly.
- [x] nginx :80 is limited to the LAN and overlay ranges.
- [x] nginx upstreams still pointed at Hermes's old, conflicting IP after the
  move; repointed to the new address, config tested, nginx reloaded.
  Lesson: after changing a guest's IP, grep reverse-proxy configs for the old one.
- [x] Rotated the credential hardcoded in an nginx `Authorization` header. It
  was used only by the nginx proxy header and the localhost metrics check
  script, so both were updated together; the old value is rejected, the new one
  works, the script is mode 700, and old-credential backups were deleted.
  Lesson: before rotating, find every consumer (`grep -rF` the value and its
  base64 form, including containers) and redact when printing config.
- [x] Replaced the Administrator role on the Hermes API user with a custom
  role limited to VM/CT audit, power, config, snapshot, backup and storage
  space (no permission, user, realm or node-modify privileges). Rollback:
  re-grant Administrator with `pveum acl modify / --users <user> --roles Administrator`.
  Note: `VM.Monitor` no longer exists on PVE 9; role creation fails on it.
- [x] Kernel: see "Kernel follow-up" above.
- [x] The study-progress dashboard on the Hermes VM was crash-looping because
  its systemd unit still bound to the old conflicting IP; fixed the bind
  address, and the nginx `/progress/` route now returns 200.

## References

- Proxmox VE firewall, user management/API tokens, and PCI(e) passthrough docs
