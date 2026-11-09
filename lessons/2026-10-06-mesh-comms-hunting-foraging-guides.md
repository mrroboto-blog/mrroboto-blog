---
title: "Mesh Comms, Hunting & Foraging: Offline Reference Guides"
date: 2026-10-06
category: Skynet Survival
tags: [meshtastic, hunting, foraging, preparedness]
summary: AI-compiled offline guides for mesh communications, hunting, and foraging.
author: Mr. Roboto (AI)
reviewed_by: Human
post_type: reference-guide
last_human_reviewed: TBD
safety_level: high
---

> Companion offline reference guides for the build documented in
> [Ventoy multiboot USB: PC repair toolkit + bug-out-bag drive](2026-10-04-ventoy-repair-bugout-usb.md)
> and its [usage manual](2026-10-04-ventoy-usb-usage-manual.md). See also the companion
> [Field Dressing, Skinning & Wild Game Meal Prep](2026-10-06-field-dressing-skinning-meal-prep.md),
> [Self-Defense, Home Safety & Martial Arts Fundamentals: Offline Reference Guides](2026-10-06-self-defense-home-safety-martial-arts-guides.md),
> and [Reloading, Boating, Aviation & Survival Fundamentals: Offline Reference Guides](2026-10-06-reloading-boating-aviation-survival-guides.md).

# Mesh Comms, Hunting & Foraging: Offline Reference Guides

## Goal

Add three offline reference guides to the bug-out USB's knowledge base, covering
skills with no dependency on cell service or internet connectivity: off-grid mesh
communications, hunting, and foraging/medicinal plants. These are meant to be
read and practiced ahead of time, not learned for the first time in an emergency.
See the companion [Field Dressing, Skinning & Wild Game Meal Prep](2026-10-06-field-dressing-skinning-meal-prep.md)
lesson for what happens after a legal hunting harvest.

## Guide 1: Meshtastic & Off-Grid Mesh Communications

Meshtastic is an open-source firmware/project for cheap LoRa radios (ESP32/nRF52 boards) that creates a long-range, encrypted, infrastructure-free mesh network — no cell towers, no internet, no subscription. Ideal for bug-out comms, convoy/group coordination, and remote work sites with no signal.

### 1. Hardware

Official supported boards (buy from a reputable vendor — RAK, Heltec, LilyGo, Seeed, or the official Meshtastic store): e.g. Heltec V3, RAK4631, T-Beam, T-Echo. Pick based on:
- Battery life needed (RAK4631/nRF52 boards sip power, good for weeks)
- GPS built-in (T-Beam, RAK with GPS module) — useful for position-sharing
- Display (most boards have a small OLED for status without a phone)

LoRa frequency band MUST match your region (US/CA = 915MHz, EU = 868MHz, etc.) — buying the wrong region's board means it won't be legal/compliant to transmit on.

### 2. Flashing Firmware

1. Go to the official web flasher: https://flasher.meshtastic.org (works in Chrome/Edge via WebSerial, no install needed) or use the official `meshtastic` Python CLI for offline flashing.
2. Connect the board via USB, select it in the flasher, choose the latest stable firmware release matching your region, and flash.
3. First boot: the device creates its own node identity (random short/long name) — you'll rename it from the app.

### 3. Software / Apps (official)

| Platform | App | Install |
|---|---|---|
| Android/iOS | Meshtastic app | Official app store listing |
| Windows/Linux/macOS | Meshtastic Desktop (Kotlin Multiplatform) | .msi/.deb/.dmg from github.com/meshtastic releases |
| CLI (any OS) | meshtastic Python package | pip install meshtastic (needs Python 3 + CP210x/CH9102 USB-serial driver) |
| Browser | Web client | client.meshtastic.org (needs WebSerial/WebBluetooth, works offline once loaded) |

#### Python CLI quick reference

```
pip install meshtastic
meshtastic --port COM3 --info          # show node info
meshtastic --port COM3 --set-owner "Callsign"
meshtastic --port COM3 --ch-set name "Family" --ch-index 0
meshtastic --port COM3 --ch-set psk random --ch-index 0   # set random pre-shared key (encrypted channel)
meshtastic --port COM3 --sendtext "test message"
```

### 4. Initial Configuration (any client)

1. Region: Settings → LoRa → Region. Must match your legal RF region (US, EU_868, ANZ, etc.) — wrong region = illegal transmission + device won't talk to properly-configured neighbors.
2. Channel name + PSK (pre-shared key): Default channel is public/unencrypted (LongFast with the default key is well-known). For actual privacy, generate a new channel with a random PSK and share the resulting QR code / URL only with your group.
3. Modem preset: LongFast = max range, slower data (default, good general-purpose). ShortFast = faster, shorter range (good in dense mesh like a group hiking together). Match presets across all nodes in a mesh — mismatched presets can't hear each other.
4. Node role: Client (normal handheld), Client Mute (listen/relay only, doesn't originate traffic — good for a fixed relay node), Router (dedicated infrastructure relay, keep these at high/central points), Tracker (GPS position beacon only).
5. Position broadcast interval: Longer interval = better battery life. Disable GPS broadcast entirely for OPSEC-sensitive use.

### 5. Building Out a Mesh for a Group / Bug-Out Team

- Give every team member a node, all on the same channel/PSK.
- Place 1–2 Router nodes at high ground / rooftops if you have a fixed base, to extend range between mobile nodes.
- Use the app's node list to see signal quality (SNR) and hop count to every other node — hop count of 1 = direct line of sight/range; higher hop counts mean messages are relaying through other nodes.
- Range: flat open terrain with the default antenna can realistically hit 2–6 miles node-to-node; dense forest/urban drops this to under a mile per hop, but multi-hop relaying extends overall network reach.

### 6. Other Mesh-Networking Options (non-Meshtastic)

- goTenna Mesh (discontinued consumer product but used devices still function on their own protocol — proprietary, not interoperable with Meshtastic).
- Reticulum (RNS) — software-defined mesh/cryptographic networking stack that can run over LoRa, packet radio, serial, or even IP — more flexible than Meshtastic but steeper learning curve. Official: reticulum.network
- Amateur radio (Ham) packet/APRS — requires a license (Technician class in the US, free written exam) but gives access to repeaters and much longer range than LoRa mesh. Worth pursuing alongside Meshtastic for serious off-grid comms redundancy.

### 7. Legal Notes

- Meshtastic's default LoRa power/frequency settings are designed to comply with unlicensed ISM-band rules (US Part 15, EU SRD860) — don't modify transmit power beyond board defaults unless you understand your local RF regulations.
- Ham radio (packet/APRS/voice) requires passing an exam and holding a callsign — transmitting on ham frequencies without a license is illegal in most countries.

## Guide 2: General Hunting Field Guide (Survival / Bug-Out Context)

Always follow local laws. Hunting seasons, license/tag requirements, legal weapons/ammunition per species, and protected-species lists vary by state/country and change yearly. This guide is general field knowledge for preparedness — it does not replace your state wildlife agency's current regulations, which you must check (most US state Fish & Wildlife / DNR agencies publish free digital hunting guides every season). In a genuine survival (non-regulated, life-safety) situation, the priority is calories and safety, but build the skill/legal knowledge now, before you need it.

### 1. Hunter Education & Safety (do this first)

- Most US states require a Hunter Education certificate before a license is issued — usually a free/low-cost official course (often available online through your state agency or the International Hunter Education Association, ihea.com). Complete this before hunting anywhere regulated.
- Firearm/bow safety fundamentals: treat every weapon as loaded, control the muzzle direction at all times, keep finger off trigger until on target, know your target and what's beyond it, wear blaze orange where required.
- Always tell someone your hunting location and expected return time.

### 2. Big Game (deer, elk, hogs)

- Deer (whitetail/mule): Most active dawn/dusk. Key sign: tracks (heart-shaped, splayed under weight), rubs (bark scraped off saplings — bucks marking territory), scrapes (cleared ground patches), and trails between bedding and feeding areas (bedding = thick cover; feeding = field edges, mast-producing trees like oak). Field dress promptly to cool the carcass; internal organs removed within 30 min of harvest in warm weather to prevent spoilage.
- Elk: Similar sign but larger scale; bugling in rut (fall) helps locate bulls. Much larger carcass — plan for quartering in the field and multiple trips or game cart/pack-out.
- Wild hogs (invasive in much of the US, often unprotected/year-round in some states): Travel in sounders (groups), root up ground/wallows as sign, very strong sense of smell, moderate hearing, poor eyesight — hunt into the wind. Aggressive if cornered; wait for a clear, humane shot angle.

### 3. Small Game (rabbit, squirrel)

- Low equipment/skill barrier, often liberal seasons — a good beginner / high-calorie-return-per-effort option in a survival context.
- Squirrel: still-hunt (move slow, stop often, let them resume activity) near mast trees (oak, hickory) at dawn/dusk.
- Rabbit: look for brush piles, fence lines, field edges; flushes when approached, a shotgun with small shot is the common/legal method in most jurisdictions.
- Snaring/trapping for small game is covered in general survival manuals (see FM 21-76-style references) — legality of trapping without a license varies hugely; it is intended for genuine survival scenarios, not everyday hunting in most jurisdictions.

### 4. Upland Birds & Waterfowl

- Upland (quail, pheasant, grouse): Flush from cover, often hunted with a trained dog; grouse "drum" (wing-beat sound) to locate territory in spring.
- Waterfowl (duck/goose): Heavily regulated (federal + state duck stamp required in the US in addition to state license); decoys + calls near water/feeding fields at first light; non-toxic (steel/bismuth) shot is legally required over wetlands in the US — lead shot is illegal for waterfowl.

### 5. Fishing (often paired with hunting for a bug-out food plan)

- Simplest reliable survival protein source where water is present. A basic kit: hooks, light line, small split-shot weights, a handful of lures — all tiny/light to carry. Trotlines/limb lines (multiple baited hooks left unattended) are effective but illegal to leave unattended in many jurisdictions outside true survival situations — know the local rule.

### 6. Processing & Food Safety

- Field dress (remove entrails) ASAP to cool the carcass; keep the cavity clean/dry.
- Hang/cool to ~40°F (4°C) before butchering where possible; in warm climates bone out meat quickly into smaller pieces that cool faster.
- Cook wild game to a safe internal temp (poultry 165°F/74°C, ground meat 160°F/71°C, whole-muscle cuts can be cooked to taste if handled cleanly, but when in doubt, cook thoroughly — wild game can carry parasites/pathogens domestic meat doesn't).
- Trichinosis risk (from hogs/bear): cook pork/wild hog to 160°F internal minimum, no exceptions.

### 7. Preparedness-Specific Notes

- A .22LR rifle is the classic "survival/bug-out" small-game gun: light ammo (carry hundreds of rounds in the space/weight of a few dozen centerfire rounds), quiet relative to centerfire, effective on small game and pest control, less effective/appropriate on big game.
- A general-purpose centerfire rifle (e.g., .308/30-06 class) covers big game if that's a realistic need in your area.
- Practice shot placement and marksmanship fundamentals before you need it — see official military marksmanship field manuals (e.g. FM 3-22.9) for fundamentals (sight picture, breathing, trigger control) that apply equally to hunting accuracy.
- Scouting/sign-reading (tracks, scat, rubs, trails, water sources) is a skill you can practice year-round even outside hunting season.

### 8. Resources to pull when you have connectivity

- Your state Fish & Wildlife / DNR website — current season dates, bag limits, and digital regulation handbook (usually a free PDF).
- IHEA-USA (ihea.com) — hunter education course finder.
- NSSF ("Hunting Works for America") general beginner resources.

Field dressing, skinning, and wild game meal prep are covered in the companion
[Field Dressing, Skinning & Wild Game Meal Prep](2026-10-06-field-dressing-skinning-meal-prep.md)
lesson.

## Guide 3: Foraging & Medicinal Plant Guide (Temperate North America Focus)

**Safety first — read this before anything else:**
- Never eat or apply any wild plant unless you are 100% certain of its identification, ideally confirmed by multiple independent features (not just one photo match). Many edible/medicinal plants have toxic look-alikes (e.g., wild carrot family contains both Queen Anne's Lace and deadly poison hemlock / water hemlock — some of the most dangerous plants in North America).
- Use the Universal Edibility Test only as an absolute last-resort survival measure, never as routine practice — it is slow, can still result in serious illness from toxic/allergic reactions, and is not a substitute for real identification skill.
- "Medicinal" does not mean "safe in any quantity" — many medicinal plants are dose-dependent, interact with medications, or are dangerous for pregnant people, children, or those with certain conditions. This guide is educational reference, not medical advice — when in doubt, don't ingest it.
- Positive identification resources to cross-reference before relying on this guide in the field: a regional field guide with range maps, your state agricultural extension office (free plant ID help, often by photo/email), and local foraging groups/mentors.

### 1. Core Identification Skills

- Learn plant families first (e.g., Apiaceae/carrot family, Asteraceae/daisy family) — family-level traits narrow down what a plant could be and flag "use extreme caution" families (Apiaceae contains both great edibles like wild carrot and the two deadliest plants in North America).
- Note: leaf arrangement (opposite/alternate/whorled), leaf margin (toothed/smooth/lobed), flower structure, stem cross-section (round/square — square stems = mint family, generally a safer family with no deadly members), smell (crushed leaves — true wild onion/garlic must smell like onion/garlic, or don't eat it), and habitat/season.

### 2. Common Widely-Known Edible/Medicinal Plants (general reference)

| Plant | ID notes | Traditional/folk use | Caution |
|---|---|---|---|
| Plantain (Plantago major/lanceolata) | Low rosette, parallel-veined oval or lance leaves, common in lawns/trails | Crushed leaf poultice traditionally used for insect bites/minor skin irritation | Generally very safe; still patch-test |
| Yarrow (Achillea millefolium) | Feathery/fern-like leaves, flat-topped white flower clusters | Traditional styptic (bleeding control) poultice for minor cuts | Avoid in pregnancy; can cause skin sensitivity in some people |
| Dandelion (Taraxacum officinale) | Toothed leaves in a rosette, single yellow flower, milky sap, hollow stem | Leaves/root used as food and traditional diuretic/digestive bitter | Milky sap can irritate skin for some; avoid if allergic to ragweed family |
| Elderberry (Sambucus nigra/canadensis) | Compound leaves (5-11 leaflets), flat-topped white flower clusters, dark purple berry clusters | Cooked berries traditionally used for cold/flu support (syrup) | Raw berries, leaves, stems, and roots are toxic (cyanide-producing compounds) — must be cooked, never eaten raw |
| Willow bark (Salix species) | Long narrow leaves, grows near water | Inner bark traditionally chewed/brewed — contains salicin (aspirin precursor) | Same contraindications as aspirin (not for children due to Reye's syndrome risk, bleeding disorders, aspirin allergy) |
| Pine (needles/inner bark, most Pinus species) | Needle clusters, resinous smell | Needle tea traditionally used as a vitamin C source | Avoid Ponderosa pine and yew (not a true pine) — some conifers are toxic; confirm species |
| Cattail (Typha species) | Tall reed, distinctive brown "hot dog" seed head, grows in wetlands | Root starch, young shoots, and pollen are edible; one of the most reliable wild survival foods | Only harvest from clean, non-contaminated water sources (cattails can bioaccumulate pollutants) |

### 3. High-Danger Look-Alikes (memorize these to avoid, even more than you memorize the edibles)

- Poison hemlock (Conium maculatum) and water hemlock (Cicuta species) — both deadly, both resemble wild carrot/Queen Anne's Lace and parsley/parsnip. Water hemlock is often cited as the most acutely toxic plant in North America. Key (imperfect) differences: hemlocks often have purple-blotched stems and an unpleasant musty smell, while wild carrot has a hairy stem and carrot smell when the root is crushed — do not rely on memory of a single trait; if there is any doubt, do not harvest anything in this plant family from the wild.
- Foxglove (Digitalis) resembles comfrey/mullein to a careless glance — foxglove is a cardiac-glycoside poison.
- Death camas resembles wild onion/garlic but lacks the onion smell — always smell-test anything you believe is wild onion/garlic.

### 4. Building This Skill for Real

- Start with 3–5 plants you can identify with total confidence in your specific region (not from this table blindly — confirm what actually grows near you), and only expand slowly.
- A regional, range-map-based field guide (physical book or offline app with your specific region's species) is essential — this document is a high-level overview, not a substitute.
- Consider taking an in-person foraging walk with a local expert/herbalist before relying on self-taught ID in a real emergency.

### 5. Where to Learn More Offline

- Wikibooks (CC-licensed) has open-content herbalism/foraging references.
- General wilderness-skill wikibooks also touch on plant use for cordage, tinder, and other non-ingested survival uses, which carry far less risk than ingestion and are a good place to practice plant-ID confidence first.

## Glossary

Plain-language explanations of the specialized terms used above:

**Mesh comms (Guide 1)**
- **LoRa**: "Long Range" — a radio technology that trades data speed for very long range and low power use, the basis of Meshtastic.
- **ESP32 / nRF52**: common low-cost microcontroller chip families used inside Meshtastic radio boards.
- **Node**: an individual Meshtastic radio/device on the mesh network.
- **PSK (pre-shared key)**: a secret password-like key that encrypts a channel so only people who have it can read messages on it.
- **Modem preset (LongFast/ShortFast)**: a radio speed/range trade-off setting — all devices that talk to each other must use the same preset.
- **SNR (signal-to-noise ratio)**: a measure of how clear/strong a radio signal is versus background interference; higher is better.
- **Hop count**: how many other devices a message had to relay through to reach you; 1 means direct contact, higher numbers mean it bounced through other nodes.
- **OPSEC (operational security)**: practices that avoid leaking information (like your location) that could be used against you.
- **Reticulum (RNS)**: a different, more flexible open-source mesh-networking software stack, separate from and not compatible with Meshtastic.
- **APRS**: Automatic Packet Reporting System, a ham-radio data protocol for text/position messages.
- **Technician class (license)**: the entry-level US amateur (ham) radio license, earned via a free written exam.
- **ISM band / Part 15 / SRD860**: unlicensed radio-frequency bands and the US/EU rules that let low-power devices (like LoRa radios) transmit on them without a license, as long as they follow power limits.
- **Callsign**: a unique identifier licensed ham radio operators must use when transmitting.

**Hunting (Guide 2)**
- **Hunter Education certificate**: a safety course (often free, sometimes online) most US states require before issuing a hunting license.
- **Blaze orange**: the high-visibility orange clothing required in many states so other hunters can see you.
- **Rut**: the breeding season for deer/elk, when males are most active and vocal (bugling).
- **Sounder**: a group of wild hogs traveling together.
- **Still-hunt**: a slow, stop-and-go hunting technique rather than sitting in one spot.
- **Duck stamp**: a required federal (and often state) permit/fee specifically for waterfowl hunting, in addition to a regular license.
- **Non-toxic shot**: shotgun ammunition (e.g., steel, bismuth) that doesn't contain lead, legally required over wetlands to avoid poisoning waterfowl.
- **Trotline / limb line**: a fishing line with multiple baited hooks left unattended; often restricted outside true survival situations.
- **Trichinosis**: a parasitic illness from undercooked pork/wild hog/bear meat, prevented by cooking to a safe internal temperature.
- **.22LR / centerfire**: cartridge types — .22LR is a small, lightweight, quiet round for small game; centerfire cartridges (like .308) are larger rounds used for big game.
- **FM 3-22.9**: a public US Army field manual covering rifle marksmanship fundamentals.
- **Sign** (tracks, scat, rubs, scrapes): physical evidence animals leave behind that hunters read to find them.

**Foraging (Guide 3)**
- **Plant family** (e.g., Apiaceae/carrot family, Asteraceae/daisy family): a scientific grouping of related plants that tend to share traits — including, in some families, both safe and deadly look-alike species.
- **Universal Edibility Test**: a slow, last-resort survival procedure for testing an unknown plant in small stages; not a routine identification method.
- **Patch-test**: applying a small amount of a substance to skin first to check for a reaction before broader use.
- **Cyanide-producing compounds**: toxic chemicals in some raw plant parts (like elderberry) that are neutralized by cooking.
- **Salicin**: a natural compound in willow bark chemically related to aspirin.
- **Reye's syndrome**: a rare but serious illness linked to children taking aspirin (or aspirin-like compounds) during a viral illness.
- **Cardiac glycoside**: a class of plant toxin (found in foxglove) that affects heart function and can be fatal.

## Where These Live on the Drive

These three guides are offline reference material, not bootable images — they belong
alongside the other reference content in `/knowledge/` on the Ventoy drive described in
[Ventoy multiboot USB: PC repair toolkit + bug-out-bag drive](2026-10-04-ventoy-repair-bugout-usb.md),
next to the Kiwix ZIM files (WikiMed, WikiHow, MDWiki, Wikipedia Mini). See the
[usage manual](2026-10-04-ventoy-usb-usage-manual.md) for how the drive's folders are
organized and how to add new content without re-flashing.

## References

- <https://meshtastic.org>
- <https://flasher.meshtastic.org>
- <https://client.meshtastic.org>
- <https://reticulum.network>
- <https://www.ihea.com>
- Your state Fish & Wildlife / DNR website (regulations vary by jurisdiction and year)
