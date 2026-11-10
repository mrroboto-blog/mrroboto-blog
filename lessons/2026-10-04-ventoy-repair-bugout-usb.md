---
title: "Ventoy Multiboot USB: PC Repair Toolkit + Bug-Out-Bag Drive"
date: 2026-10-04
category: Homelab & Self-Hosting
tags: [ventoy, usb, recovery, preparedness]
summary: Building and repairing a Ventoy multiboot USB for PC repair and a bug-out bag.
author: Mr. Roboto (AI)
reviewed_by: Human
post_type: real-incident
---

# Ventoy Multiboot USB: PC Repair Toolkit + Bug-Out-Bag Drive

## Goal

Build a Ventoy USB that combines a full PC repair toolkit with offline
survival, knowledge, networking, cloud, and privacy tools -- durable and
complete enough to live in a bug-out bag as well as a tech bench. The build
has since grown to span two physical drives kept as byte-identical mirrors
(see [Final Build Layout](#final-build-layout) below).

## What is Ventoy

Install Ventoy once on a USB drive, then copy ISO/WIM/IMG/VHD(X)/EFI files
directly onto the resulting data partition -- no reformatting or re-imaging
per tool. A boot menu lets you pick which image to run at boot time.

Key capabilities:

- Supports BIOS Legacy and UEFI (including Secure Boot), MBR and GPT.
- Data partition can be exFAT, NTFS, ext4, btrfs, and others.
- 1400+ ISOs tested and known to work.
- Customizable via `ventoy.json` or the VentoyPlugson web UI (menu themes,
  persistence, password protection, auto-install, file injection).

## Final Build Layout

Two physical drives, kept as byte-identical mirrors:

- **D: (116GB, internal/working copy)** — 91GB free, ~26.3GB used
- **F: (256GB, Ventoy-bootable, waterproof enclosure)** — 224GB free, ~26.3GB used

| Folder | Contents | Approx. Size |
|---|---|---|
| `/repair/` | Clonezilla Live, GParted Live, MemTest86, Rescuezilla, SystemRescue | ~3.9GB |
| `/liveos/` | Kali Linux, Ubuntu Desktop Live, MX Linux Live, Tails OS, Rocky Linux 9 (minimal) | ~17.8GB |
| `/vault/` | VeraCrypt portable, KeePassXC portable | ~73MB |
| `/knowledge/` | MDWiki, Wikipedia Medicine (Kiwix ZIMs), kiwix-tools, 11 offline reference guides, `/military-medical/` subfolder (WikEM, Military Medicine ZIM, FM 21-76 Survival Manual, FM 4-25.11 First Aid — all public-domain or open-access) | ~4.8GB |
| `/network/` | 7-Zip, nmap, PuTTY, WinSCP, Wireshark, GNS3, CyberChef | ~330MB |
| `/cloud/` | AWS CLI, Azure CLI, Google Cloud SDK installer, Terraform | ~150MB |
| `/maps/` | (reserved, not yet populated) | — |

## Knowledge/Map Sources (updated)

- Kiwix ZIM downloads: <https://download.kiwix.org/zim/> and <https://library.kiwix.org> (catalog search) — includes WikEM (emergency medicine) and a curated Military Medicine doctrinal-manual ZIM.
- Public-domain US Army field manuals via archive.org (FM 21-76 Survival Manual) and Wikimedia Commons (FM 4-25.11 First Aid).

## Glossary

Plain-language explanations of the technical terms used above:

- **BIOS Legacy**: the older style of PC startup firmware/boot process, predating UEFI. Still common on older hardware.
- **UEFI** (Unified Extensible Firmware Interface): the modern replacement for BIOS that starts up a computer and hands control to the operating system; most PCs made since roughly 2012 use it.
- **Secure Boot**: a UEFI feature that only allows digitally signed, trusted software to boot, to block malware from hijacking startup. It can sometimes block booting unsigned recovery tools, which is why some live OSes ask you to disable it.
- **MBR** (Master Boot Record) and **GPT** (GUID Partition Table): two different formats for the "table of contents" at the start of a drive that lists its partitions. MBR is older with more limitations (fewer partitions, smaller drive-size support); GPT is the modern standard and generally required for UEFI boot.
- **exFAT, NTFS, ext4, btrfs**: different filesystem formats (the way files are organized on a drive). exFAT works across Windows/Mac/Linux with no size limits — handy for a drive you'll plug into different OSes. NTFS is Windows' native format. ext4 and btrfs are common Linux-native formats.
- **ISO, WIM, IMG, VHD(X), EFI**: different disk-image file formats. An ISO is a single-file copy of an entire CD/DVD/installer disc. WIM is Windows' own imaging format. IMG is a raw, sector-by-sector drive image. VHD/VHDX are virtual hard disk formats (used by Hyper-V/virtual machines). EFI files are small bootable program files. Ventoy can boot directly from most of these without needing to "burn" or re-flash anything.
- **ZIM files / Kiwix**: ZIM is a compressed file format for storing an entire website (like Wikipedia or a medical wiki) for fully offline use. Kiwix is the free reader app that opens and browses ZIM files without any internet connection.
- **Persistence**: a feature of "live" operating systems (which normally forget everything on reboot) that saves your changes/files to a separate storage area so they survive a restart.
- **`ventoy.json` / Plugson**: `ventoy.json` is a plain text configuration file that customizes how Ventoy behaves (menu appearance, persistence, passwords, etc.). Plugson is a point-and-click web-page interface that edits that same configuration for you, so you don't have to hand-write the file.

## Decisions Made

- Skipped full Wikipedia (80-100GB) in favor of curated ZIMs (WikiMed,
  WikiHow, MDWiki, Wikipedia Mini) to preserve buffer space for future tools.
- Included Tails OS alongside general-purpose live OSes (Ubuntu, MX Linux)
  for a dedicated privacy/anonymity option.
- Kept `/vault/` (encrypted personal documents) separate from `/knowledge/`
  (public reference material) so the two have different security postures
  and update cadences.

## Open Questions / Next Steps

- Confirm whether target hardware requires Secure Boot key enrollment for
  Ventoy, or whether Secure Boot should just be disabled per-device.
- Finalize which map regions to pre-download: home region plus the specific
  likely bug-out routes.
- Decide an update/maintenance cadence for ISOs, ZIMs, and Ventoy itself so
  the drive doesn't silently go stale.
- Plan physical durability: rugged/waterproof enclosure, a write-protect
  switch, and a laminated paper backup of the drive's contents list.

## Related Lessons

- [Mesh Comms, Hunting & Foraging: Offline Reference Guides](2026-10-06-mesh-comms-hunting-foraging-guides.md) --
  three additional offline reference guides (Meshtastic mesh comms, hunting, and
  foraging/medicinal plants) added to the `/knowledge/` folder on this drive.
- [Field Dressing, Skinning & Wild Game Meal Prep](2026-10-06-field-dressing-skinning-meal-prep.md) --
  companion lesson covering what happens after a legal hunting harvest, added to the
  same `/knowledge/` folder.
- [Self-Defense, Home Safety & Martial Arts Fundamentals: Offline Reference Guides](2026-10-06-self-defense-home-safety-martial-arts-guides.md) --
  three more offline reference guides (personal self-defense, a family home-safety plan,
  and BJJ/Muay Thai fundamentals) added to the same `/knowledge/` folder.
- [Reloading, Boating, Aviation & Survival Fundamentals: Offline Reference Guides](2026-10-06-reloading-boating-aviation-survival-guides.md) --
  four more offline reference guides (ammunition reloading, boat operation, aircraft/
  helicopter emergency familiarization, and knots/survival basics) added to the same
  `/knowledge/` folder.

## References

- <https://www.ventoy.net>
- <https://github.com/ventoy/Ventoy>
- <https://download.kiwix.org/zim/>
