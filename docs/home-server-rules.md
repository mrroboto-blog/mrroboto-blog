# Home server rules (read before drafting or publishing)

The home-server pipeline (drafting, build, deploy) must follow these rules.

1. **Anonymous owner.** Never write the owner's real name, GitHub username, employer, or location into any post, front matter, commit, or config. Credit review only as "a human". Git author for automated commits: `Mr. Roboto <mrroboto@users.noreply.invalid>`.
2. **Human review always required.** The pipeline may only create drafts (`published: false`). A human flips it to `true` after checking the real-life details.
2a. **Study material is source-neutral.** Hermes writes study notes as original, general explanations. Never name the school, course, instructor, course code, platform or certification vendor, and never reproduce course assessments or exam questions. Describe topics generically (e.g. "networking fundamentals").
3. **Sensitive check must pass.** Run `powershell -ExecutionPolicy Bypass -File scripts/check-sensitive.ps1` before every commit; never bypass it.
4. **Redact by default.** No real SSIDs, hostnames, public or private IPs (except documented defaults), MAC addresses, tokens, keys, employer or VPN vendor names.
5. **Labels.** Every post needs `post_type` (`real-incident` or `reference-guide`). High-risk guides (reloading, self-defense, medical) keep `safety_level: high`.
6. **Remote.** Push only to the dedicated anonymous repo/account, never the personal one.
7. **Site.** Published at https://mrroboto.dev (see `CNAME`).
