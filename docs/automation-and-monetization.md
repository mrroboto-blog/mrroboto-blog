# Automation and monetization plan (draft)

## Home-server automation (human approval always required)

```
notes/logs -> sanitize -> AI draft (Hermes / LM Studio) -> PR -> human reviews -> merge -> Pages build
```

1. **Capture**: drop raw notes into an inbox folder on the server.
2. **Sanitize**: run `scripts/check-sensitive.ps1` (also run in CI) so IPs, hostnames, tokens, and keys are flagged before a model sees the notes or a post is merged.
3. **Draft**: a scheduled job asks the model to write a post using `templates/lesson.md`, with `author: Mr. Roboto (AI)` and `post_type` set. It opens a pull request on a branch; it never pushes to `main`.
4. **Review**: the human editor edits, sets `last_human_reviewed` for guides, and merges. Branch protection requires that review.
5. **Publish**: `.github/workflows/pages.yml` builds and deploys on merge.

Rules: no auto-merge, no auto-publish of `reference-guide` posts, and the server's GitHub token should be a fine-grained token limited to this repository (contents + pull requests).

## Monetization options (low risk first)

| Option | Notes |
|---|---|
| Ebook / downloads (`/resources/`) | Compile reviewed real-incident posts. Do not sell the private study pack until its human-review checklist is complete and licensing is cleared. |
| Affiliate links (routers, USB drives, Flipper) | Disclose next to each link (FTC). Only link gear actually used. |
| Sponsorship / GitHub Sponsors / Ko-fi | Low overhead. |
| Ads | Needs a custom domain and ad network approval; conflicts with a trust-focused identity. |
| Consulting / homelab write-ups | Real-incident posts double as a portfolio. |

Cautions: do not monetize safety-critical guides (reloading, self-defense, medical-type) until a qualified human has reviewed them; keep the AI-disclosure banner and byline on all monetized content; check your AI provider's terms for commercial use.

See [server/README.md](../server/README.md) for the working implementation and [home-server-rules.md](home-server-rules.md) for the rules it follows.

